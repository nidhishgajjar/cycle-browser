
//  Created by Nidhish Gajjar on 2023-06-08.
//

import Combine
import Foundation

class WebSocketService: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var hasActiveSubscription: Bool = false
    private var subscriptionCheckTimer: Timer?
    private var pongReceived: Bool = true

    
    // Define a Message struct to hold the content and type of each message.
    struct Message {
        let id: String
        let slateUUID: String
        let mindResponse: [String: Any]
        let respType: String
    }

    // Define a PassthroughSubject that emits Messages.
    let messagePublisher = PassthroughSubject<Message, Never>()

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var authManager: AuthManager
    private var healthCheckTimer: Timer?

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func connect() {
//       guard let currentUserUID = authManager.currentUserUID else { return }
//
//       let url = URL(string: "wss://scigic-neo-cortex.onrender.com/websocket/\(currentUserUID)")!
//       let url = URL(string: "ws://localhost:8000/websocket/12345")!
        
//       webSocketTask = URLSession.shared.webSocketTask(with: url)
//       webSocketTask?.resume()

        // Set isConnected to true.
       DispatchQueue.main.async {
          guard let currentUserUID = self.authManager.currentUserUID else { return }
          let url = URL(string: "wss://scigic-neo-cortex.onrender.com/websocket/\(currentUserUID)")!

          self.webSocketTask = URLSession.shared.webSocketTask(with: url)
          self.webSocketTask?.resume()
          self.isConnected = true
          self.listen()
          self.startHealthCheckTimer()
       }
        
   }

    func listen() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket receive failed with error \(error)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                    // Try to reconnect after a delay
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        self?.connect()
                    }
                }

                
            case .success(let message):
                switch message {
                case .string(let text):
                    // Assuming the text is a JSON string, parse it into a dictionary.
                    let data = Data(text.utf8)
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                       let dict = jsonObject as? [String: Any],
                       let id = dict["id"] as? String,
                       let slateUUID = dict["slateUUID"] as? String,
                       let mindResponse = dict["mindResponse"] as? [String: Any],
                       let respType = dict["respType"] as? String {
                        // Create a new Message and publish it.
                        let message = Message(id: id, slateUUID: slateUUID, mindResponse: mindResponse, respType: respType)
                        DispatchQueue.main.async { // Make sure to publish on the main thread
                            self?.messagePublisher.send(message)
                        }
                    }
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError("Unknown message type")
                }

                self?.listen()
            }
        })
    }
    
    
    func startHealthCheckTimer() {
        healthCheckTimer?.invalidate()
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            self?.checkHealthEndpoint()
        }
    }

    
    private func checkHealthEndpoint() {
        let url = URL(string: "https://scigic-neo-cortex.onrender.com/health")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Failed to hit health endpoint: \(error)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                    // Try to reconnect after a delay
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                        self?.connect()
                    }
                }
            }
        }
        task.resume()
    }
    
    
    func checkSubscriptionStatus() {
        guard let clientId = authManager.currentUserUID else { return }
         let url = URL(string: "https://scigic-neo-cortex.onrender.com/account/subscription/\(clientId)")!
//        let url = URL(string: "http://localhost:8000/account/subscription/46789")!
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Failed to check subscription status: \(error)")
                return
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                let isActive = (responseString == "true")
                DispatchQueue.main.async {
                    self?.hasActiveSubscription = isActive
                }
            }
        }
        task.resume()
    }

    
    
    func startSubscriptionCheckTimer() {
          subscriptionCheckTimer?.invalidate()
          subscriptionCheckTimer = Timer.scheduledTimer(withTimeInterval: 86400.0, repeats: true) { [weak self] _ in
              self?.checkSubscriptionStatus()
          }
      }





    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        DispatchQueue.main.async {
            self.isConnected = false
            self.healthCheckTimer?.invalidate()
        }

    }
    
    
    
    func send(slateUUID: String, mindRequest: [String: Any], reqType: String) {
        let messageDict: [String: Any] = ["slateUUID": slateUUID, "reqType": reqType]
        var finalMessageDict = messageDict
        finalMessageDict["mindRequest"] = mindRequest

        if let data = try? JSONSerialization.data(withJSONObject: finalMessageDict, options: []),
           let text = String(data: data, encoding: .utf8) {
            let message = URLSessionWebSocketTask.Message.string(text)
            webSocketTask?.send(message, completionHandler: { error in
                if let error = error {
                    print("WebSocket failed to send message with error \(error)")
                }
            })
        }
    }
} 
