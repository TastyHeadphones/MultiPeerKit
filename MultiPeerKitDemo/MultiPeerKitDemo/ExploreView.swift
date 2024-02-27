//
//  ExploreView.swift
//  MultiPeerKitDemo
//
//  Created by Young Geo on 2/27/24.
//

import SwiftUI
import MultiPeerKit
import Combine

struct User: Codable, Identifiable {
    var id: String { name }

    let name: String
    let activator: String

    static let current: User = User(name: UUID().uuidString, activator: "https://picsum.photos/200")

    var dictValue: [String: String] {
        ["name": name, "activator": activator]
    }
}

extension [String: String] {
    var user: User {
        User(name: self["name"]!, activator: self["activator"]!)
    }
}

struct UserView: View {
    let user: User

    var body: some View {
        HStack {
            Image(systemName: "person")
                .resizable()
                .frame(width: 50, height: 50)
            Text(user.name)
        }
    }
}

@Observable class ExploreViewModel {
    let mananger = MultipeerManager(peer: .init(id: UIDevice.current.identifierForVendor!.uuidString, info: User.current.dictValue),
                                    serviceType: "mpkit")

    private var cancellables = Set<AnyCancellable>()

    var users: [User] = []

    init() {
        mananger.beginConnection()
        mananger.store.$peers.sink { [weak self] peers in
            self?.users = peers.compactMap(\.info?.user)
        }
        .store(in: &cancellables)
    }
}

struct ExploreView: View {
    var viewModel = ExploreViewModel()

    var body: some View {
        List(viewModel.users) { user in
            Text(user.name)
        }
    }
}
