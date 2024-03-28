
//  Created by Nidhish Gajjar on 2023-06-14.
//

import SwiftUI
import WebKit
import NaturalLanguage
import Foundation


class SlateManagerViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {

    struct Slate: Identifiable {
        let id: UUID
        let slateUUID: UUID
        let webView: WKWebView?
        let humanAGIRequest: String?
        var url: URL? {
            webView?.url
        }
        var currentUrl: URL?
        let initialUrl: URL?
        let timestamp: Date
        var lastUsedTimestamp: Date
        var isThinking: Bool
    }

    @Published var slates: [Slate] = []
    @Published var currentSlateIndex: Int = 0
    @Published var version: Int = 0
    
    var webSocketService: WebSocketService
//    var passwordManagerService: PasswordManagerService
    var commonContext: ContextViewModel
    var timeOnCurrentSlate: Date?
    var timer: Timer?
    var secondaryWebViews = [WKWebView: Bool]() // The Bool value indicates whether the WebView has been redirected to an OAuth provider
    let oauthProviders = ["accounts.google.com", "login.microsoftonline.com", /* any other providers */]
    var lastMagnification: CGFloat = 1.0

    init(context: ContextViewModel, webSocket: WebSocketService ) {
        self.commonContext = context
        self.webSocketService = webSocket
//        self.passwordManagerService = passwordManager
        super.init()
        let scigicClip = URL(string: "https://constitute.ai")!
        addNewSlate(url: scigicClip)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: NSApplication.willBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSApplication.willResignActiveNotification, object: nil)
        
