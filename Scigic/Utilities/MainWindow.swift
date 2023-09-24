
//  Created by Nidhish Gajjar on 2023-06-11.
//
import SwiftUI


class MainWindow: NSWindow {
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36: // Enter key
            // We handle it in SwiftUI, so do nothing here.
            break
        default:
            super.keyDown(with: event) // For all other keys, let the super class handle it.
        }
    }


    override func mouseDragged(with event: NSEvent) {
        var newOrigin = self.frame.origin
        newOrigin.x += event.deltaX
        newOrigin.y -= event.deltaY
        self.setFrameOrigin(newOrigin)
    }
    
    override func mouseDown(with event: NSEvent) {
            NotificationCenter.default.post(name: NSNotification.Name("mouseClickedOutside"), object: nil)
            super.mouseDown(with: event)
    }
    
    
}


//
//override func keyDown(with event: NSEvent) {
//    if isWebViewOrDescendantFirstResponder() {
//        super.keyDown(with: event)
//        return
//    }
//
//    switch event.keyCode {
//    case 36: // Enter key
//        // Handled in SwiftUI, so do nothing here.
//        break
//    default:
//        super.keyDown(with: event) // For all other keys, let the super class handle it.
//    }
//}
//
//func isWebViewOrDescendantFirstResponder() -> Bool {
//    guard let firstResponder = self.firstResponder else {
//        return false
//    }
//    
//    if firstResponder is WKWebView {
//        return true
//    }
//    
//    var responder: NSResponder? = firstResponder
//    while let nextResponder = responder?.nextResponder {
//        if nextResponder is WKWebView {
//            return true
//        }
//        responder = nextResponder
//    }
//    
//    return false
//}
