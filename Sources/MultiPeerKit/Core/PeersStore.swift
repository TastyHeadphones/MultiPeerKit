//
//  PeersStore.swift
//
//
//  Created by Young Geo on 2/23/24.
//

import MultipeerConnectivity
import Combine

final class PeersStore {
    let peersPublisher = CurrentValueSubject<[Peer], Never>([])

    func addPeer(_ peer: Peer) {
        if peersPublisher.value.contains(peer) { return }
        peersPublisher.value.append(peer)
    }

    func removePeer(with mcPeerID: MCPeerID) {
        peersPublisher.value.removeAll { $0.mcPeerID == mcPeerID }
    }

    func peer(for id: String) -> Peer? {
        return peersPublisher.value.first { $0.id == id }
    }
}
