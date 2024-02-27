//
//  PeersStore.swift
//
//
//  Created by Young Geo on 2/23/24.
//

import MultipeerConnectivity
import Combine

final class PeersStore {
    @Published var peers: [Peer] = []
    var sendTrackingMap: [String: MCPeerID] = [:] // This is used to keep track of the send data uuid to specific peer

    func addPeer(_ peer: Peer) {
        peers.append(peer)
    }

    func removePeer(with id: String) {
        peers.removeAll { $0.id == id }
    }

    func peer(for id: String) -> Peer? {
        return peers.first { $0.id == id }
    }
}
