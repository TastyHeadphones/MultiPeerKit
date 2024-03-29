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

    private let header: [String: String]?

    private let session: MCSession

    init(session: MCSession, header: [String: String]?) {
        self.session = session
        self.header = header
    }

    func send(data: Data, to peers: [MCPeerID]) -> String {
        let uuidString = UUID().uuidString
        let traceableData = TraceableData(header: header, data: data, uuid: uuidString)
        do {
            try session.send(traceableData.dataValue, toPeers: peers, with: .reliable)
            LogTool.log("Send data \(traceableData) to \(peers)", level: .debug)
            let record = DataSendRecord(uuid: uuidString, state: .pending)
            updateSendRecord(record)
        } catch {
            LogTool.log("Fail to send data \(error.localizedDescription) \(session.connectedPeers)", level: .error)
            let record = DataSendRecord(uuid: uuidString, state: .fail)
            updateSendRecord(record)
        }
        return uuidString
    }
}

extension MultipeerSender {
    func updateSendRecord(_ record: DataSendRecord) {
        Task.detached(priority: .background) { [weak self] in
            self?.recordPublisher.send(record)
        }
    }
}
