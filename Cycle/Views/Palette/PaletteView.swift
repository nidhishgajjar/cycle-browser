
//  Created by Nidhish Gajjar on 2023-06-28.
//

import SwiftUI

struct PaletteView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var tabManager: TabManagerViewModel
    @State var textFieldHeight: CGFloat = 30
    @State private var isPassButtonLoading: Bool = false
    let url: String
    
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
            VStack (spacing: 0){
                HStack {
                    AskBarView(text:$commonContext.askTextFromPalette, height: $textFieldHeight)
                        .environmentObject(tabManager)
                        .frame(maxHeight: textFieldHeight > 100 ? min(textFieldHeight, 24) : textFieldHeight)
                    
                    if !url.isEmpty && AskScigicButton(url: url).isValidGoogleURL {
                       AskScigicButton(url: url)
                            .background(colorScheme == .dark ? .black.opacity(0.3) : .white.opacity(0.6))
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                   }
                    
                }
                .padding(EdgeInsets(top: 1, leading: 50, bottom: 15, trailing: 50))
                
                NavButtons(url: url)
                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 2, trailing: 40))
            }
            .frame(height: 100)
            .background(
                VisualBlurEffect(material: .sidebar)
                    .overlay(
                        Rectangle().fill(
                            colorScheme == .dark ?
                                Color(red: 62/255, green: 62/255, blue: 62/255).opacity(0.3) :
                                Color(red: 241/255, green: 241/255, blue: 241/255).opacity(0.3)
                        )
                    )
            )
            .clipShape(RoundedCornersShape(topLeft: 0, topRight: 0, bottomLeft: 20, bottomRight: 20))
            .onChange(of: commonContext.askTextFromPalette) { newValue in
                if newValue.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                    commonContext.isAskViewActive = true
                    commonContext.askText = newValue
                } else {
                    commonContext.isAskViewActive = false
                }
            }
        }
    }
