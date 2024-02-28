//
//  MultipeerManagerHelper.swift
//  MultiPeerKitDemo
//
//  Created by Young Geo on 2/28/24.
//

import MultiPeerKit

class MultipeerManagerHelper {
    static let sharedManager = MultipeerManager(peer: Peer(id: User.current.id,
                                                           info: User.current.dictValue),
                                                serviceType: "mpkit")
}
