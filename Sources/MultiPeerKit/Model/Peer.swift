//
//  Peer.swift
//
//
//  Created by Young Geo on 2/23/24.
//

import MultipeerConnectivity

public struct Peer: Hashable, Sendable {
    public let id: String // This id should be unique key for each peer for send data to specific peer, can use device id
    public let mcPeerID: MCPeerID // mcPeerID is same to id for easy access to peer
    public let info: [String: String]?

    public init(id: String, info: [String: String]?) {
        self.id = id
        self.mcPeerID = MCPeerID(displayName: id)
        self.info = info
    }

    public init(mcPeerID: MCPeerID, info: [String: String]?) {
        self.id = mcPeerID.displayName
        self.mcPeerID = mcPeerID
        self.info = info
    }
}
