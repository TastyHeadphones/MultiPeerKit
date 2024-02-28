//
//  User.swift
//  MultiPeerKitDemo
//
//  Created by Young Geo on 2/28/24.
//

import MultiPeerKit
import UIKit

struct User: Codable, Identifiable, Hashable {
    var id: String { deviceId }

    let deviceId: String
    let name: String
    let activator: String

    var state: DataSendState?

    static let current = User(deviceId: UIDevice.current.identifierForVendor!.uuidString,
                              name: generateRandomString(length: 7),
                              activator: "")

    var dictValue: [String: String] {
        ["deviceId": deviceId, "name": name, "activator": activator]
    }
}

extension [String: String] {
    var user: User? {
        guard let deviceId = self["deviceId"],
              let name = self["name"],
              let activator = self["activator"] else { return nil }
        return User(deviceId: deviceId, name: name, activator: activator)
    }
}

func generateRandomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}
