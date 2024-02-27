//
//  DataSendState.swift
//
//
//  Created by Young Geo on 2/27/24.
//

enum DataSendState: String, Sendable, Codable {
    case fail
    case decline
    case accept
    case pending
}
