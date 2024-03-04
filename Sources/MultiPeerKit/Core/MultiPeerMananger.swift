//
//  MultiPeerMananger.swift
//
//
//  Created by Young Geo on 2/23/24.
//

import MultipeerConnectivity
import Combine

public final class MultipeerManager: NSObject {
    private let serviceType: String
    private let localPeerID: MCPeerID
    private let session: MCSession

    private let sender: MultipeerSender
    private let receiver: MultipeerReceiver

    private let store = PeersStore()

    private let browser: MCNearbyServiceBrowser
    private var advertiser: MCNearbyServiceAdvertiser

    public let dataPublisher: AnyPublisher<TraceableData, Never>
    public let sendRecordPublisher: AnyPublisher<DataSendRecord, Never>
    public let peersPublisher: AnyPublisher<[Peer], Never>

    public init(peer: Peer, serviceType: String) {
        self.serviceType = serviceType
        localPeerID = peer.mcPeerID
        session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
        sender = MultipeerSender(session: session, header: peer.info)
        receiver = MultipeerReceiver(session: session)
        browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: serviceType)
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: peer.info, serviceType: serviceType)
        dataPublisher = receiver.dataPublisher.eraseToAnyPublisher()
        sendRecordPublisher = sender.recordPublisher.eraseToAnyPublisher()
        peersPublisher = store.peersPublisher.eraseToAnyPublisher()
        super.init()
        setupDelegate()
    }

    private func setupDelegate() {
        session.delegate = self
        browser.delegate = self
        advertiser.delegate = self
    }
}

extension MultipeerManager {
    public func updateAdvertiser(_ peer: Peer, isAdvertising: Bool = true) {
        advertiser.stopAdvertisingPeer()
        Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: peer.info, serviceType: serviceType)
            advertiser.delegate = self
            guard isAdvertising else { return }
            try await Task.sleep(nanoseconds: UInt64(2e9)) // 2s delay for MCNearbyServiceBrowserDelegate work
            advertiser.startAdvertisingPeer()
        }
    }

    public func startBrowsingForPeers() {
        browser.startBrowsingForPeers()
    }

    public func stopBrowsingForPeers() {
        browser.stopBrowsingForPeers()
    }

    public func startAdvertisingPeer() {
        advertiser.startAdvertisingPeer()
    }

    public func stopAdvertisingPeer() {
        advertiser.stopAdvertisingPeer()
    }

    public func beginConnection() {
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
    }

    public func stopConnection() {
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
    }

    public func send(_ data: Data, to peers: [String]) -> String {
        send(data, to: peers.compactMap { store.peer(for: $0) })
    }

    public func send(_ data: Data, to peers: [Peer]) -> String {
        sender.send(data: data, to: peers.map { $0.mcPeerID })
    }

    public func acceptData(from uuid: String) throws {
        guard let mcPeerID = receiver.idPeerMap[uuid] else {
            throw PeerError.noPeerTrackError
        }
        try receiver.response(with: DataSendRecord(uuid: uuid, state: .accept), to: mcPeerID)
    }

    public func declineData(from uuid: String) throws {
        guard let mcPeerID = receiver.idPeerMap[uuid] else {
            throw PeerError.noPeerTrackError
        }
        try receiver.response(with: DataSendRecord(uuid: uuid, state: .decline), to: mcPeerID)
    }
}

extension MultipeerManager: MCSessionDelegate {
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let record = ReceiveDataProcessor.getResponse(data: data) {
            LogTool.log("Received Response \(record)", level: .debug)
            sender.updateSendRecord(record)
            return
        }
        receiver.receive(data.traceableValue!, from: peerID)
    }

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: .infinity)
        let peer = Peer(mcPeerID: peerID, info: info)
        store.addPeer(peer)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        store.removePeer(with: peerID)
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session) // Always accept the invitation for receiving data
    }
}