        commonContext.onUpdateIsThinking = { [weak self] slateUUID, isThinking in
            self?.updateIsThinkingState(for: slateUUID, to: isThinking)
        }
    }
    
    @objc func appMovedToForeground() {
//        print("App moved to Foreground!")
        self.clearOldCacheItems()
    }

    @objc func appMovedToBackground() {
//        print("App moved to Background!")
        self.clearOldCacheItems()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func view(for url: URL) -> WKWebView {
        if let index = slates.firstIndex(where: { $0.url == url }), !isSlateOld(slates[index]) {
            return slates[index].webView ?? WKWebView() // Provide a default value
        }
        let webView = createWebView(for: url)
        webView.navigationDelegate = self
        return webView
    }
    
    
    func wordCount(_ s: String) -> Int {
        let words = s.split(whereSeparator: { !$0.isLetter })
        return words.count
    }
    
    

    func containsEntity(in text: String) -> Bool {
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass])
        tagger.string = text
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        
        var hasEntity = false

        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameTypeOrLexicalClass, options: options) { tag, range in
            if let tag = tag {
                switch tag {
                case .personalName, .placeName, .organizationName, .noun, .pronoun:
                    hasEntity = true
                    return false
                default:
                    break
                }
            }
            return true
        }

        return hasEntity
    }



    
    
    func sendWebSocketMessage(slateUUID: UUID, request: String, unstated: Bool) {
//        if !webSocketService.isConnected {
//            webSocketService.connect()
//        }
//
//        if unstated {
//            let mindRequest: [String: Any] = ["askText": request]
//            webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "unstatedAsk")
//        } else {
//            let mindRequest: [String: Any] = ["askText": request]
//            webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "ask")
//        }
        DispatchQueue.global(qos: .background).async {
            if !self.webSocketService.isConnected {
                self.webSocketService.connect()
            }

            if unstated {
                let mindRequest: [String: Any] = ["askText": request]
                self.webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "unstatedAsk")
            } else {
                let mindRequest: [String: Any] = ["askText": request]
                self.webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "ask")
            }
        }


    }


    
    func addNewSlate(url: URL? = nil, humanAGIRequest: String? = nil, unstated: Bool = true) {
        var webView: WKWebView? = nil
        var initialUrl: URL? = nil
        
        
        // Retrieve slates with humanAGIRequest and sort them by lastUsedTimestamp.
        var humanAGISlates = slates.filter { $0.humanAGIRequest != nil }.sorted { $0.lastUsedTimestamp > $1.lastUsedTimestamp }

        // Close all slates with humanAGIRequest except the last three.
        while humanAGISlates.count > 2 {
            let slateToClose = humanAGISlates.removeLast()
            // here add if task oriented slate or ongoing task on slate then archive the slate otherwise close it. when jumped to archive slate append that slate to slates array. and add view slate option inside jobs pop.
            closeSlate(with: slateToClose.slateUUID)
            
        }

        
        if commonContext.shouldMoveCurrentSlateToLast == true {
            moveCurrentSlateToLast(from: currentSlateIndex)
            commonContext.shouldMoveCurrentSlateToLast = false

        }
        commonContext.isAskViewActive = false

        if let url = url {
            webView = view(for: url)
            initialUrl = url
            
        // Check if URL is in clips
            if let clipIndex = commonContext.clips.firstIndex(where: { $0.url == url }) {
                  // If clip slateUUID is present
                if let existingSlateUUID = commonContext.clips[clipIndex].slateUUID {
                    // Jump to slate
                    jumpToSlate(with: existingSlateUUID)
                    return
                }
            }
        }

        let slateUUID = UUID()
        let slate = Slate(id: UUID(), slateUUID: slateUUID, webView: webView, humanAGIRequest: humanAGIRequest, currentUrl: initialUrl, initialUrl: initialUrl, timestamp: Date(), lastUsedTimestamp: Date(), isThinking: true)
        slates.append(slate)
        
        // If URL is in clips, update its slateUUID
        if let url = url, let clipIndex = commonContext.clips.firstIndex(where: { $0.url == url }) {
            commonContext.clips[clipIndex].slateUUID = slateUUID
        }
        
        
        currentSlateIndex = slates.count - 1
        
        // WebSocket message
//        if let request = humanAGIRequest, !request.isEmpty {
//                let count = wordCount(request)
//                let hasEntity = containsEntity(in: request)
//            
//                print(count)
//                print(hasEntity)
//                
//                if count < 5 && hasEntity && unstated {
////                    self.closeCurrentSlate()
//                    addPerlexitySlate(query: request)
//
//                } else {
//                    self.sendWebSocketMessage(slateUUID: slateUUID, request: request, unstated: unstated)
//                }
//        }
    }
    

    
    func addPerlexitySlate(query: String, searchEngine: String? = nil) {
        let trimmedText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty { return }
        
//        print(slates)
        
        
        let count = wordCount(trimmedText)
        let hasEntity = containsEntity(in: trimmedText)
    
        print(count)
        print(hasEntity)
        
        if count < 5 && hasEntity {
//            self.closeCurrentSlate()
            addGoogleSearchSlate(query: trimmedText)

        } else {
            
            // Check for an existing Google search slate using the currentUrl key
            if let existingGoogleSearchSlate = slates.first(where: { $0.currentUrl?.host == "www.perplexity.ai" && $0.currentUrl?.path == "/search" }) {
                
                // Replace the query for that slate's URL
                let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let newSearchURL = URL(string: "https://www.perplexity.ai/search?q=\(searchString)") {
                    existingGoogleSearchSlate.webView?.load(URLRequest(url: newSearchURL))
                }
                
                // Jump to that slate
                jumpToSlate(with: existingGoogleSearchSlate.slateUUID)
            } else {
                // If no existing Google search slate was found, then add a new slate as originally done
                let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let searchURL = URL(string: "https://www.perplexity.ai/search?q=\(searchString)")!
                addNewSlate(url: searchURL)
            }
        }
    }
    
    func addGoogleSearchSlate(query: String, searchEngine: String? = nil) {
        let trimmedText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty { return }
        
//        print(slates)

        // Check for an existing Google search slate using the currentUrl key
        if let existingGoogleSearchSlate = slates.first(where: { $0.currentUrl?.host == "www.google.com" && $0.currentUrl?.path == "/search" }) {
            
            // Replace the query for that slate's URL
            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let newSearchURL = URL(string: "https://www.google.com/search?q=\(searchString)") {
                existingGoogleSearchSlate.webView?.load(URLRequest(url: newSearchURL))
            }
            
            // Jump to that slate
            jumpToSlate(with: existingGoogleSearchSlate.slateUUID)
        } else {
            // If no existing Google search slate was found, then add a new slate as originally done
            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let searchURL = URL(string: "https://www.google.com/search?q=\(searchString)")!
            addNewSlate(url: searchURL)
        }
    }
    
    
