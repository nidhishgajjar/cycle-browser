
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI
import Foundation

struct AskView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel

    @State var textFieldHeight: CGFloat = 30
    @State private var suggestionRowHeight: CGFloat = 55
    let googleService = GoogleAutocompleteService()
    @StateObject var autoComplete = AutoSuggestViewModel()
    
    @Environment(\.colorScheme) var colorScheme

    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    if textFieldHeight <= 100 {
                        //                    Spacer()
                        ClipsView()
                            .opacity((autoComplete.suggestions.count > 3 && commonContext.askText.count > 0 && textFieldHeight <= 30) ? 0 : 1)
                        Spacer()
                        //                        ActionView()
                        //                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 21, trailing: 0))
                        if !(autoComplete.suggestions.count > 3) && !(commonContext.askText.count > 0) {
                            ActionView()
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 21, trailing: 0))
                        }
                        
//                                                .opacity((autoComplete.suggestions.count > 1 || commonContext.askText.count > 0) ? 0 : 1)
                    }
                    ZStack {
                        
                        VStack {
                            if autoComplete.suggestions.count > 3 && commonContext.askText.count > 0 && commonContext.askText.count <= 70 && textFieldHeight <= 30  {
                                Spacer()
                                RoundedCornersShape(topLeft: 20, topRight: 20, bottomLeft: 20, bottomRight: 20)
                                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                                    .padding(EdgeInsets(top: 0, leading: 27, bottom: 35, trailing: 27))
                                    .frame(height: CGFloat(6) * suggestionRowHeight)

                            }
                        }
                        
                            VStack(spacing: 10) {
                                // Conditionally display AutoSuggestView
                                if autoComplete.suggestions.count > 3 && commonContext.askText.count > 0 && commonContext.askText.count <= 70 && textFieldHeight <= 30 {
                                    
                                    
                                    AutoSuggestView(autoComplete: autoComplete)
                                        .padding(EdgeInsets(top: 10, leading: 45, bottom: 0, trailing: 45))
                                }
                                
                                AskBarView(text: $commonContext.askText, height: $textFieldHeight)
                                    .environmentObject(slateManager)
                                    .frame(maxHeight: textFieldHeight > 100 ? min(textFieldHeight, geometry.size.height) : textFieldHeight)
                                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 57, trailing: 50))
                                    .shadow(color: Color.gray, radius: (autoComplete.suggestions.count > 1 && commonContext.askText.count > 0) ? 0.5 : 0)
                                    .onChange(of: commonContext.askText) { newValue in
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
    }
}






//                if textFieldHeight <= 100 {
//                    HStack{
//                        Image(systemName: "command")
//                            .frame(width: 10, height: 10)
//                            .foregroundColor(.gray.opacity(0.4))
//                        Text("+")
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray.opacity(0.4))
//                        Image(systemName: "return")
//                            .frame(width: 10, height: 10)
//                            .foregroundColor(.gray.opacity(0.4))
//                        Text("to Google it!")
//                            .font(.system(size: 11))
//                            .foregroundColor(.gray.opacity(0.4))
//                        Spacer()
//                    }
//                    .padding(EdgeInsets(top: 0, leading: 65, bottom: 21, trailing: 50))
//                }
