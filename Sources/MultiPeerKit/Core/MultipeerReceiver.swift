//
//  MultipeerReceiver.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import MultipeerConnectivity
import Combine

class MultipeerReceiver {
    let dataPublisher = PassthroughSubject<TraceableData, Never>()

    var idPeerMap: [String: MCPeerID] = [:] // This is used to keep track of the send data uuid to specific peer

    private let session: MCSession

    init(session: MCSession) {
        self.session = session
    }
}

extension MultipeerReceiver {
    func receive(_ data: TraceableData, from peer: MCPeerID) {
        dataPublisher.send(data)
        idPeerMap.updateValue(peer, forKey: data.uuid)
    }

    func  response(with record: DataSendRecord, to peer: MCPeerID) throws {
        try session.send(record.dataValue, toPeers: [peer], with: .reliable)
    }
}
