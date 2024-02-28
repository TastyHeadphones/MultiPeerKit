//
//  ReceivedData.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import Foundation

public struct TraceableData: Sendable, Codable {
    let header: [String: String]? // Peer advertisement info
    let data: Data
    let uuid: String

    var dataValue: Data {
        try! JSONEncoder().encode(self)
    }
}

extension Data {
    var traceableValue: TraceableData? {
        try? JSONDecoder().decode(TraceableData.self, from: self)
    }
}
