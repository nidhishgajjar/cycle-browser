
//  Created by Nidhish Gajjar on 2023-06-10.
//
import Foundation
import Combine
import SwiftUI
import Markdown


struct IdentifiableParserResult: Identifiable {
    let id = UUID()
    let parserResult: ParserResult
}


class Job: ObservableObject, Identifiable {
    @Published var slateUUID: UUID
    @Published var userInput: String
    @Published var progress: Double {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var isCompleted: Bool {
        willSet {
            objectWillChange.send()
        }
    }

    init(slateUUID: UUID, userInput: String, progress: Double, isCompleted: Bool) {
        self.slateUUID = slateUUID
        self.userInput = userInput
        self.progress = progress
        self.isCompleted = isCompleted
    }
}

class Interface: ObservableObject, Identifiable {
    @Published var slateUUID: UUID
    @Published var showInstinctsView = true
    @Published var showKnowledgeGapView = false
    @Published var showHumanApprovalView = false
    @Published var showDeduceView = false

    init(slateUUID: UUID) {
        self.slateUUID = slateUUID
    }
}

class Outcome: ObservableObject, Identifiable {
    @Published var slateUUID: UUID
    @Published var status: String
    @Published var type: String?
    @Published var content: String?
    @Published var url: String?
    
    init(slateUUID: UUID, status: String, type: String?, content: String?, url: String?) {
        self.slateUUID = slateUUID
        self.status = status
        self.type = type
        self.content = content
        self.url = url
    }
}

class Approval: ObservableObject, Identifiable {
    @Published var slateUUID: UUID
    @Published var approvalID: String
    @Published var toolID: Int
    @Published var toolName: String
    @Published var toolAction: String
    @Published var inputParams: [String: Any]
    
    init(slateUUID: UUID, approvalID: String, toolID: Int, toolName: String, toolAction: String, inputParams: [String: Any]) {
        self.slateUUID = slateUUID
        self.approvalID = approvalID
        self.toolID = toolID
        self.toolName = toolName
        self.toolAction = toolAction
        self.inputParams = inputParams
    }
}




class ContextViewModel: ObservableObject {
//  AskView States
    @Published var askText: String = ""
    @Published var suggestedAskText: String = ""
    @Published var askTextFromPalette = ""
    @Published var isAskViewActive: Bool = true
    @Published var askBarFocusedOnAGI: Bool = false
    @Published var currentSlateURL: URL?
    @Published var currentSlateHumanAGIRequest: String?
    @Published var hoverAutoSuggestState: Bool = false
    @Published var arrowKeyForNavSuggestions: Bool = false
    @Published var typingInAskBar: Bool = false
    


    
//  PopViewStates
    @Published var isPopVisible: Bool = false
    @Published var isJobsPopActive: Bool = false
    @Published var isNotificationsPopActive: Bool = false
    @Published var isHistoryPopActive: Bool = false
    
//  SlateView States
    @Published var currentSlate: Bool = false
    @Published var shouldMoveCurrentSlateToLast = false
    @Published var relevantAutofillInputs: Bool = false
    
    
//  ChooseTypeOfSlate States
    @Published var interfaces: [UUID: Interface] = [:]
    
    
//  AGIDeduceView States
    @Published var approval: [Approval] = []
    
    
//  AGIDeduceView States
    @Published var outcomes: [Outcome] = []

    
//  ClipView States
    struct Clip {
        let name: String
        let url: URL
        let icon: NSImage? // or UIImage in iOS
        var slateUUID: UUID?
    }
    
