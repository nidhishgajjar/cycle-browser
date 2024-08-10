
//  Created by Nidhish Gajjar on 2023-07-04.
//

import SwiftUI



struct ThinkingView: View {
    @EnvironmentObject var slateManager: SlateManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    @State private var displayText: String? = nil
    @State private var copied = false

    let errorCopyText: String
    let slateUUID: UUID

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0)
                .fill(colorScheme == .dark ?
                      Color(red: 25/255, green: 25/255, blue: 25/255) : Color.white
                )

            if let text = displayText {
                ErrorView(errorCopyText: text, slateUUID: slateUUID)
                    .padding(10)
            } else {
                Image(systemName: "circle.dotted")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.75) : .black.opacity(0.75))
                    .scaleEffect(commonContext.isBeating ? 0.4 : 0.6)
            }
        }
        .onAppear() {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                commonContext.isBeating.toggle()
            }

            // Introduce a delay to display the passed text
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation {
                    displayText = errorCopyText
                }
            }
        }
    }
}

