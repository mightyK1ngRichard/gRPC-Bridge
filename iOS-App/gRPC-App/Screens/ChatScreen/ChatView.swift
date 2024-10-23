//
//  ChatView.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 23.10.2024.
//

import SwiftUI

struct ChatView: View {
    @State var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            TextField("Введите имя", text: $viewModel.uiProperties.userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Соединение", action: viewModel.connect)
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(maxWidth: .infinity, alignment: .trailing)

            TextField("Введите сообщение", text: $viewModel.uiProperties.messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Отправить сообщение", action: viewModel.sendMessage)
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(maxWidth: .infinity, alignment: .trailing)

            ScrollView {
                VStack(spacing: 3.5) {
                    ForEach(viewModel.messages) { message in
                        ChatCellView(message: message)
                    }
                }
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .background(
            Color(
                uiColor: UIColor(
                    red: 242/255,
                    green: 242/255,
                    blue: 242/255,
                    alpha: 1
                )
            )
        )
    }
}

// MARK: - Preview

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            messages: [
                ChatMessage(
                    id: UUID(),
                    owner: "Dima Permyakov",
                    message: "Просто моковый текст сообщения",
                    time: Date()
                )
            ]
        )
    )
}
