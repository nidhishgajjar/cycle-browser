
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI

//struct AGIDeduceView: View {
//    @EnvironmentObject var commonContext: ContextViewModel
//
//    let slateUUID: UUID  // each AGIDeduceView should have its own slateUUID
//    let humanAGIRequest: String
//    @State private var expanded: Bool = false
//
//    var body: some View {
//        ZStack {
//            RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0)
//                .fill(Color.white)
//
//            VStack {
//                if let outcome = commonContext.outcomes.first(where: {$0.slateUUID == slateUUID}) {
//                    Button(action: {}) {
//                        Text("Look's Good!")
//                            .font(.system(size:15))
//                            .padding(EdgeInsets(top: 5, leading: 40, bottom: 5, trailing: 40))
//                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black, Color.indigo]), startPoint: .bottomLeading, endPoint: .topTrailing))
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                    }
//                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 5, trailing: 0))
//                    .buttonStyle(PlainButtonStyle())
//
//                    Button(action: {
//                        expanded.toggle()
//                    }) {
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text(humanAGIRequest)
//                                    .font(.system(size: 15))
//                                    .lineSpacing(5)
//                                    .kerning(0.75)
//                                    .lineLimit(expanded ? nil : 1)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                Spacer()
//                            }
//                        }
//                        .padding(EdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40))
//                        .background(Color.gray.opacity(0.1))
//                        .foregroundColor(Color.gray.opacity(0.6))
//                        .cornerRadius(10)
//                        .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .padding(EdgeInsets(top: 30, leading: 70, bottom: 0, trailing: 70))
//
//                    ScrollView {
//                        Text(outcome.content ?? "")
//                            .font(.system(size: 18))
//                            .fontWeight(.light)
//                            .lineSpacing(5)
//                            .kerning(0.75)
//                            .padding(EdgeInsets(top: 30, leading: 40, bottom: 30, trailing: 40))
//                            .background(Color.gray.opacity(0.05))
//                            .foregroundColor(Color.black.opacity(0.75))
//                            .cornerRadius(10)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .frame(height: 700)
//                    }
//                    .textSelection(.enabled)
//                    .cornerRadius(10)
//                    .padding(EdgeInsets(top: 15, leading: 70, bottom: 30, trailing: 70))
//
//                    if let url = URL(string: outcome.url ?? "https://google.com") {
//                        WebView(url: url)
//                            .cornerRadius(15)
//                            .padding(EdgeInsets(top: 15, leading: 70, bottom: 30, trailing: 70))
//                            .frame(height: 700)
//                    }
//                }
//            }
//        }
//    }
//}
//



import SwiftUI

struct AGIDeduceView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel

    let slateUUID: UUID  // each AGIDeduceView should have its own slateUUID
    let humanAGIRequest: String
    @State private var expanded: Bool = false

    var body: some View {
        ZStack {
            RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0)
                .fill(Color.white)

            VStack {
                VStack {
//                    Button(action: {}) {
//                        Text("Look's Good!")
//                            .font(.system(size:15))
//                            .padding(EdgeInsets(top: 5, leading: 40, bottom: 5, trailing: 40))
//                            .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black, Color.indigo]), startPoint: .bottomLeading, endPoint: .topTrailing))
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                    }
//                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 5, trailing: 0))
//                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        expanded.toggle()
                    }) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(humanAGIRequest)
                                    .font(.system(size: 15))
                                    .lineSpacing(5)
                                    .kerning(0.75)
                                    .lineLimit(expanded ? nil : 1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                        }
                        .padding(EdgeInsets(top: 7, leading: 40, bottom: 7, trailing: 40))
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(Color.gray.opacity(0.6))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(EdgeInsets(top: 35, leading: 70, bottom: 0, trailing: 70))
                }
                
                ScrollView {
                    if let outcome = commonContext.outcomes.first(where: {$0.slateUUID == slateUUID}) {

                        Text(outcome.content ?? "")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .lineSpacing(5)
                            .kerning(0.75)
                            .padding(EdgeInsets(top: 30, leading: 40, bottom: 15, trailing: 40))
                            .foregroundColor(Color.black.opacity(0.75))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
//                            slateManager.addNewSlate(url: URL(string: outcome.url ?? "https://google.com"))
                            slateManager.addGoogleSearchSlate(query: "constitute ai")
                        }) {
                            Text("Open in Slate")
                                .font(.system(size:13))
                                .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
                                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.black]), startPoint: .bottomLeading, endPoint: .topTrailing))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(EdgeInsets(top: 35, leading: 0, bottom: 5, trailing: 60))
                        .buttonStyle(PlainButtonStyle())

                        if let url = URL(string: outcome.url ?? "https://google.com") {
                            WebView(url: url)
                                .cornerRadius(15)
                                .padding(EdgeInsets(top: 5, leading: 50, bottom: 15, trailing: 50))
                                .frame(height: 500)
                        }
                    }
                }
                .textSelection(.enabled)
                .background(Color.gray.opacity(0.05)).cornerRadius(15)
                .padding(EdgeInsets(top: 15, leading: 70, bottom: 30, trailing: 70))
            }
        }
    }
}

