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
    @State var prsentTextFiled = false
    @State var sendMessage: String = ""

    let user: User

    var body: some View {
        HStack {
            Image(systemName: "person")
                .resizable()
                .frame(width: 20, height: 20)
            Text(user.name)
            Spacer()
            Button(action: {
                prsentTextFiled = true
            }) {
                Image(systemName: "arrow.right.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .sheet(isPresented: $prsentTextFiled) {
            VStack {
                Text("\(User.current.name)")
                    .font(.title)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                TextField("Send Message", text: $sendMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                Button(action: {
                    try? MultipeerManagerHelper.sharedManager.send(sendMessage.data(using: .utf8)!, to: [MultipeerManagerHelper.sharedManager.store.peer(for: user.id)!])
                    prsentTextFiled = false
                }) {
                    Image(systemName: "paperplane")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
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
