
//  Created by Nidhish Gajjar on 2023-06-09.
//

import SwiftUI

struct CanvasStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.75))
            .cornerRadius(20)
    }
}

//
//struct HandCursorModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .onHover { isHovering in
//                if isHovering {
//                    NSCursor.pointingHand.push()
//                } else {
//                    NSCursor.pop()
//                }
//            }
//    }
//}
//
//extension View {
//    func handCursor() -> some View {
//        self.modifier(HandCursorModifier())
//    }
//}


