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

protocol GRPCManagerProtocol {
    func addTwoNumbers(num: Int, num2: Int)
    func fibo(number: Int, completion: @escaping (Result<[Int64], Error>) -> Void)
    func fibo(number: Int) async throws -> [Int64]
    func findMaximum(numbers: Int...)
    func computeAverage(numbers: Int...)
    func shutdown() throws
    func connect(
        userID: String,
        userName: String,
        complection: @escaping (ChatMessage) -> Void
    )
    func sendMessage(message: String, userID: String)
}

final class GRPCManager: GRPCManagerProtocol {
    static let shared = GRPCManager()

    private let group: EventLoopGroup
    private let client: Calc_CalcClientProtocol
    private let chatClient: Chat_BroadcastClientProtocol

    private init(address: String = "127.0.0.1") {
        self.group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        let channel = ClientConnection(
            configuration: .default(
                target: ConnectionTarget.hostAndPort(address, 50051),
                eventLoopGroup: group
            )
        )
        client = Calc_CalcNIOClient(channel: channel)
        chatClient = Chat_BroadcastNIOClient(channel: channel)
    }

    func addTwoNumbers(num: Int, num2: Int) {
        var request = Calc_AddRequest()
        request.firstNumber = Int32(num)
        request.secondNumber = Int32(num2)
        let calloption = CallOptions(eventLoopPreference: .indifferent)
        let unaryCall = client.add(request, callOptions: calloption)
        do {
            let response = try unaryCall.response.wait()
            print("[DEBUG]: sum=\(response.sumResult)")
        } catch {
            print("[DEBUG]: failed: \(error)")
        }
    }

    func fibo(number: Int, completion: @escaping (Result<[Int64], Error>) -> Void) {
        var request = Calc_FiboRequest()
        request.num = Int64(number)

        var resultNumbers: [Int64] = []
        let call = client.fibo(request, callOptions: nil) { response in
            print("[DEBUG]: get streaming data: \(response.num)")
            resultNumbers.append(response.num)
        }

        call.status.whenSuccess { status in
            print("[DEBUG]: status: \(status.code)")
            completion(.success(resultNumbers))
        }

        call.status.whenFailure { error in
            completion(.failure(error))
        }
    }

    func findMaximum(numbers: Int...) {
        let call = client.findMaximum(callOptions: nil) { maxNumber in
            print("[DEBUG]: currentMax=\(maxNumber)")
        }

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

    func connect(
        userID: String,
        userName: String,
        complection: @escaping (ChatMessage) -> Void
    ) {
        var request = Chat_Connect()
        var user = Chat_User()
        user.id = userID
        user.name = userName
        request.user = user

        let call = chatClient.createStream(request, callOptions: nil) { message in
            let message = ChatMessage(
                id: UUID(),
                owner: message.id,
                message: message.content,
                time: message.timestamp.date
            )
            complection(message)
        }

        call.status.whenComplete { result in
            switch result {
            case let .success(status):
                print("[DEBUG]: success: \(status.code)")
            case let .failure(error):
                print("[DEBUG]: error: \(error)")
            }
        }
    }

    func sendMessage(message: String, userID: String) {
        var request = Chat_Message()
        request.content = message
        request.id = userID
        request.timestamp = Google_Protobuf_Timestamp()
        let call = chatClient.broadcastMessage(request, callOptions: nil)

        call.response.whenComplete { result in
            switch result {
            case let .success(status):
                print("[DEBUG]: success: \(status)")
            case let .failure(error):
                print("[DEBUG]: error: \(error)")
            }
        }
    }
}

// MARK: - Async Await

extension GRPCManager {

    func fibo(number: Int) async throws -> [Int64] {
        try await withCheckedThrowingContinuation { continuation in
            fibo(number: number) { result in
                switch result {
                case let.success(numbers):
                    continuation.resume(returning: numbers)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
