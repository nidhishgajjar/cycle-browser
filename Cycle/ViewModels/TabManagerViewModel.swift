
//  Created by Nidhish Gajjar on 2023-06-14.
//

import SwiftUI
import WebKit
import NaturalLanguage
import Foundation


class TabManagerViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate {

    struct Tab: Identifiable {
        let id: UUID
        let tabUUID: UUID
        let webView: WKWebView?
        var url: URL? {
            webView?.url
        }
        var currentUrl: URL?
        let initialUrl: URL?
        let timestamp: Date
        var lastUsedTimestamp: Date
        var isThinking: Bool
    }

    @Published var tabs: [Tab] = []
    @Published var currentTabIndex: Int = 0
    @Published var version: Int = 0
    
    var commonContext: ContextViewModel
    var timeOnCurrentTab: Date?
    var timer: Timer?
    var secondaryWebViews = [WKWebView: Bool]() // The Bool value indicates whether the WebView has been redirected to an OAuth provider
    let oauthProviders = ["accounts.google.com", "login.microsoftonline.com", /* any other providers */]
    var lastMagnification: CGFloat = 1.0

    init(context: ContextViewModel) {
        self.commonContext = context
//        self.webSocketService = webSocket
//        self.passwordManagerService = passwordManager
        super.init()
        let scigicClip = URL(string: "https://constitute.ai")!
        addNewTab(url: scigicClip)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: NSApplication.willBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: NSApplication.willResignActiveNotification, object: nil)
        
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
        if let index = tabs.firstIndex(where: { $0.url == url }), !isTabOld(tabs[index]) {
            return tabs[index].webView ?? WKWebView() // Provide a default value
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





    
    func addNewTab(url: URL? = nil) {
        var webView: WKWebView? = nil
        var initialUrl: URL? = nil

        
        if commonContext.shouldMoveCurrentTabToLast == true {
            moveCurrentTabToLast(from: currentTabIndex)
            commonContext.shouldMoveCurrentTabToLast = false

        }
        commonContext.isAskViewActive = false

        if let url = url {
            webView = view(for: url)
            initialUrl = url
            
        // Check if URL is in clips
            if let clipIndex = commonContext.clips.firstIndex(where: { $0.url == url }) {
                  // If clip tabUUID is present
                if let existingTabUUID = commonContext.clips[clipIndex].tabUUID {
                    // Jump to tab
                    jumpToTab(with: existingTabUUID)
                    return
                }
            }
        }

        let tabUUID = UUID()
        let tab = Tab(id: UUID(), tabUUID: tabUUID, webView: webView, currentUrl: initialUrl, initialUrl: initialUrl, timestamp: Date(), lastUsedTimestamp: Date(), isThinking: true)
        tabs.append(tab)
        
        // If URL is in clips, update its tabUUID
        if let url = url, let clipIndex = commonContext.clips.firstIndex(where: { $0.url == url }) {
            commonContext.clips[clipIndex].tabUUID = tabUUID
        }
        
        
        currentTabIndex = tabs.count - 1
        
    }
    

    
    func addPerlexityTab(query: String, searchEngine: String? = nil) {
        let trimmedText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty { return }
        
        let count = wordCount(trimmedText)
        let hasEntity = containsEntity(in: trimmedText)
    
        print(count)
        print(hasEntity)
        
        if count < 5 && hasEntity {
            addGoogleSearchTab(query: trimmedText)

        } else {
            
            // Check for an existing Google search tab using the currentUrl key
            if let existingGoogleSearchTab = tabs.first(where: { $0.currentUrl?.host == "www.perplexity.ai" && $0.currentUrl?.path == "/search" }) {
                
                // Replace the query for that tab's URL
                let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let newSearchURL = URL(string: "https://www.perplexity.ai/search?q=\(searchString)") {
                    existingGoogleSearchTab.webView?.load(URLRequest(url: newSearchURL))
                }
                
                // Jump to that tab
                jumpToTab(with: existingGoogleSearchTab.tabUUID)
            } else {
                // If no existing Google search tab was found, then add a new tab as originally done
                let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let searchURL = URL(string: "https://www.perplexity.ai/search?q=\(searchString)")!
                addNewTab(url: searchURL)
            }
        }
    }
    
    func addGoogleSearchTab(query: String, searchEngine: String? = nil) {
        let trimmedText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty { return }
        

        // Check for an existing Google search tab using the currentUrl key
        if let existingGoogleSearchTab = tabs.first(where: { $0.currentUrl?.host == "www.google.com" && $0.currentUrl?.path == "/search" }) {
            
            // Replace the query for that tab's URL
            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let newSearchURL = URL(string: "https://www.google.com/search?q=\(searchString)") {
                existingGoogleSearchTab.webView?.load(URLRequest(url: newSearchURL))
            }
            
            // Jump to that tab
            jumpToTab(with: existingGoogleSearchTab.tabUUID)
        } else {
            // If no existing Google search tab was found, then add a new tab as originally done
            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let searchURL = URL(string: "https://www.google.com/search?q=\(searchString)")!
            addNewTab(url: searchURL)
        }
    }
    
    



  
    func navTabTimer() {
        timeOnCurrentTab = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if let timeOnCurrentTab = self.timeOnCurrentTab, Date().timeIntervalSince(timeOnCurrentTab) >= 3 {
                // Check if the current tab is the last tab
                if self.currentTabIndex < self.tabs.count - 1 {
                    updateLastUsedTimestamp(for: self.currentTabIndex)
                    self.commonContext.shouldMoveCurrentTabToLast = true
                }
            }
        }
    }
    