    @Published var clips = [
        Clip(name: "ChatGPT", url: URL(string: "https://chat.openai.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Github", url: URL(string: "https://github.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Twitter", url: URL(string: "https://twitter.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Figma", url: URL(string: "https://figma.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Pinterest", url: URL(string: "https://pinterest.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Youtube", url: URL(string: "https://youtube.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Docs", url: URL(string: "https://docs.google.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Slack", url: URL(string: "https://slack.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Notion", url: URL(string: "https://notion.com")!, icon: nil, slateUUID: nil),
        Clip(name: "Gmail", url: URL(string: "https://mail.google.com")!, icon: nil, slateUUID: nil),
    ]
    
//  AGIInstinctSlateView State and func
    @Published var instinctRespChunkDict: [String: [String]] = [:]
    @Published var parserResultDict: [String: [ParserResult]] = [:]
    @Published var currentSearchEngine: String?
    @Published var currentQuery: String?
    @Published var isBeating = false

    
    func parseChunks(slateUUID: String) {
        let chunks = self.chunks(for: slateUUID)
        let allText = chunks.joined()

        let document = Document(parsing: allText)
        var parser = MarkdownAttributedStringParser()
        self.parserResultDict[slateUUID] = parser.parserResults(from: document)
    }

    
    func appendChunk(slateUUID: String, chunk: String) {
        if instinctRespChunkDict[slateUUID] == nil {
            instinctRespChunkDict[slateUUID] = [chunk]
        } else {
            instinctRespChunkDict[slateUUID]?.append(chunk)
        }
    }

    func chunks(for slateUUID: String) -> [String] {
        return instinctRespChunkDict[slateUUID] ?? []
    }
    
//  Jobs States and funcs
    @Published var jobs: [Job] = []
    @Published var NewJobCreated: Bool = false
    
    func removeJob(slateUUID: UUID) {
        if let index = jobs.firstIndex(where: { $0.slateUUID == slateUUID }) {
            jobs.remove(at: index)
        }
    }

    func removeAllCompletedJobs() {
          jobs.removeAll(where: { $0.isCompleted })
    }

    
//  Mind Response distribution system
    var onUpdateIsThinking: ((UUID, Bool) -> Void)? 
    
    var webSocketService: WebSocketService
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
        
        // Start listening for messages as soon as this object is created
        webSocketService.messagePublisher.sink { [weak self] message in
            self?.handleMessage(message)
        }.store(in: &cancellables)
    }
    
    private func handleMessage(_ message: WebSocketService.Message) {
        guard let slateUUID = UUID(uuidString: message.slateUUID) else {
            return
        }
        
        // Retrieve the corresponding Interface object or create a new one if it doesn't exist
        let interface = interfaces[slateUUID] ?? Interface(slateUUID: slateUUID)
        
        
        // Based on the message type, show the appropriate view
        switch message.respType {
            
        case "instinct":
            onUpdateIsThinking?(UUID(uuidString: message.slateUUID)!, false)
            if let mindResponse = message.mindResponse["chunk"] as? String {
                appendChunk(slateUUID: message.slateUUID, chunk: mindResponse)
            }
            
        case "websearch":
            if let searchEngine = message.mindResponse["searchengine"] as? String,
               let query = message.mindResponse["query"] as? String {
                onUpdateIsThinking?(UUID(uuidString: message.slateUUID)!, false)
                currentSearchEngine = searchEngine
                currentQuery = query
                
            }
            
        case "introspection":
            if let userInput = message.mindResponse["userInput"] as? String,
               jobs.firstIndex(where: { $0.slateUUID == slateUUID }) == nil {
                let newJob = Job(slateUUID: slateUUID, userInput: userInput, progress: 0, isCompleted: false)
                jobs.append(newJob)
                self.NewJobCreated = true
            }
            
        case "knowledege-gap":
            interface.showHumanApprovalView = false
            interface.showInstinctsView = false
            interface.showDeduceView = false
            interface.showKnowledgeGapView = true
            
        case "human-approval":
            
            if let approvalID = message.mindResponse["approvalID"] as? String,
               let toolID = message.mindResponse["toolID"] as? Int,
               let toolName = message.mindResponse["toolName"] as? String,
               let toolAction = message.mindResponse["toolAction"] as? String,
               let inputParams = message.mindResponse["inputParams"] as? [String: Any],
               approval.firstIndex(where: {$0.slateUUID == slateUUID}) == nil {
                interface.showInstinctsView = false
                interface.showKnowledgeGapView = false
                interface.showDeduceView = false
                interface.showHumanApprovalView = true
        

                let newApprovalRequest = Approval(slateUUID: slateUUID, approvalID: approvalID, toolID: toolID, toolName: toolName, toolAction: toolAction, inputParams: inputParams)
                approval.append(newApprovalRequest)
            }

            
            
        case "deduce":
            if let conclusion = message.mindResponse["conclusion"] as? String, conclusion == "success",
               outcomes.firstIndex(where: {$0.slateUUID == slateUUID}) == nil {
                interface.showInstinctsView = false
                interface.showKnowledgeGapView = false
                interface.showHumanApprovalView = false
                interface.showDeduceView = true
                
                var type: String? = nil
                var content: String? = nil
                var url: String? = nil
                if let mindResponseResult = message.mindResponse["result"] as? [String], mindResponseResult.count >= 2 {
                    type = mindResponseResult[0]
                    content = mindResponseResult[1]
                    // The following lines depend on how you want to use the title and content.
                    // Here, we assume you have methods in your `Interface` class to set the title and content.
                }
                if let urlString = message.mindResponse["interface"] as? String{
                    url = urlString
                }
                let newOutcome = Outcome(slateUUID: slateUUID, status: "success", type: type, content: content, url: url)
                outcomes.append(newOutcome)
            }


        case "task-progress":
            if let progress = message.mindResponse["progress"] as? Double,
               let jobIndex = jobs.firstIndex(where: { $0.slateUUID == slateUUID }) {
                // Create a copy of the job and modify the progress
                let updatedJob = jobs[jobIndex]
                updatedJob.progress = progress
                if progress >= 100 {
                    updatedJob.isCompleted = true
                    interface.showDeduceView = false
                    interface.showInstinctsView = false
                    interface.showKnowledgeGapView = false
                    interface.showHumanApprovalView = false
                }
                // Replace the job at the same index with the updated job
                var updatedJobs = jobs
                updatedJobs[jobIndex] = updatedJob
                // Replace the entire array
                jobs = updatedJobs
            }
        default:
            break
        }
        
        // Save the updated Interface object
        interfaces[slateUUID] = interface
    }

}
