//
//  ReceiveDataProcessor.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import Foundation

enum DataType: Sendable {
    case response
    case receiveData
}

enum ReceiveDataProcessor {
    static func getResponse(data: Data) -> DataSendRecord? {
        try? JSONDecoder().decode(DataSendRecord.self, from: data)
    }
}
