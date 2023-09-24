
//  Created by Nidhish Gajjar on 2023-06-08.
//

import Combine
import Foundation

class WebSocketService: ObservableObject {
    @Published var isConnected: Bool = false

    
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

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func connect() {
       guard let currentUserUID = authManager.currentUserUID else { return }

       let url = URL(string: "wss://scigic-neo-cortex.onrender.com/websocket/\(currentUserUID)")!
//       let url = URL(string: "ws://localhost:8000/websocket/12345")!
        
       webSocketTask = URLSession.shared.webSocketTask(with: url)
       webSocketTask?.resume()

       // Set isConnected to true.
       isConnected = true

       listen()
   }

    func listen() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket receive failed with error \(error)")
                DispatchQueue.main.async {
                    // Your UI updates or changes go here
                    self?.isConnected = false
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


    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        // Set isConnected to false.
        isConnected = false
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.isConnected = true // Connection successful
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.isConnected = false // Connection lost or closed
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
