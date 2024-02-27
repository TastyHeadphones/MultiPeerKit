//
//  DataSendRecord.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import Foundation

struct DataSendRecord: Hashable, Codable {
    let uuid: String
    var state: DataSendState

    init(uuid: String = UUID().uuidString, state: DataSendState) {
        self.uuid = uuid
        self.state = state
    }

    mutating func updateState(_ state: DataSendState) {
        self.state = state
    }

    var dataValue: Data {
        try! JSONEncoder().encode(self)
    }
}
