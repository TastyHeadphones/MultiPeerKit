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

    private let session: MCSession

    init(session: MCSession) {
        self.session = session
    }
}

extension MultipeerReceiver {
    func receive(_ data: TraceableData) {
        dataPublisher.send(data)
    }

    func  response(with record: DataSendRecord, to peer: MCPeerID) throws {
        try session.send(record.dataValue, toPeers: [peer], with: .reliable)
    }
}