    func moveCurrentTabToLast(from index: Int) {
        if commonContext.shouldMoveCurrentTabToLast {
            let tabToMove = tabs.remove(at: index)
            tabs.append(tabToMove)
            commonContext.shouldMoveCurrentTabToLast = false
            version += 1
        }
    }

    func jumpToTab(with UUID: UUID) {
        if let tabIndex = tabs.firstIndex(where: { $0.tabUUID == UUID }) {
            commonContext.shouldMoveCurrentTabToLast = false
            commonContext.isAskViewActive = false
//            print("Jump to tab invoked")
            
//            withAnimation(.easeInOut) {
                currentTabIndex = tabIndex
//            }
            
//             Newly added cause timer no initiated or may be initiated and then bool changes to false
            navTabTimer()
        }
    }
    
    func updateLastUsedTimestamp(for index: Int) {
        if index < tabs.count {
            tabs[index].lastUsedTimestamp = Date() // Update the last used timestamp to the current time
        }
    }
    
    func updateIsThinkingState(for tabUUID: UUID, to state: Bool) {
        if let tabIndex = tabs.firstIndex(where: { $0.tabUUID == tabUUID }) {
            tabs[tabIndex].isThinking = state
        }
    }
    
    
    func goBack() {
        guard currentTabIndex < tabs.count else { return }
        if tabs[currentTabIndex].webView?.canGoBack ?? false {
            tabs[currentTabIndex].webView?.goBack()
            objectWillChange.send()
        }
    }

    func goForward() {
        guard currentTabIndex < tabs.count else { return }
        if tabs[currentTabIndex].webView?.canGoForward ?? false {
            tabs[currentTabIndex].webView?.goForward()
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
            
//            if let index = self.tabs.firstIndex(where: { $0.webView == webView }) {
                self.objectWillChange.send() // Notify SwiftUI to update the view
//            }
        }
    }


    
    func reloadCurrentTab() {
        if currentTabIndex < tabs.count {
            tabs[currentTabIndex].webView?.reload()
        }
    }

    
    func closeCurrentTab() {
        if currentTabIndex >= 0 && currentTabIndex < tabs.count {
            let uuid = tabs[currentTabIndex].tabUUID
//            withAnimation(.easeInOut) {
            if self.commonContext.shouldMoveCurrentTabToLast == true {
                moveCurrentTabToLast(from: currentTabIndex)
                }
            closeTab(with: uuid)
//            }
        }
    }

    
    private func createWebView(for url: URL) -> WKWebView {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController.add(self, name: "inputFieldInFocus")
        configuration.processPool = WKProcessPool()




        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.configuration.allowsAirPlayForMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        


        webView.uiDelegate = self



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






    

    
    func isTabOld(_ tab: Tab) -> Bool {
        // If the tab is the current one, it's not old
        if tab.tabUUID == tabs[currentTabIndex].tabUUID {
            return false
        }
        
        // Check for any other tab if it's more than 6 hours old
        else {
            return Date().timeIntervalSince(tab.lastUsedTimestamp) > 6 * 60 * 60
        }
    }





    func closeTab(with uuid: UUID) {
        if let index = tabs.firstIndex(where: { $0.tabUUID == uuid }) {
            tabs.remove(at: index)
            if currentTabIndex > index {
                currentTabIndex -= 1
            } else if !tabs.isEmpty { // Check if there are other tabs available
                currentTabIndex = min(currentTabIndex, tabs.count - 1) // Ensure currentTabIndex is not out of range
            } else {
                currentTabIndex = -1 // Indicate that there are no more tabs
            }
            
            // Add this block to check and update any clips with matching tabUUID
            for i in 0..<self.commonContext.clips.count {
                if self.commonContext.clips[i].tabUUID == uuid {
                    self.commonContext.clips[i].tabUUID = nil
                }
            }
        }
    }
    
    
    private func clearOldCacheItems() {
        for tab in tabs.reversed() {

            if isTabOld(tab) {
                closeTab(with: tab.tabUUID)
            }
        }
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Handle links opening in new target (_blank, etc.)
        if navigationAction.targetFrame == nil {
            addNewTab(url: url)
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
        if let index = tabs.firstIndex(where: { $0.webView == webView }) {
            
            var updateUrl = tabs[index]
            
            updateUrl.currentUrl = webView.url // Update the newUrl
            
            
            tabs[index] = Tab(id: tabs[index].id, tabUUID: tabs[index].tabUUID, webView: webView, currentUrl: updateUrl.currentUrl, initialUrl: tabs[index].initialUrl, timestamp: Date(), lastUsedTimestamp: Date(), isThinking: false)

            
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

extension TabManagerViewModel: WKScriptMessageHandler {
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





protocol TabManagerDelegate: AnyObject {
    func updateIsThinkingState(for tabUUID: UUID, to state: Bool)
}

