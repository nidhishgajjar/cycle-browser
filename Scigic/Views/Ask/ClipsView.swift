
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI
import Combine

struct ClipsView: View {
    @EnvironmentObject var commonContext: ContextViewModel
    @EnvironmentObject var slateManager: SlateManagerViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var imageCache: [String: NSImage] = [:]

    func fetchImage(for url: String, completion: @escaping (NSImage?) -> Void) {
        let faviconURL = "https://www.google.com/s2/favicons?sz=64&domain=\(url)"
        if let cachedImage = imageCache[url] {
            completion(cachedImage)
            return
        }
        URLSession.shared.dataTask(with: URL(string: faviconURL)!) { data, _, _ in
            if let data = data, let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.imageCache[url] = image
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }

    var body: some View {
        VStack {
            ForEach(0..<2) { rowIndex in
                HStack (spacing: 50) {
                    ForEach(0..<5) { columnIndex in
                        let index = rowIndex * 5 + columnIndex
                        Button(action: {
                            if index < commonContext.clips.count {
                                let clip = commonContext.clips[index]
                                commonContext.askTextFromPalette = ""
                                slateManager.addNewSlate(url: clip.url)
                            }
                        }) {
                            Rectangle()
                                .background(
                                    VisualBlurEffect(material: .fullScreenUI) // Change the material here
                                        .overlay(
                                            Rectangle()
                                                .fill(colorScheme == .dark ? .gray.opacity(0.1) : .white.opacity(0.8))
                                        )
                                )
                                .foregroundColor(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
                                .frame(width: 60, height: 60)
                                .cornerRadius(20)
                                .overlay(
                                    ZStack {
                                        if let image = imageCache[commonContext.clips[index].url.absoluteString] {
                                            Image(nsImage: image)
                                                .resizable()
                                                .opacity(0.85)
                                                .frame(width: 23, height: 23)
                                                .cornerRadius(5)
                                        } else if let host = commonContext.clips[index].url.host, let firstLetter = host.first {
                                            Text(String(firstLetter).uppercased())
                                                .font(.headline)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                        }
                                    }
                                    .onAppear {
                                        if imageCache[commonContext.clips[index].url.absoluteString] == nil {
                                            fetchImage(for: commonContext.clips[index].url.absoluteString) { _ in }
                                        }
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
    }
}


// WebImage would be part of the SDWebImageSwiftUI framework, which allows you to easily load images from URLs.


//
//
//struct ClipsView: View {
//    @EnvironmentObject var commonContext: ContextViewModel
//    @EnvironmentObject var slateManager: SlateManagerViewModel
//    
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        VStack {
//            ForEach(0..<2) { rowIndex in
//                HStack (spacing: 50) {
//                    ForEach(0..<5) { columnIndex in
//                        let index = rowIndex * 5 + columnIndex
//                        Button(action: {
//                            if index < commonContext.clips.count {
//                                let clip = commonContext.clips[index]
//                                commonContext.askTextFromPalette = ""
//                                slateManager.addNewSlate(url: clip.url)
//                            }
//                        }) {
//                            Rectangle()
//                                .background(
//                                    VisualBlurEffect(material: .fullScreenUI) // Change the material here
//                                        .overlay(
//                                            Rectangle()
//                                                .fill(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
//                                        )
//                                )
//                                .foregroundColor(colorScheme == .dark ? .black.opacity(0.05) : .white.opacity(0.8))
//                                .frame(width: 70, height: 70)
//                                .cornerRadius(20)
//                                .overlay(
//                                    Text(commonContext.clips[index].name)
//                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.3))
//                                        .multilineTextAlignment(.center)
//                                )
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .padding()
//                    }
//                }
//            }
//        }
//        .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
//    }
//}
