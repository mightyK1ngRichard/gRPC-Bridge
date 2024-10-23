//
//  ChatCellView.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 23.10.2024.
//

import SwiftUI

struct ChatCellView: View {
    var message: ChatMessage

    var body: some View {
        VStack(alignment: .leading) {
            Text(message.owner)
                .font(.system(size: 14, weight: .medium))

            Text(message.message)
                .font(.system(size: 14, weight: .regular))
                .padding(.top, 5)

            Divider()
            Text("\(message.time)")
                .font(.system(size: 14, weight: .ultraLight))
        }
        .padding()
        .background(.white, in: .rect(cornerRadius: 8))
    }
}

#Preview {
    ChatCellView(
        message: ChatMessage(
            id: UUID(),
            owner: "Dima Permyakov",
            message: "Просто текст сообщения",
            time: Date()
        )
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