//    func addPerlexitySlate(query: String, searchEngine: String? = nil) {
//        let trimmedText = query.trimmingCharacters(in: .whitespacesAndNewlines)
//        if trimmedText.isEmpty { return }
//
//        let count = wordCount(trimmedText)
//        let hasEntity = containsEntity(in: trimmedText)
//
//        if count < 5 && hasEntity {
////            self.closeCurrentSlate()
//            addGoogleSearchSlate(query: trimmedText)
//        } else {
//            processSearchSlate(trimmedText: trimmedText, host: "www.perplexity.ai", path: "/search", baseSearchURL: "https://www.perplexity.ai/search?q=")
//        }
//    }
//
//    func addGoogleSearchSlate(query: String, searchEngine: String? = nil) {
//        let trimmedText = query.trimmingCharacters(in: .whitespacesAndNewlines)
//        if trimmedText.isEmpty { return }
//
//        processSearchSlate(trimmedText: trimmedText, host: "www.google.com", path: "/search", baseSearchURL: "https://www.google.com/search?q=")
//    }
//
//    func processSearchSlate(trimmedText: String, host: String, path: String, baseSearchURL: String) {
//        if let existingSearchSlate = slates.first(where: { $0.currentUrl?.host == host && $0.currentUrl?.path == path }) {
//            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//            if let newSearchURL = URL(string: "\(baseSearchURL)\(searchString)") {
//                existingSearchSlate.webView?.load(URLRequest(url: newSearchURL))
//            }
//            jumpToSlate(with: existingSearchSlate.slateUUID)
//        } else {
//            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//            let searchURL = URL(string: "\(baseSearchURL)\(searchString)")!
//            addNewSlate(url: searchURL)
//        }
//    }



  
    func navSlateTimer() {
        timeOnCurrentSlate = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if let timeOnCurrentSlate = self.timeOnCurrentSlate, Date().timeIntervalSince(timeOnCurrentSlate) >= 3 {
                // Check if the current slate is the last slate
                if self.currentSlateIndex < self.slates.count - 1 {
                    updateLastUsedTimestamp(for: self.currentSlateIndex)
                    self.commonContext.shouldMoveCurrentSlateToLast = true
                }
            }
        }
    }
    
    func moveCurrentSlateToLast(from index: Int) {
        if commonContext.shouldMoveCurrentSlateToLast {
            let slateToMove = slates.remove(at: index)
            slates.append(slateToMove)
            commonContext.shouldMoveCurrentSlateToLast = false
            version += 1
        }
    }

    func jumpToSlate(with UUID: UUID) {
        if let slateIndex = slates.firstIndex(where: { $0.slateUUID == UUID }) {
            commonContext.shouldMoveCurrentSlateToLast = false
            commonContext.isAskViewActive = false
//            print("Jump to slate invoked")
            
//            withAnimation(.easeInOut) {
                currentSlateIndex = slateIndex
//            }
            
//             Newly added cause timer no initiated or may be initiated and then bool changes to false
            navSlateTimer()
        }
    }
    
    func updateLastUsedTimestamp(for index: Int) {
        if index < slates.count {
            slates[index].lastUsedTimestamp = Date() // Update the last used timestamp to the current time
        }
    }
    
    func updateIsThinkingState(for slateUUID: UUID, to state: Bool) {
        if let slateIndex = slates.firstIndex(where: { $0.slateUUID == slateUUID }) {
            slates[slateIndex].isThinking = state
        }
    }
    
    
    func goBack() {
        guard currentSlateIndex < slates.count else { return }
        if slates[currentSlateIndex].webView?.canGoBack ?? false {
            slates[currentSlateIndex].webView?.goBack()
            objectWillChange.send()
        }
    }

    func goForward() {
        guard currentSlateIndex < slates.count else { return }
        if slates[currentSlateIndex].webView?.canGoForward ?? false {
            slates[currentSlateIndex].webView?.goForward()
            objectWillChange.send()
        }
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Code to enable or disable navigation buttons based on the state of the WebView
        updateNavigationButtonsState(for: webView)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Code to enable or disable navigation buttons based on the state of the WebView
        updateNavigationButtonsState(for: webView)
    }

    private func updateNavigationButtonsState(for webView: WKWebView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
//            if let index = self.slates.firstIndex(where: { $0.webView == webView }) {
                self.objectWillChange.send() // Notify SwiftUI to update the view
//            }
        }
    }


    
    func reloadCurrentSlate() {
        if currentSlateIndex < slates.count {
            slates[currentSlateIndex].webView?.reload()
        }
    }

    
    func closeCurrentSlate() {
        if currentSlateIndex >= 0 && currentSlateIndex < slates.count {
            let uuid = slates[currentSlateIndex].slateUUID
//            withAnimation(.easeInOut) {
            if self.commonContext.shouldMoveCurrentSlateToLast == true {
                moveCurrentSlateToLast(from: currentSlateIndex)
                }
            closeSlate(with: uuid)
//            }
        }
    }

    
    private func createWebView(for url: URL) -> WKWebView {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
//        configuration.dataDetectorTypes = [.all]
        configuration.userContentController.add(self, name: "inputFieldInFocus")
        configuration.processPool = WKProcessPool()




        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.configuration.allowsAirPlayForMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        


        webView.uiDelegate = self

//        let magnify = NSMagnificationGestureRecognizer(target: self, action: #selector(magnifyWithGestureRecognizer(_:)))
//        webView.addGestureRecognizer(magnify)



        webView.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0))

        return webView
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = navigationResponse.response.url {
            let fileExtension = url.pathExtension
            if ["dmg", "zip", "pdf", "mp4", "mp3"].contains(fileExtension) {  // Add any other extensions you want to handle
                decisionHandler(.cancel)
                
                // Use URLSession to download
                downloadFileFromURL(url)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.begin { (result) in
            if result == .OK {
                completionHandler(openPanel.urls)
            } else {
                completionHandler(nil)
            }
        }
    }


//    func downloadFileFromURL(_ url: URL) {
//        let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
//            guard let location = location, error == nil else {
//                // Handle error
//                return
//            }
//
//            // Determine the directory and final location for the file
//            let directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
//            let destinationURL = directoryURL.appendingPathComponent(url.lastPathComponent)
//
//            // Move the file to the final location
//            do {
//                try FileManager.default.moveItem(at: location, to: destinationURL)
//                print("File moved to \(destinationURL)")
//
//                // Optionally, if you're on a macOS app, you can reveal the file in Finder:
//                NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
//            } catch {
//                print("Error moving the file: \(error)")
//            }
//        }
//        downloadTask.resume()
//    }

    
    func downloadFileFromURL(_ url: URL) {
        // Use NSOpenPanel to get the directory where the user wants to save the file
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false // We want to choose directories, not files
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.title = "Select a Directory"
        openPanel.prompt = "Select"
        openPanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

        openPanel.begin { (result) in
            if result == .OK, let directoryURL = openPanel.url {
                let destinationURL = directoryURL.appendingPathComponent(url.lastPathComponent)

                let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
                    guard let location = location, error == nil else {
                        // Handle error
                        return
                    }

                    // Move the file to the chosen directory
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                        print("File moved to \(destinationURL)")

                        // Reveal the file in Finder
                        NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
                    } catch {
                        print("Error moving the file: \(error)")
                    }
                }
                downloadTask.resume()
            } else {
                print("Directory selection was cancelled or failed")
            }
        }
    }






    





