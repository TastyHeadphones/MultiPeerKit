//
//  DataSendRecord.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import Foundation

public struct DataSendRecord: Hashable, Codable {
    public let uuid: String
    public var state: DataSendState

    public init(uuid: String = UUID().uuidString, state: DataSendState) {
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
