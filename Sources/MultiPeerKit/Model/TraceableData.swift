//
//  ReceivedData.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import Foundation

public struct TraceableData: Sendable, Codable {
    public let header: [String: String]? // Peer advertisement info
    public let data: Data
    public let uuid: String

    public var dataValue: Data {
        try! JSONEncoder().encode(self)
    }
}

public extension Data {
    var traceableValue: TraceableData? {
        try? JSONDecoder().decode(TraceableData.self, from: self)
    }
}
