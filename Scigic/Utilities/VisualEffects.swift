
//  Created by Nidhish Gajjar on 2023-06-28.
//

import SwiftUI

struct VisualBlurEffect: NSViewRepresentable {
    var material: NSVisualEffectView.Material

    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .withinWindow // Change the blendingMode here
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: NSViewRepresentableContext<Self>) {
        nsView.material = material
        nsView.blendingMode = .withinWindow // And here
    }
}


