//
//  SocketManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/25/24.
//

import Foundation
import ComposableArchitecture
import SocketIO

enum ChatSocketManagerError: Error {
    case nilSocat
    case weakError
    case JSONDecodeError
    
    var message: String {
        switch self {
        case .nilSocat:
            return "인터넷 환경을 확인해 주세요"
        case .weakError:
            return "치명적이 에러가 발생했습니다."
        case .JSONDecodeError:
            return "모델을 불러오는중 문제가 발생 했어요!"
        }
    }
}

final class WSXSocketManager {
    
    enum SocketCase {
        case channelChat(channelID: String)
        
        var address: String {
            let base = APIKey.baseURL + APIKey.version
            switch self {
            case .channelChat(let channelID):
                return "\(base)/ws-channel-\(channelID)"
            }
        }
    }
    /// 소켓 해제를 각별히 유의해 주시길 바랍니다. 1. 방나갈때 2. 백그라운드
    static let shared = WSXSocketManager()
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    private init() {}
    
    /// 연결 메서드 입니다. 시작 메서드와 스탑 메서드는 분리 되어있어
    func connect<T: DTO>(to socketCase: SocketCase, type: T.Type) -> AsyncStream<Result<T,ChatSocketManagerError>> {
        
        guard let url = URL(string: socketCase.address) else {
            return AsyncStream { continuation in
                continuation.finish()
            }
        }
        
        let config : SocketIOClientConfiguration = [
            .log(true), // 로그
            .compress, // 압축
            .reconnects(true),
            .reconnectWait(10),
            .reconnectAttempts(-1), // 무한 재연결
            .forceNew(true) // 새로운것이 있을시 예전것 삭제
        ]
        manager = SocketManager(socketURL: url, config: config)
        
        socket = manager?.defaultSocket
        
        return AsyncStream { contin in
            socket?.on(clientEvent: .connect) { data, ack in
                print("소켓 시작 되었습니다.")
                print("\(data) - \(ack)")
            }
            socket?.on(clientEvent: .disconnect) { data, ack in
                print("소켓이 정지 됩니다.")
                print("\(data) - \(ack)")
            }
            
            socket?.on(clientEvent: .error) { data, ack in
                print("소켓에 문제가 발생합니다.")
                contin.yield(.failure(.weakError))
                contin.finish()
            }
            
            socket?.once("channel") { [weak self] dataArray, ack in
                guard let self else {
                    contin.yield(.failure(.weakError))
                    self?.stopAndRemoveSocket()
                    contin.finish()
                    return
                }
                do {
                    if let datafirst = dataArray.first {
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: datafirst, options: [])
                        
                        let dto = try WSXCoder.shared.jsonDecoding(model: T.self, from: jsonData)
                        
                        contin.yield(.success(dto))
                        
                    } else {
                        contin.yield(.failure(.JSONDecodeError))
                        self.stopAndRemoveSocket()
                        contin.finish()
                    }
                } catch {
                    contin.yield(.failure(.weakError))
                    self.stopAndRemoveSocket()
                    contin.finish()
                }
            }
            
            socket?.connect()
            
            contin.onTermination = { @Sendable _ in
                self.stopSocket()
            }
        }
        
    }
    
    func startSocket() {
        socket?.connect()
    }
    
    func stopAndRemoveSocket() {
        stopSocket()
        removeSocket()
    }
    
    func stopSocket() {
        socket?.disconnect()
    }
    
    func removeSocket() {
        if let socket {
            manager?.removeSocket(socket)
        }
        socket = nil
    }
}
/// 고민해야 할 부분
//extension WSXSocketManager: DependencyKey {
//    static var liveValue: WSXSocketManager = WSXSocketManager.shared
//}
//
//extension DependencyValues {
//    var socketManager: WSXSocketManager {
//        get { self[WSXSocketManager.self] }
//        set { self[WSXSocketManager.self] = newValue }
//    }
//}