//    func isSlateOld(_ slate: Slate) -> Bool {
//        if slate.slateUUID == slates[currentSlateIndex].slateUUID {
//            return false
//        } else {
//            // Your current logic for determining if a slate is old
//            return Date().timeIntervalSince(slate.lastUsedTimestamp) > 6 * 60 * 60
//        }
//    }
    
    func isSlateOld(_ slate: Slate) -> Bool {
        // If the slate is the current one, it's not old
        if slate.slateUUID == slates[currentSlateIndex].slateUUID {
            return false
        }
        // Check if the slate is a humanAGISlate and if it's more than 5 minutes old
        else if let _ = slate.humanAGIRequest, Date().timeIntervalSince(slate.lastUsedTimestamp) > 3 * 60 {
            return true
        }
        
        // Check for any other slate if it's more than 6 hours old
        else {
            return Date().timeIntervalSince(slate.lastUsedTimestamp) > 6 * 60 * 60
        }
    }





    func closeSlate(with uuid: UUID) {
        if let index = slates.firstIndex(where: { $0.slateUUID == uuid }) {
            slates.remove(at: index)
            if currentSlateIndex > index {
                currentSlateIndex -= 1
            } else if !slates.isEmpty { // Check if there are other slates available
                currentSlateIndex = min(currentSlateIndex, slates.count - 1) // Ensure currentSlateIndex is not out of range
            } else {
                currentSlateIndex = -1 // Indicate that there are no more slates
            }
            
            // Add this block to check and update any clips with matching slateUUID
            for i in 0..<self.commonContext.clips.count {
                if self.commonContext.clips[i].slateUUID == uuid {
                    self.commonContext.clips[i].slateUUID = nil
                }
            }
        }
    }
    
    
    private func clearOldCacheItems() {
        for slate in slates.reversed() {

            if isSlateOld(slate) {
                closeSlate(with: slate.slateUUID)
            }
        }
    }

    
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
//            // Open in new slate
//            addNewSlate(url: url)
//            decisionHandler(.cancel)
//        } else {
//            decisionHandler(.allow)
//        }
//    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Handle links opening in new target (_blank, etc.)
        if navigationAction.targetFrame == nil {
            addNewSlate(url: url)
            decisionHandler(.cancel)
            return
        }

        // Upgrade to HTTPS if URL is HTTP
        if url.scheme == "http" {
            if let httpsURL = URL(string: url.absoluteString.replacingOccurrences(of: "http://", with: "https://")) {
                webView.load(URLRequest(url: httpsURL))
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                
                let subviewFrame = CGRect(x: 20, y: 20, width: webView.frame.width - 40, height: webView.frame.height - 80)
                
                let newWebView = WKWebView(frame: subviewFrame, configuration: configuration)
                newWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
                newWebView.navigationDelegate = self
                newWebView.wantsLayer = true
                newWebView.layer?.cornerRadius = 10
                newWebView.layer?.masksToBounds = true
                webView.addSubview(newWebView)
                newWebView.load(URLRequest(url: url))
                secondaryWebViews[newWebView] = false // Initially, the WebView hasn't been redirected to an OAuth provider

                
                let closeButton = NSButton(frame: CGRect(x: subviewFrame.width - 23, y: 3, width: 20, height: 20))
                if let closeImage = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil) {
                    closeButton.image = closeImage
                    closeButton.imageScaling = .scaleProportionallyUpOrDown
                    closeButton.contentTintColor = .white // Setting the image color to white
                }
                closeButton.bezelStyle = .rounded
                closeButton.isBordered = false
                closeButton.wantsLayer = true  // Make sure the button uses a CALayer
                closeButton.contentTintColor = .red  // Set the background color of the layer
                closeButton.layer?.cornerRadius = 10 // Half of the button's width/height to make it a circle
                closeButton.target = self
                closeButton.action = #selector(closeSubview(_:))
                newWebView.addSubview(closeButton)
                
                return newWebView
            }
        }
        return nil
    }

    @objc func closeSubview(_ sender: NSButton) {
        sender.superview?.removeFromSuperview()  // This will remove the newWebView
    }




    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let index = slates.firstIndex(where: { $0.webView == webView }) {
            
            var updateUrl = slates[index]
            
            updateUrl.currentUrl = webView.url // Update the newUrl
            
            
            slates[index] = Slate(id: slates[index].id, slateUUID: slates[index].slateUUID, webView: webView, humanAGIRequest: slates[index].humanAGIRequest, currentUrl: updateUrl.currentUrl, initialUrl: slates[index].initialUrl, timestamp: Date(), lastUsedTimestamp: Date(), isThinking: false)
            
//            if let url = webView.url, url.absoluteString.starts(with: "https://constitute.ai") {
//                handleAuthRedirectURL(url)
//            }
        } else if let isRedirected = secondaryWebViews[webView], let host = webView.url?.host {
            if isRedirected && !oauthProviders.contains(host) {
                // The WebView has been redirected to an OAuth provider, and now it's redirected again to a non-OAuth URL, so we remove it
                webView.removeFromSuperview()
                secondaryWebViews.removeValue(forKey: webView)
            } else if !isRedirected && oauthProviders.contains(host) {
                // The WebView hasn't been redirected to an OAuth provider yet, but now it's redirected to an OAuth URL, so we update its state
                secondaryWebViews[webView] = true
            }
        }
        
        let jsCode = """
            function isRelevantInputField(input) {
                return ['password', 'email', 'username'].includes(input.type);
            }

            // Check for already focused field
            let activeElement = document.activeElement;
            if (activeElement && activeElement.tagName.toLowerCase() === 'input' && isRelevantInputField(activeElement)) {
                window.webkit.messageHandlers.inputFieldInFocus.postMessage({ focus: true, fieldType: activeElement.type });
            }

            document.addEventListener('focusin', (event) => {
                if (event.target.tagName.toLowerCase() === 'input' && isRelevantInputField(event.target)) {
                    window.webkit.messageHandlers.inputFieldInFocus.postMessage({ focus: true, fieldType: event.target.type });
                }
            });

            document.addEventListener('focusout', (event) => {
                if (event.target.tagName.toLowerCase() === 'input' && isRelevantInputField(event.target)) {
                    window.webkit.messageHandlers.inputFieldInFocus.postMessage({ focus: false, fieldType: event.target.type });
                }
            });
        """

        webView.evaluateJavaScript(jsCode) { (result, error) in
            guard error == nil else {
                print("Error evaluating JavaScript: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
        }

        webView.evaluateJavaScript(jsCode) { (result, error) in
            guard error == nil else {
                print("Error evaluating JavaScript: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
        }

    }

}

extension SlateManagerViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "inputFieldInFocus" {
            if let body = message.body as? [String: Any], let focus = body["focus"] as? Bool {
                DispatchQueue.main.async {
                    self.commonContext.relevantAutofillInputs = focus
                    if focus {
                        let fieldType = body["fieldType"] as? String
                        print("Field \(fieldType ?? "unknown") has gained focus")
                    } else {
                        print("Field has lost focus")
                    }
                }
            }
        }
    }
}





