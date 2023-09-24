
//  Created by Nidhish Gajjar on 2023-07-04.
//

import SwiftUI

struct AGIView: View {
    @ObservedObject var interface: Interface
    @EnvironmentObject var commonContext: ContextViewModel
    let humanAGIRequest: String

    var body: some View {
        Group {
            if interface.showInstinctsView {
                AGIInstinctView(slateUUID: interface.slateUUID, humanAGIRequest: humanAGIRequest)
            } else if interface.showKnowledgeGapView {
                AGIKnowledgeGapView()
            } else if interface.showHumanApprovalView {
                AGIHumanApprovalView(slateUUID: interface.slateUUID)
            } else if interface.showDeduceView {
                AGIDeduceView(slateUUID: interface.slateUUID, humanAGIRequest: humanAGIRequest)
            }
        }
    }
}
