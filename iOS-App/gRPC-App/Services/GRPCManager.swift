//
//  GRPCManager.swift
//  gRPC-App
//
//  Created by Dmitriy Permyakov on 22.10.2024.
//

import Foundation
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf

/// Команды для кодгена:
/// `protoc --swift_out=. calc.proto`
/// `protoc --grpc-swift_out=. calc.proto`
final class GRPCManager {
    static let shared = GRPCManager()

    private let group: EventLoopGroup
    private let client: Calc_CalcClientProtocol

    private init(address: String = "127.0.0.1") {
        self.group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let channel = ClientConnection(
            configuration: .default(
                target: ConnectionTarget.hostAndPort(address, 50051),
                eventLoopGroup: group
            )
        )
        client = Calc_CalcNIOClient(channel: channel)
    }

    func addTwoNumbers(num: Int, num2: Int) {
        var request = Calc_AddRequest()
        request.firstNumber = Int32(num)
        request.secondNumber = Int32(num2)
        let calloption = CallOptions(eventLoopPreference: .indifferent)
        let unaryCall = client.add(request, callOptions: calloption)
        do {
            let response = try unaryCall.response.wait()
            print("Sum Received received: \(response.sumResult)")
        } catch {
            print("Sum Received failed: \(error)")
        }
    }

    func findMaximum(numbers: Int...) {
        let call = client.findMaximum(callOptions: nil) { maxNumber in
            print("[DEBUG]: currentMax=\(maxNumber)")
        }

        // Отправляем числа на сервер
        for number in numbers {
            var request = Calc_FindMaximumRequest()
            request.number = Int32(number)
            let _ = call.sendMessage(request)
            print("[DEBUG]: отправили: \(number)")
        }

        let end = call.sendEnd()
        _ = end.always { res in
            switch res {
            case .success:
                print("Ended BD: Success")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }

    func computeAverage(numbers: Int...) {
        let call = client.computeAverage(callOptions: nil)

        for number in numbers {
            var response = Calc_ComputeAverageRequest()
            response.number = Int32(number)
            _ = call.sendMessage(response)
            print("[DEBUG]: отправили: \(number)")
        }

        call.response.whenComplete { result in
            switch result {
                case let .success(response):
                print("[DEBUG]: average=\(response.average)")
            case let .failure(error):
                print("error \(error)")
            }
        }

        let end = call.sendEnd()
        _ = end.always { res in
            switch res {
            case .success:
                print("Ended BD: Success")
            case .failure(let error):
                print("error \(error)")
            }
        }
    }

    func shutdown() throws {
        try group.syncShutdownGracefully()
    }
}
