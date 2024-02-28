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

    func removePeer(with id: String) {
        peers.removeAll { $0.id == id }
    }

    public func peer(for id: String) -> Peer? {
        return peers.first { $0.id == id }
    }
}
