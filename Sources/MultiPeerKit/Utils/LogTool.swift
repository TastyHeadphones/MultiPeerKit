//
//  LogTool.swift
//
//
//  Created by Young Geo on 2/29/24.
//

import os

enum LogTool {
    private static let logger = Logger(subsystem: "io.github.tastyheadphones", category: "MultiPeerKit")

    static func log(_ message: String, level: OSLogType) {
        logger.log(level: level, "\(message)")
    }
}
