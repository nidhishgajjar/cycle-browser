
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI
import Markdown

struct AGIInstinctView: View {
//    @EnvironmentObject var webSocketService: WebSocketService
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel

    @Environment(\.colorScheme) var colorScheme

    let slateUUID: UUID
    let humanAGIRequest: String
    let chunkSize: Int = 64

    @State private var expanded: Bool = false
    @State private var textHeight: CGFloat = 15
    @State private var parserResults: [ParserResult] = []
    @State var isCopied = false


    func attributedView(results: [ParserResult]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { parsed in
                if parsed.isCodeBlock {
                    CodeBlockView(parserResult: parsed)
                        .padding(.bottom, 24)
                        .padding(.top, -20)
                        .padding(.horizontal, 25)
                        .lineSpacing(7)
                } else {
                    Text(parsed.attributedString)
                        .lineSpacing(10)
                        .padding(3)
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.75))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }


//    func jobExistsForCurrentSlate() -> Bool {
//        return commonContext.jobs.first(where: { $0.slateUUID == slateUUID }) != nil
//    }

    var body: some View {
        ZStack {
            RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0)
                .fill(colorScheme == .dark ?
                      Color(red: 25/255, green: 25/255, blue: 25/255) : Color.white
                )

            VStack {

                Button(action: {
                    expanded.toggle()
                }) {
                    VStack(alignment: .leading) {
                        ScrollView {
                            Text(humanAGIRequest)
                                .font(.system(size: 15))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 120))
                                .lineSpacing(5)
                                .kerning(0.75)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(GeometryReader { geometry in
                                    Color.clear.onAppear {
                                        self.textHeight = geometry.size.height
                                    }
                                })
                        }
                        .frame(height: expanded ? min(self.textHeight, 200) : 19)
                    }
                    .padding(EdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40))
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(EdgeInsets(top: 30, leading: 70, bottom: 0, trailing: 70))
                .overlay(
                    VStack {
                        HStack(spacing: 30) {
                            
                            Spacer()
                            
                            Button(action: {
                                slateManager.closeCurrentSlate()
                                slateManager.addPerlexitySlate(query: humanAGIRequest)
                            }) {
                                Text("Google It")
                                    .foregroundColor(.gray)
                            }
                            .padding(2)
                            .padding(.horizontal, 9)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                            .cornerRadius(7)
                            .buttonStyle(PlainButtonStyle())

                            Button {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(humanAGIRequest, forType: .string)
                                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                                withAnimation {
                                    isCopied = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        isCopied = false
                                    }
                                }
                            } label: {
                                if isCopied {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .symbolRenderingMode(.multicolor)
                                        .opacity(0.75)
                                } else {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            .frame(width: 35, height: 20)
                            .foregroundColor(.gray)
                            .padding(.vertical, 1)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                            .cornerRadius(5)
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 28)
                        .padding(.trailing, 85)
                    }
                )


                ScrollView {
                    
                    ZStack {
                        RoundedCornersShape(topLeft: 20, topRight: 20, bottomLeft: 20, bottomRight: 20)
                            .fill(Color.gray.opacity(0.05))
                        
                        attributedView(results: commonContext.parserResultDict[slateUUID.uuidString] ?? [])
                            .padding(EdgeInsets(top: 27, leading: 37, bottom: 27, trailing: 37))
                    }
                }
                .textSelection(.enabled)
                .cornerRadius(10)
                .padding(EdgeInsets(top: 15, leading: 70, bottom: 30, trailing: 70))
                .onChange(of: commonContext.instinctRespChunkDict[slateUUID.uuidString]) { _ in
                    commonContext.parseChunks(slateUUID: slateUUID.uuidString)
                }
                .onReceive(commonContext.$currentQuery, perform: { query in
                    if let query = query, !query.isEmpty {
                        // Perform some action with the new query
                        slateManager.closeSlate(with: slateUUID)
                        slateManager.addPerlexitySlate(query: query)
                        commonContext.currentQuery = ""
                    }
                })


            }
        }
    }

}







// Scigic Assistant Autonomous
// This goes after the attributedString

//                    if jobExistsForCurrentSlate() {
//                        Button(action: {
//                            commonContext.isPopVisible.toggle()
//                            commonContext.isJobsPopActive.toggle()
//                        }) {
//                            Text("View Job")
//                                .foregroundColor(.black.opacity(0.75))
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.top, 20)
//                        .padding(.horizontal, 40)
//                    }