protocol SlateManagerDelegate: AnyObject {
    func updateIsThinkingState(for slateUUID: UUID, to state: Bool)
}





//    func handleAuthRedirectURL(_ url: URL) {
//        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
//              let queryItems = urlComponents.queryItems,
//              let authCodeItem = queryItems.first(where: { $0.name == "code" }),
//              let authCode = authCodeItem.value else {
//            print("Failed to parse auth code")
//            return
//        }
//        if !webSocketService.isConnected {
//            webSocketService.connect()
//        }
//        // Now you have the authorization code
//        print("Auth code: \(authCode)")
//        let slateUUID = UUID()
//        let gmailAuthCode: [String: Any] = ["gmailAuthCode": authCode]
//        webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: gmailAuthCode, reqType: "gmailAuthCode")
//
//        // Send the authorization code to your server here
//    }




//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        if navigationAction.targetFrame == nil {
//            if let url = navigationAction.request.url {
//                let newWebView = WKWebView(frame: webView.frame, configuration: configuration)
//                newWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Safari/605.1.15"
//                newWebView.navigationDelegate = self
//                webView.addSubview(newWebView)
//                newWebView.load(URLRequest(url: url))
//                secondaryWebViews[newWebView] = false // Initially, the WebView hasn't been redirected to an OAuth provider
//
//                return newWebView
//            }
//        }
//        return nil
//    }
//




