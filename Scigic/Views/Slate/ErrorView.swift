//
//  ErrorView.swift
//  Scigic
//
//  Created by Nidhish Gajjar on 2023-08-22.


import SwiftUI

struct ErrorView: View {
    let errorCopyText: String
    let slateUUID: UUID
    @State var isCopied = false
    @EnvironmentObject var slateManager : SlateManagerViewModel
    @EnvironmentObject var commonContext : ContextViewModel
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(colorScheme == .dark ? Color.gray.opacity(0.8) : .black)

            Text("Oops! There seems to be an error on our end.")
                .font(.title2)
                .padding(.vertical, 20)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : .black)

            VStack(alignment: .leading) {
                
                Text("Copy text, ask scigic again or search your request manually")
                    .font(.system(size: 16))
                    .italic()
                    .padding(.top, 5)
                    .padding(.bottom, 1)
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : .black)
                
                HStack (spacing: 15)  {
                    
                    Text(errorCopyText)
                        .font(.system(size: 15))
                        .padding(5)
                        .padding(.horizontal, 10)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(errorCopyText, forType: .string)
                        withAnimation {
                            isCopied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isCopied = false
                            }
                        }
                    }) {
                        if isCopied {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "doc.on.doc")
                        }
                    }
                    .frame(width: 25, height: 25)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(17.5)
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        slateManager.addNewSlate(humanAGIRequest: errorCopyText, unstated: false)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            slateManager.closeSlate(with: slateUUID)
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .imageScale(.large)
                    }
                    .frame(width: 25, height: 25)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(17.5)
                    .buttonStyle(PlainButtonStyle())


                    
                    Button(action: {
                        slateManager.addWebSearchSlate(query: errorCopyText)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            slateManager.closeSlate(with: slateUUID)
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                    }
                    .frame(width: 25, height: 25)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(17.5)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 20)

                HStack(spacing: 0) {
                    Text("If the error continues, please ")
                        .font(.system(size: 13))
                        .opacity(0.5)

                    Text("contact us")
                        .underline()
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            if let url = URL(string: "https://twitter.com/constituteai") {
                                NSWorkspace.shared.open(url)
                            }
                        }

                    Text(". Or reach out by email at ")
                        .font(.system(size: 13))
                        .opacity(0.5)

                    Text("help@scigic.com")
                        .underline()
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            if let url = URL(string: "mailto:help@scigic.com") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                }
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.85) : .black)
                .padding(.vertical, 5)
            }
            .padding([.leading, .trailing], 20)
        }
        .padding()
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? Color(red: 30/255, green: 30/255, blue: 30/255) : Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.3), radius: 10, x: 0, y: 2)
    }
}
