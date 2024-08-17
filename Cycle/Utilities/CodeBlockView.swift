////
////  CodeBlockView.swift
////  Scigic
////
////  Created by Nidhish Gajjar on 2023-08-01.
////
//
//import SwiftUI
//import Markdown
//
//enum HighlighterConstants {
//    static let color = Color(red: 38/255, green: 38/255, blue: 38/255)
//}
//
//struct CodeBlockView: View {
//    
//    let parserResult: ParserResult
//    @State var isCopied = false
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            header
//                .padding(.horizontal)
//                .padding(.vertical, 8)
//                .background(Color(red: 9/255, green: 49/255, blue: 69/255))
//            
//            ScrollView(.horizontal, showsIndicators: true) {
//                Text(parserResult.attributedString)
//                    .padding(.horizontal, 16)
//                    .textSelection(.enabled)
//                    .padding(.top, 16)
//            }
//        }
//        .background(HighlighterConstants.color)
//        .cornerRadius(8)
//    }
//    
//    var header: some View {
//        HStack {
//            if let codeBlockLanguage = parserResult.codeBlockLanguage {
//                Text(codeBlockLanguage.capitalized)
//                    .font(.headline.monospaced())
//                    .foregroundColor(.white)
//            }
//            Spacer()
//            button
//        }
//    }
//    
//    @ViewBuilder
//    var button: some View {
//        if isCopied {
//            HStack {
//                Text("Copied")
//                    .foregroundColor(.white)
//                    .font(.subheadline.monospaced().bold())
//                Image(systemName: "checkmark.circle.fill")
//                    .imageScale(.large)
//                    .symbolRenderingMode(.multicolor)
//                    .padding(.bottom, 1)
//            }
//            .frame(alignment: .trailing)
//        } else {
//            Button {
//                let codeSnippet = NSAttributedString(parserResult.attributedString).string
//                
//                let pasteboard = NSPasteboard.general
//                pasteboard.clearContents()
//                pasteboard.setString(codeSnippet, forType: .string)
//                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
//                
//                
//                withAnimation {
//                    isCopied = true
//                }
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    withAnimation {
//                        isCopied = false
//                    }
//                }
//            } label: {
//                Image(systemName: "doc.on.doc")
//            }
//            .foregroundColor(.white)
//        }
//    }
//}
//
//
//
//struct CodeBlockOrTextView: View {
//    let parserResult: ParserResult
//
//    @ViewBuilder
//    var body: some View {
//        if parserResult.isCodeBlock {
//            CodeBlockView(parserResult: parserResult)
//        } else {
//            Text(parserResult.attributedString)
//                .textSelection(.enabled)
//        }
//    }
//}
//
//
//
//
//
//
//
//
////
////struct CodeBlockView_Previews: PreviewProvider {
////
////    static var markdownString = """
////    ```swift
////    let api = ChatGPTAPI(apiKey: "API_KEY")
////
////    Task {
////        do {
////            let stream = try await api.sendMessageStream(text: "What is ChatGPT?")
////            for try await line in stream {
////                print(line)
////            }
////        } catch {
////            print(error.localizedDescription)
////        }
////    }
////    ```
////    """
////
////    static let parserResult: ParserResult = {
////        let document = Document(parsing: markdownString)
////        var parser = MarkdownAttributedStringParser()
////        return parser.parserResults(from: document)[0]
////    }()
////
////    static var previews: some View {
////        CodeBlockView(parserResult: parserResult)
////    }
////}
////
////
