//
//  ExploreView.swift
//  MultiPeerKitDemo
//
//  Created by Young Geo on 2/27/24.
//

import SwiftUI
import MultiPeerKit
import Combine

struct UserView: View {
    let user: User

    var body: some View {
        HStack {
            Image(systemName: "person")
                .resizable()
                .frame(width: 10, height: 10)
            Text(user.name)
            Button(action: {
                try? MultipeerManagerHelper.sharedManager.send("Hello".data(using: .utf8)!, to: [MultipeerManagerHelper.sharedManager.store.peer(for: user.id)!])
            }) {
                Image(systemName: "arrow.right.circle")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
        }
    }
}

@Observable class ExploreViewModel {
    private var cancellables = Set<AnyCancellable>()

    var showAlert = false

    var users: [User] = []

    init() {
        MultipeerManagerHelper.sharedManager.beginConnection()
        MultipeerManagerHelper.sharedManager.store.$peers.sink { [weak self] peers in
            print(peers)
            self?.users = peers.compactMap(\.info?.user)
        }
        .store(in: &cancellables)
        MultipeerManagerHelper.sharedManager.dataPublisher.sink { data in
            print(data)
            self.showAlert = true
        }
        .store(in: &cancellables)
    }
}

struct ExploreView: View {
    @State var viewModel = ExploreViewModel()

    var body: some View {
        VStack{
            Text("\(User.current.name)")
            List(viewModel.users) { user in
                UserView(user: user)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Receive"), message: Text("Receive"), dismissButton: .default(Text("OK")))
        }
    }
}
