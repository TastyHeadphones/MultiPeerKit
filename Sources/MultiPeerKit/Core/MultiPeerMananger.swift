//
//  MultiPeerMananger.swift
//
//
//  Created by Young Geo on 2/23/24.
//

import MultipeerConnectivity
import Combine

public final class MultipeerManager: NSObject {
    private let localPeerID: MCPeerID
    private let session: MCSession

    private let sender: MultipeerSender
    private let receiver: MultipeerReceiver

    private let browser: MCNearbyServiceBrowser
    private let advertiser: MCNearbyServiceAdvertiser
    public let store = PeersStore()

    public let dataPublisher: AnyPublisher<TraceableData, Never>

    public init(peer: Peer, serviceType: String) {
        localPeerID = peer.mcPeerID
        session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .none)
        sender = MultipeerSender(session: session, header: peer.info)
        receiver = MultipeerReceiver(session: session)
        browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: serviceType)
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: peer.info, serviceType: serviceType)
        dataPublisher = receiver.dataPublisher.eraseToAnyPublisher()
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
    public func beginConnection() {
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
    }

    public func stopConnection() {
        browser.stopBrowsingForPeers()
        advertiser.stopAdvertisingPeer()
    }

    public func send(_ data: Data, to peers: [Peer]) throws -> String {
        try sender.send(data: data, to: peers.map { $0.mcPeerID })
    }

    public func acceptData(from uuid: String) throws {
        guard let mcPeerID = store.sendTrackingMap[uuid] else {
            throw PeerError.noPeerTrackError
        }
        try receiver.response(with: DataSendRecord(uuid: uuid, state: .accept), to: mcPeerID)
    }

    public func decline(from uuid: String) throws {
        guard let mcPeerID = store.sendTrackingMap[uuid] else {
            throw PeerError.noPeerTrackError
        }
        try receiver.response(with: DataSendRecord(uuid: uuid, state: .decline), to: mcPeerID)
    }
}

extension MultipeerManager: MCSessionDelegate {
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let record = ReceiveDataProcessor.getResponse(data: data) {
            sender.updateSendRecord(record)
            return
        }
        receiver.receive(data.traceableValue!)
    }

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        let peer = Peer(mcPeerID: peerID, info: info)
        store.addPeer(peer)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        store.removePeer(with: peerID.displayName)
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session) // Always accept the invitation for receiving data
    }
}