//class SlateManagerViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {
//
//    struct Slate: Identifiable {
//        let id: UUID
//        let slateUUID: UUID
//        let webView: WKWebView?
//        let humanAGIRequest: String?
//        var url: URL? {
//            webView?.url
//        }
//        var currentUrl: URL?
//        let initialUrl: URL?
//        let timestamp: Date
//        var lastUsedTimestamp: Date
//        var isThinking: Bool
//    }
//
//    @Published var slates: [Slate] = []
//    @Published var currentSlateIndex: Int = 0
//    @Published var version: Int = 0
//
//    var webSocketService: WebSocketService
////    var passwordManagerService: PasswordManagerService
//    var commonContext: ContextViewModel
//    var timeOnCurrentSlate: Date?
//    var timer: Timer?
//    var secondaryWebViews = [WKWebView: Bool]() // The Bool value indicates whether the WebView has been redirected to an OAuth provider
//    let oauthProviders = ["accounts.google.com", "login.microsoftonline.com", /* any other providers */]
//    var lastMagnification: CGFloat = 1.0
//
//    init(context: ContextViewModel, webSocket: WebSocketService ) {
//        self.commonContext = context
//        self.webSocketService = webSocket
////        self.passwordManagerService = passwordManager
//        super.init()
//        let scigicClip = URL(string: "https://scigic.com")!
//        addNewSlate(url: scigicClip)
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: NSApplication.willBecomeActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSApplication.willResignActiveNotification, object: nil)
//
//        commonContext.onUpdateIsThinking = { [weak self] slateUUID, isThinking in
//            self?.updateIsThinkingState(for: slateUUID, to: isThinking)
//        }
//    }
//
//    @objc func appMovedToForeground() {
////        print("App moved to Foreground!")
//        self.clearOldCacheItems()
//    }
//
//    @objc func appMovedToBackground() {
////        print("App moved to Background!")
//        self.clearOldCacheItems()
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    func view(for url: URL) -> WKWebView {
//        if let index = slates.firstIndex(where: { $0.url == url }), !isSlateOld(slates[index]) {
//            return slates[index].webView ?? WKWebView() // Provide a default value
//        }
//        let webView = createWebView(for: url)
//        webView.navigationDelegate = self
//        return webView
//    }
//
//
//    func sendWebSocketMessage(slateUUID: UUID, request: String, unstated: Bool) {
//        if !webSocketService.isConnected {
//            webSocketService.connect()
//        }
//
//        print("invoked slate")
//
//        if unstated {
//            let mindRequest: [String: Any] = ["askText": request]
//            webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "unstatedAsk")
//        } else {
//            let mindRequest: [String: Any] = ["askText": request]
//            webSocketService.send(slateUUID: slateUUID.uuidString, mindRequest: mindRequest, reqType: "ask")
//        }
//    }
//
//
//
//    func addNewSlate(url: URL? = nil, humanAGIRequest: String? = nil, unstated: Bool = true) {
//        var webView: WKWebView? = nil
//        var initialUrl: URL? = nil
//
//
//        // Retrieve slates with humanAGIRequest and sort them by lastUsedTimestamp.
//        var humanAGISlates = slates.filter { $0.humanAGIRequest != nil }.sorted { $0.lastUsedTimestamp > $1.lastUsedTimestamp }
//
//        // Close all slates with humanAGIRequest except the last three.
//        while humanAGISlates.count > 2 {
//            let slateToClose = humanAGISlates.removeLast()
//            // here add if task oriented slate or ongoing task on slate then archive the slate otherwise close it. when jumped to archive slate append that slate to slates array. and add view slate option inside jobs pop.
//            closeSlate(with: slateToClose.slateUUID)
//
//        }
//
//
//        if commonContext.shouldMoveCurrentSlateToLast == true {
//            moveCurrentSlateToLast(from: currentSlateIndex)
//            commonContext.shouldMoveCurrentSlateToLast = false
//
//        }
//        commonContext.isAskViewActive = false
//
//        let slateUUID = UUID()
//        let slate = Slate(id: UUID(), slateUUID: slateUUID, webView: webView, humanAGIRequest: humanAGIRequest, currentUrl: initialUrl, initialUrl: initialUrl, timestamp: Date(), lastUsedTimestamp: Date(), isThinking: true)
//        slates.append(slate)
//
//        // If URL is in clips, update its slateUUID
//        if let url = url, let clipIndex = commonContext.clips.firstIndex(where: { $0.url == url }) {
//            commonContext.clips[clipIndex].slateUUID = slateUUID
//        }
//
//
//        currentSlateIndex = slates.count - 1
//
//        // WebSocket message
//        if let request = humanAGIRequest, !request.isEmpty {
//            self.sendWebSocketMessage(slateUUID: slateUUID, request: request, unstated: unstated)
//        }
//    }
//
//
//
//    func navSlateTimer() {
//        timeOnCurrentSlate = Date()
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
//            guard let self = self else { return }
//            if let timeOnCurrentSlate = self.timeOnCurrentSlate, Date().timeIntervalSince(timeOnCurrentSlate) >= 3 {
//                // Check if the current slate is the last slate
//                if self.currentSlateIndex < self.slates.count - 1 {
//                    updateLastUsedTimestamp(for: self.currentSlateIndex)
//                    self.commonContext.shouldMoveCurrentSlateToLast = true
//                }
//            }
//        }
//    }
//
//    func moveCurrentSlateToLast(from index: Int) {
//        if commonContext.shouldMoveCurrentSlateToLast {
//            let slateToMove = slates.remove(at: index)
//            slates.append(slateToMove)
//            commonContext.shouldMoveCurrentSlateToLast = false
//            version += 1
//        }
//    }
//
//    func jumpToSlate(with UUID: UUID) {
//        if let slateIndex = slates.firstIndex(where: { $0.slateUUID == UUID }) {
//            commonContext.shouldMoveCurrentSlateToLast = false
//            commonContext.isAskViewActive = false
//
//            withAnimation(.easeInOut) {
//                currentSlateIndex = slateIndex
//            }
//
//            navSlateTimer()
//        }
//    }
//
//    func updateLastUsedTimestamp(for index: Int) {
//        if index < slates.count {
//            slates[index].lastUsedTimestamp = Date() // Update the last used timestamp to the current time
//        }
//    }
//
//    func updateIsThinkingState(for slateUUID: UUID, to state: Bool) {
//        if let slateIndex = slates.firstIndex(where: { $0.slateUUID == slateUUID }) {
//            slates[slateIndex].isThinking = state
//        }
//    }
//
//
//    func goBack() {
//        guard currentSlateIndex < slates.count else { return }
//        if slates[currentSlateIndex].webView?.canGoBack ?? false {
//            slates[currentSlateIndex].webView?.goBack()
//            objectWillChange.send()
//        }
//    }
//
//    func goForward() {
//        guard currentSlateIndex < slates.count else { return }
//        if slates[currentSlateIndex].webView?.canGoForward ?? false {
//            slates[currentSlateIndex].webView?.goForward()
//            objectWillChange.send()
//        }
//    }
//
//
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        // Code to enable or disable navigation buttons based on the state of the WebView
//        updateNavigationButtonsState(for: webView)
//    }
//
//    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        // Code to enable or disable navigation buttons based on the state of the WebView
//        updateNavigationButtonsState(for: webView)
//    }
//
//    private func updateNavigationButtonsState(for webView: WKWebView) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//
//                self.objectWillChange.send() // Notify SwiftUI to update the view
//        }
//    }
//
//
//    func closeCurrentSlate() {
//        if currentSlateIndex >= 0 && currentSlateIndex < slates.count {
//            let uuid = slates[currentSlateIndex].slateUUID
////            withAnimation(.easeInOut) {
//            if self.commonContext.shouldMoveCurrentSlateToLast == true {
//                moveCurrentSlateToLast(from: currentSlateIndex)
//                }
//            closeSlate(with: uuid)
////            }
//        }
//    }
//
//
//    private func createWebView(for url: URL) -> WKWebView {
//        let preferences = WKPreferences()
//        let configuration = WKWebViewConfiguration()
//        configuration.preferences = preferences
//
//
//
//        let webView = WKWebView(frame: .zero, configuration: configuration)
//        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
//        webView.allowsBackForwardNavigationGestures = true
//        webView.allowsLinkPreview = true
//        webView.configuration.allowsAirPlayForMediaPlayback = true
//
//        webView.uiDelegate = self
//
//
//
//        webView.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0))
//
//        return webView
//    }
//
//
//    func isSlateOld(_ slate: Slate) -> Bool {
//        // If the slate is the current one, it's not old
//        if slate.slateUUID == slates[currentSlateIndex].slateUUID {
//            return false
//        }
//        // Check if the slate is a humanAGISlate and if it's more than 5 minutes old
//        else if let _ = slate.humanAGIRequest, Date().timeIntervalSince(slate.lastUsedTimestamp) > 3 * 60 {
//            return true
//        }
//        // Check for any other slate if it's more than 6 hours old
//        else {
//            return Date().timeIntervalSince(slate.lastUsedTimestamp) > 6 * 60 * 60
//        }
//    }
//
//
//
//
//
//    func closeSlate(with uuid: UUID) {
//        if let index = slates.firstIndex(where: { $0.slateUUID == uuid }) {
//            slates.remove(at: index)
//            if currentSlateIndex > index {
//                currentSlateIndex -= 1
//            } else if !slates.isEmpty { // Check if there are other slates available
//                currentSlateIndex = min(currentSlateIndex, slates.count - 1) // Ensure currentSlateIndex is not out of range
//            } else {
//                currentSlateIndex = -1 // Indicate that there are no more slates
//            }
//
//            // Add this block to check and update any clips with matching slateUUID
//            for i in 0..<self.commonContext.clips.count {
//                if self.commonContext.clips[i].slateUUID == uuid {
//                    self.commonContext.clips[i].slateUUID = nil
//                }
//            }
//        }
//    }
//
//
//    private func clearOldCacheItems() {
//        for slate in slates.reversed() {
//
//            if isSlateOld(slate) {
//                closeSlate(with: slate.slateUUID)
//            }
//        }
//    }
//
//
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        guard let url = navigationAction.request.url else {
//            decisionHandler(.allow)
//            return
//        }
//
//        // Handle links opening in new target (_blank, etc.)
//        if navigationAction.targetFrame == nil {
//            addNewSlate(url: url)
//            decisionHandler(.cancel)
//            return
//        }
//
//        decisionHandler(.allow)
//    }
//
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        if navigationAction.targetFrame == nil {
//            if let url = navigationAction.request.url {
//
//                let subviewFrame = CGRect(x: 20, y: 20, width: webView.frame.width - 40, height: webView.frame.height - 80)
//
//                let newWebView = WKWebView(frame: subviewFrame, configuration: configuration)
//                newWebView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
//                newWebView.navigationDelegate = self
//                newWebView.wantsLayer = true
//                newWebView.layer?.cornerRadius = 10
//                newWebView.layer?.masksToBounds = true
//                webView.addSubview(newWebView)
//                newWebView.load(URLRequest(url: url))
//                secondaryWebViews[newWebView] = false // Initially, the WebView hasn't been redirected to an OAuth provider
//
//
//                let closeButton = NSButton(frame: CGRect(x: subviewFrame.width - 23, y: 3, width: 20, height: 20))
//                if let closeImage = NSImage(systemSymbolName: "xmark.circle.fill", accessibilityDescription: nil) {
//                    closeButton.image = closeImage
//                    closeButton.imageScaling = .scaleProportionallyUpOrDown
//                    closeButton.contentTintColor = .white // Setting the image color to white
//                }
//                closeButton.bezelStyle = .rounded
//                closeButton.isBordered = false
//                closeButton.wantsLayer = true  // Make sure the button uses a CALayer
//                closeButton.contentTintColor = .red  // Set the background color of the layer
//                closeButton.layer?.cornerRadius = 10 // Half of the button's width/height to make it a circle
//                closeButton.target = self
//                closeButton.action = #selector(closeSubview(_:))
//                newWebView.addSubview(closeButton)
//
//                return newWebView
//            }
//        }
//        return nil
//    }
//
//    @objc func closeSubview(_ sender: NSButton) {
//        sender.superview?.removeFromSuperview()  // This will remove the newWebView
//    }
//
//
//
//
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        if let index = slates.firstIndex(where: { $0.webView == webView }) {
//
//            var updateUrl = slates[index]
//
//            updateUrl.currentUrl = webView.url // Update the newUrl
//
//
//            slates[index] = Slate(id: slates[index].id, slateUUID: slates[index].slateUUID, webView: webView, humanAGIRequest: slates[index].humanAGIRequest, currentUrl: updateUrl.currentUrl, initialUrl: slates[index].initialUrl, timestamp: Date(), lastUsedTimestamp: Date(), isThinking: false)
//
////            if let url = webView.url, url.absoluteString.starts(with: "https://constitute.ai") {
////                handleAuthRedirectURL(url)
////            }
//        } else if let isRedirected = secondaryWebViews[webView], let host = webView.url?.host {
//            if isRedirected && !oauthProviders.contains(host) {
//                // The WebView has been redirected to an OAuth provider, and now it's redirected again to a non-OAuth URL, so we remove it
//                webView.removeFromSuperview()
//                secondaryWebViews.removeValue(forKey: webView)
//            } else if !isRedirected && oauthProviders.contains(host) {
//                // The WebView hasn't been redirected to an OAuth provider yet, but now it's redirected to an OAuth URL, so we update its state
//                secondaryWebViews[webView] = true
//            }
//        }
//
//    }
//
//}
