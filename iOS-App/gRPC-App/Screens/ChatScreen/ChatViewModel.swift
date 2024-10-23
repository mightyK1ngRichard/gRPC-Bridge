//
//  ChatViewModel.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 23.10.2024.
//

import Foundation
import Observation

@Observable
final class ChatViewModel {
    var uiProperties: UIProperties
    private(set) var messages: [ChatMessage]
    private let grpcManager = GRPCManager.shared

    init(uiProperties: UIProperties = UIProperties(), messages: [ChatMessage] = []) {
        self.uiProperties = uiProperties
        self.messages = messages
    }

    func connect() {
        grpcManager.connect(
            userID: uiProperties.userName,
            userName: uiProperties.userName
        ) { [weak self] message in
            self?.messages.append(message)
        }
    }

    func sendMessage() {
        grpcManager.sendMessage(message: uiProperties.messageText, userID: uiProperties.userName)
    }
}

// MARK: - UIProperties

extension ChatViewModel {

    struct UIProperties {
        var userName = ""
        var messageText = ""
    }
}
