//
//  MultipeerReceiver.swift
//
//
//  Created by Young Geo on 2/27/24.
//

import MultipeerConnectivity
import Combine

class MultipeerReceiver {
    let dataPublisher = PassthroughSubject<Data, Never>()

    private let session: MCSession

    init(session: MCSession) {
        self.session = session
    }
}

extension MultipeerReceiver {
    func receive(_ data: Data) {
        dataPublisher.send(data)
    }
}
