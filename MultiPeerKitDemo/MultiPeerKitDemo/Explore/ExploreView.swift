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

    init(user: User) {
        self.user = user
    }

    var body: some View {
        HStack {
            Image(systemName: "person")
                .resizable()
                .frame(width: 20, height: 20)
            Text(user.name)
            Spacer()
            switch user.state {
            case .none:
                EmptyView()
            case .accept:
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            case .decline:
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            case .fail:
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            case .pending:
                Image(systemName: "clock.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
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
                    let taskId = MultipeerManagerHelper.sharedManager.send(sendMessage.data(using: .utf8)!, to: [MultipeerManagerHelper.sharedManager.store.peer(for: user.id)!])
                    ExploreViewModel.taskUserMap[taskId] = user
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

    static var taskUserMap = [String: User]()

    var showAlert = false

    var showContent = false

    var receivedData: TraceableData?

    var users: [User] = []

    init() {
        MultipeerManagerHelper.sharedManager.beginConnection()
        MultipeerManagerHelper.sharedManager.store.$peers.sink { [weak self] peers in
            self?.users = peers.compactMap(\.info?.user)
        }
        .store(in: &cancellables)
        MultipeerManagerHelper.sharedManager.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { data in
            self.receivedData = data
            self.showAlert = true
        }
        .store(in: &cancellables)
        MultipeerManagerHelper.sharedManager.sendRecordPublisher
            .receive(on: DispatchQueue.main)
            .sink { record in
            self.users = self.users.map { user in
                if let taskUser = ExploreViewModel.taskUserMap[record.uuid] {
                    if user.id == taskUser.id {
                        var user = user
                        user.state = record.state
                        return user
                    }
                }
                return user
            }
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
            Alert(title: Text("Receied Data"),
                  message: Text("\(viewModel.receivedData!.uuid)"),
                  primaryButton: .default(Text("Accept"),
                                          action: {
                viewModel.showAlert = false
                viewModel.showContent = true
                try? MultipeerManagerHelper.sharedManager.acceptData(from: viewModel.receivedData!.uuid)
            }),
                  secondaryButton: .cancel {
                viewModel.showAlert = false
                try? MultipeerManagerHelper.sharedManager.declineData(from: viewModel.receivedData!.uuid)
            })
        }
        .sheet(isPresented: $viewModel.showContent, content: {
            VStack {
                Text(viewModel.receivedData!.uuid)
                    .font(.title)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                Text(String(data: viewModel.receivedData!.data, encoding: .utf8)!)
                    .font(.title)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            }
        })
    }
}
