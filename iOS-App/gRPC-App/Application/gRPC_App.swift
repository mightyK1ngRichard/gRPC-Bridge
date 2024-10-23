//
//  gRPC_App.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 22.10.2024.
//

import SwiftUI

enum TabType: Int {
    case calc
    case chat
}

@main
struct gRPC_App: App {
    @State private var selectedTab: TabType = .chat

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                CalculatorView()
                    .tag(TabType.calc)
                    .tabItem {
                        Label("Калькулятор", systemImage: "numbers.rectangle")
                    }

                ChatView()
                    .tag(TabType.chat)
                    .tabItem {
                        Label("Чат", systemImage: "message")
                    }
            }
            .tint(.purple)
        }
    }
}
