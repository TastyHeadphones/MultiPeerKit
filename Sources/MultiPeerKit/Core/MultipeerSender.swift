//
//  MultipeerSender.swift
//  
//
//  Created by Young Geo on 2/27/24.
//

import MultipeerConnectivity
import Combine

class MultipeerSender {
    let recordPublisher = PassthroughSubject<DataSendRecord, Never>()

    private let session: MCSession

    init(session: MCSession) {
        self.session = session
    }

    func send(data: Data, to peers: [MCPeerID]) throws -> String {
        let uuidString = UUID().uuidString
        let traceableData = TraceableData(data: data, uuid: uuidString)
        try session.send(traceableData.dataValue, toPeers: peers, with: .reliable)
        let record = DataSendRecord(uuid: uuidString, state: .pending)
        updateSendRecord(record)
        return uuidString
    }
}

extension MultipeerSender {
    func updateSendRecord(_ record: DataSendRecord) {
        recordPublisher.send(record)
    }
}
