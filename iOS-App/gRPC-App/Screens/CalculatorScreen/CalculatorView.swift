//
//  CalculatorView.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 22.10.2024.
//

import SwiftUI

struct CalculatorView: View {
    private let grpcManager = GRPCManager.shared
    var body: some View {
        VStack {
            Button("Make Sum") {
                grpcManager.addTwoNumbers(num: 10, num2: 12)
            }
            .buttonStyle(BorderedProminentButtonStyle())

            Button("Find Max") {
                grpcManager.findMaximum(numbers: 0, 2, 5, 6, 12)
            }
            .buttonStyle(BorderedButtonStyle())

            Button("Compute Average") {
                grpcManager.computeAverage(numbers: 0, 2, 5, 6, 12)
            }
            .buttonStyle(BorderedProminentButtonStyle())

            Button("Fibo") {
//                grpcManager.fibo(number: 10) { numbers in
//                    print("[DEBUG]: numbers: \(numbers)")
//                }

                Task {
                    do {
                        let numbers = try await grpcManager.fibo(number: 10)
                        print("Fibonacci numbers: \(numbers)")
                    } catch {
                        print("Error occurred: \(error)")
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    CalculatorView()
}
