//
//  ChatMessage.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 23.10.2024.
//

import Foundation
import SwiftProtobuf

struct ChatMessage: Identifiable {
    let id: UUID
    var owner: String
    var message: String
    var time: Date
}
