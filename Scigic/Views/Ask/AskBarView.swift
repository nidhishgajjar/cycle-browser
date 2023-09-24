
//  Created by Nidhish Gajjar on 2023-06-10.
//

import SwiftUI
import AppKit


protocol CustomTextViewDelegate: NSObjectProtocol {
    func didPressCommandEnter(text: String)
}



class CustomTextView: NSTextView {
    weak var customDelegate: CustomTextViewDelegate?
    var currentHeight: CGFloat = 0
    
    override func keyDown(with event: NSEvent) {
        // Check for Command + Enter

        if event.modifierFlags.contains(.command) && event.keyCode == 36 {
            self.customDelegate?.didPressCommandEnter(text: self.string)
        } else if event.keyCode == 126 && self.currentHeight <= 30 { // Check for Up Arrow and height condition
            // Consume the up arrow key event if the height is 30
            return
        } else {
            super.keyDown(with: event)
        }
    }

    
}

struct MultilineTextField: NSViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat // Add a @State variable for the height
    @EnvironmentObject var slateManager: SlateManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel

    let padding: CGFloat
    let maxHeight: CGFloat
    let customKerningValue: CGFloat = 0.75 // Adjust this value to your liking
    
    
    func isDarkMode() -> Bool {
            if let appearance = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
                return appearance == .darkAqua
            }
            return false
        }



    class Coordinator: NSObject, NSTextViewDelegate, CustomTextViewDelegate {
        var parent: MultilineTextField

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
        

        func didPressCommandEnter(text: String) {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty { return }

            let searchString = trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let searchURL = URL(string: "https://google.com/search?q=\(searchString)")!
            parent.slateManager.addNewSlate(url: searchURL)
//            parent.commonContext.isAskViewActive.toggle()
            parent.commonContext.askBarFocusedOnAGI.toggle()
            parent.commonContext.askText = "" 
            parent.commonContext.askTextFromPalette = ""
        }
        

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if (NSApp.currentEvent?.modifierFlags.contains(.shift)) ?? false {
                    parent.commonContext.typingInAskBar = true
                    textView.insertNewlineIgnoringFieldEditor(self)
                } else {
                    let trimmedText = textView.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedText.isEmpty { return false }

                    if trimmedText.hasPrefix("https://") || trimmedText.hasPrefix("http://") {
                        if let url = URL(string: trimmedText) {
                            parent.slateManager.addNewSlate(url: url)
                        }
                        
                    } else {
                        if (NSApp.currentEvent?.modifierFlags.contains(.shift)) ?? false {
                            textView.insertNewlineIgnoringFieldEditor(self)
                        } else {
                            if !parent.commonContext.hoverAutoSuggestState && !parent.commonContext.arrowKeyForNavSuggestions {
                                if trimmedText.count > 75 {
                                    parent.slateManager.addNewSlate(humanAGIRequest: trimmedText, unstated: false)
                                } else {
                                    parent.slateManager.addNewSlate(humanAGIRequest: trimmedText)
                                }
                            }
                        }
                        
                    }
                    parent.commonContext.isAskViewActive = false
                    parent.commonContext.askBarFocusedOnAGI.toggle()
                    parent.commonContext.askText = ""
                    parent.commonContext.askTextFromPalette = ""
                }
                return true
            }
            return false
        }

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        let textView = CustomTextView()
        textView.delegate = context.coordinator
        textView.customDelegate = context.coordinator
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = .width
        textView.textContainer?.containerSize = NSSize(width: scrollView.bounds.width, height: .infinity)
        textView.textContainer?.widthTracksTextView = true
        
//        textView.backgroundColor = NSColor.textBackgroundColor
//        textView.textColor = NSColor.textColor

        textView.textContainerInset = NSSize(width: padding, height: padding)
        textView.font = NSFont.systemFont(ofSize: 15)
        textView.string = ""
        
        
        if isDarkMode() {
            textView.backgroundColor = NSColor.darkGray
            textView.textColor = NSColor.white
        } else {
            textView.backgroundColor = NSColor.white
            textView.textColor = NSColor.black
        }

        
        
        
        
//        let attributes: [NSAttributedString.Key: Any] = [
//              .kern: customKerningValue,
//              .font: NSFont.systemFont(ofSize: 15),
//              .foregroundColor: NSColor.textColor
//        ]
//
//        textView.typingAttributes = attributes
        
        let textColor: NSColor = isDarkMode() ? NSColor.lightGray : NSColor.black

        let attributes: [NSAttributedString.Key: Any] = [
            .kern: customKerningValue,
            .font: NSFont.systemFont(ofSize: 15),
            .foregroundColor: textColor
        ]

        textView.typingAttributes = attributes

        
        // Enable spell checking
        textView.isAutomaticTextCompletionEnabled  = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isGrammarCheckingEnabled = true

        textView.wantsLayer = true
        if let layer = textView.layer {
            layer.cornerRadius = 10
            layer.masksToBounds = true
        }

        scrollView.documentView = textView

        return scrollView
    }

    func focus(textView: NSTextView) {
        textView.window?.makeFirstResponder(textView)
    }


    func updateNSView(_ nsView: NSScrollView, context: Context) {
//        let textView = nsView.documentView as! NSTextView
        let textView = nsView.documentView as! CustomTextView
        
        if isDarkMode() {
            textView.backgroundColor = NSColor.darkGray
            textView.textColor = NSColor.white
        } else {
            textView.backgroundColor = NSColor.white
            textView.textColor = NSColor.black
        }

        // Check if the textView's string is already equal to the SwiftUI property
          if textView.string != text {
              // If not, then update it
              textView.string = text
          }

        // Calculate new height and apply
        if let layoutManager = textView.layoutManager, let textContainer = textView.textContainer {
            layoutManager.ensureLayout(for: textContainer)
            let size = layoutManager.usedRect(for: textContainer).size
            DispatchQueue.main.async { // Make sure to use DispatchQueue.main.async when modifying @Binding variables
                withAnimation(.easeOut) {
                    let newHeight = size.height + 2*padding
                    self.height = newHeight > 100 ? min(newHeight, maxHeight) : newHeight
                }
            }
        }
        
     
        
        textView.currentHeight = self.height
        
    }
}


struct AskBarView: View {
    @Binding var text: String
    @Binding var height: CGFloat // Add height binding here
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel
    @FocusState var isTextFieldFocused: Bool
    
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        VStack {
            ZStack (alignment: .leading) {
                MultilineTextField(text: $text, height: $height, padding:4, maxHeight: CGFloat.infinity) // Adjust min and max height here

                    .focused($isTextFieldFocused)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                
                if text.isEmpty {
                    HStack {
                        Text("Tell me...")
                            .font(.system(size:13))
                            .foregroundColor(colorScheme == .dark ? Color.secondary : Color.primary)
                            .opacity(0.5)
                            .padding(EdgeInsets(top: 4, leading: 15, bottom: 4, trailing: 0))
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: text) { newValue in
               if isTextFieldFocused {
                   commonContext.typingInAskBar = true
               }
           }

        .onChange(of: commonContext.askBarFocusedOnAGI) { newValue in
            isTextFieldFocused = newValue
        }
        .onAppear {
            DispatchQueue.main.async {
                isTextFieldFocused = true
            }
        }
    }
}
