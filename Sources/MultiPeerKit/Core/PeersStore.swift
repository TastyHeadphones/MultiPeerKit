//
//  PeersStore.swift
//
//
//  Created by Young Geo on 2/23/24.
//

import MultipeerConnectivity
import Combine

public final class PeersStore {
    @Published public var peers: [Peer] = []

    func addPeer(_ peer: Peer) {
        peers.append(peer)
    }

    func removePeer(with mcPeerID: MCPeerID) {
        peers.removeAll { $0.mcPeerID == mcPeerID }
    }

    public func peer(for id: String) -> Peer? {
        return peers.first { $0.id == id }
    }
}
