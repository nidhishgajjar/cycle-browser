import SwiftUI
import Foundation

struct AskView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var tabManager: TabManagerViewModel

    @State var textFieldHeight: CGFloat = 30
    @State private var suggestionRowHeight: CGFloat = 55
    
    @StateObject private var autoComplete: AutoSuggestViewModel
    
    @Environment(\.colorScheme) var colorScheme

    init(tabManager: TabManagerViewModel) {
        _autoComplete = StateObject(wrappedValue: AutoSuggestViewModel(tabManager: tabManager))
        print("AskView initialized") // Debug
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    if textFieldHeight <= 100 {
                        ClipsView()
                            .opacity((autoComplete.suggestions.count > 3 && commonContext.askText.count > 0 && textFieldHeight <= 30) ? 0 : 1)
                        Spacer()
                        if !(autoComplete.suggestions.count > 3) && !(commonContext.askText.count > 0) {
                            ActionView()
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 21, trailing: 0))
                        }
                    }
                    ZStack {
//                        VStack {
//                            if autoComplete.suggestions.count > 3 && commonContext.askText.count > 0 && commonContext.askText.count <= 70 && textFieldHeight <= 30  {
//                                Spacer()
//                                RoundedCornersShape(topLeft: 20, topRight: 20, bottomLeft: 20, bottomRight: 20)
//                                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
//                                    .padding(EdgeInsets(top: 0, leading: 27, bottom: 35, trailing: 27))
//                                    .frame(height: CGFloat(7) * suggestionRowHeight)
//                            }
//                        }
                        
                        VStack(spacing: 10) {
                            if autoComplete.suggestions.count > 3 && commonContext.askText.count > 0 && commonContext.askText.count <= 70 && textFieldHeight <= 30 {
                                AutoSuggestView(autoComplete: autoComplete)
                                    .padding(EdgeInsets(top: 10, leading: 50, bottom: 0, trailing: 50))
                            }
                            
                            AskBarView(text: $commonContext.askText, height: $textFieldHeight)
                                .environmentObject(tabManager)
                                .frame(maxHeight: textFieldHeight > 100 ? min(textFieldHeight, geometry.size.height) : textFieldHeight)
                                .padding(EdgeInsets(top: 0, leading: 50, bottom: 57, trailing: 50))
                                .shadow(color: Color.gray, radius: (autoComplete.suggestions.count > 1 && commonContext.askText.count > 0) ? 0.5 : 0)
                                .onChange(of: commonContext.askText) { newValue in
                                    print("Ask text changed: \(newValue)") // Debug
                                    autoComplete.fetchSuggestions(for: newValue)
                                }
                        }
                    }
                }
                .frame(maxHeight: geometry.size.height)
                .background(
                    VisualBlurEffect(material: .fullScreenUI)
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 241/255, green: 241/255, blue: 241/255).opacity(0.3))
                        )
                )
                .clipShape(RoundedCornersShape(topLeft: 0, topRight: 20, bottomLeft: 0, bottomRight: 20))
            }
        }
        .onAppear {
            print("AskView appeared") // Debug
        }
    }
}
