//
//  CalculatorView.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 22.10.2024.
//

import SwiftUI

struct CalculatorView: View {
    var body: some View {
        VStack {
            Button("Make Sum") {
                GRPCManager.shared.addTwoNumbers(num: 10, num2: 12)
            }
            .buttonStyle(BorderedProminentButtonStyle())

            Button("Find Max") {
                GRPCManager.shared.findMaximum(numbers: 0, 2, 5, 6, 12)
            }
            .buttonStyle(BorderedButtonStyle())

            Button("Compute Average") {
                GRPCManager.shared.computeAverage(numbers: 0, 2, 5, 6, 12)
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    CalculatorView()
}
