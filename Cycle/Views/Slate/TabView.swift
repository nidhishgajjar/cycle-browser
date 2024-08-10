
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI
import WebKit

struct Item: Identifiable {
    var id = UUID()
}


struct TabView: View {
    @EnvironmentObject var slateManager: TabManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    
    @State private var switchClosSlateIcon: Bool = false
    @State private var isMovingUp: Bool = false
    @State private var isPassButtonLoading: Bool = false
    @Namespace private var transition
    
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        let currentSlate = Binding<Int>(
            get: { slateManager.currentSlateIndex },
            set: {
                let safeIndex = min(max($0, 0), slateManager.slates.count - 1)
                slateManager.currentSlateIndex = safeIndex
//                slateManager.currentSlateIndex = $0
                slateManager.updateLastUsedTimestamp(for: slateManager.currentSlateIndex)
                if !commonContext.shouldMoveCurrentSlateToLast {
                    slateManager.navSlateTimer()
                } else {
                    commonContext.shouldMoveCurrentSlateToLast = false
                }
            }
        )

        return VStack (spacing: 0) {
            if !slateManager.slates.isEmpty {
                HStack {
                    ZStack {
                        ForEach(slateManager.slates.indices, id: \.self) { index in
                                if index == currentSlate.wrappedValue {
                                    ChooseTypeOfTabView(tab: $slateManager.slates[index])
                                        .matchedGeometryEffect(id: "transition", in: transition)
                                        .transition(AnyTransition.asymmetric(insertion: .identity, removal: .move(edge: isMovingUp ? .top : .bottom)))
                                        .clipShape(RoundedCornersShape(topLeft: 10, topRight: 10, bottomLeft: 0, bottomRight: 0))
                                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                                }
                    
                        }
                        
                        if commonContext.relevantAutofillInputs {
                            GeometryReader { geometry in
                                VStack {
                                    Spacer() // Pushes the content to the bottom of the VStack
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.easeInOut) {
                                                if let url = URL(string: "x-apple.systempreferences:com.apple.Passwords-Settings.extension") {
                                                    self.isPassButtonLoading = true
                                                    let configuration = NSWorkspace.OpenConfiguration()
                                                    NSWorkspace.shared.open(url, configuration: configuration, completionHandler: { (app, error) in
                                                        // Introduce a delay before hiding the loading indicator.
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                            self.isPassButtonLoading = false
                                                            commonContext.relevantAutofillInputs = false
                                                        }
                                                    })
                                                }
                                            }
                                        }) {
                                            VStack{
                                                Text("Open iCloud Passwords")
                                                    .font(.system(size: 14))
                                                    .fontWeight(.light)
                                                    .lineSpacing(5)
                                                    .kerning(0.75)
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 12)
                                                    .opacity((isPassButtonLoading) ? 0 : 1.0)
                                            }
                                            .background(colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.05))
                                            .overlay(
                                                Group {
                                                    if isPassButtonLoading {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                                            .scaleEffect(0.5, anchor: .center)
                                                    }
                                                }
                                            )
                                        }
                                        .background(
                                            VisualBlurEffect(material: .sidebar)
                                                .overlay(
                                                    Rectangle()
                                                        .fill(Color(red: 241/255, green: 241/255, blue: 241/255).opacity(0.3))
                                                )
                                        )
                                        .clipShape(RoundedCornersShape(topLeft: 20, topRight: 20, bottomLeft: 0, bottomRight: 0))
                                        .frame(maxWidth: 300)
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                }
                            }
                        }
                    }.id(slateManager.version)
                    
                    VStack {
                        Spacer().frame(height: 5)

                        Button(action: {
                            if slateManager.slates.count > 1 {
                                  slateManager.closeCurrentSlate()
                              }
                        }) {
                            if switchClosSlateIcon {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.red.opacity(0.7))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18) // Adjust size as needed
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .foregroundColor(.red.opacity(0.3))
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16) // Adjust size as needed
                            }
                        }
                        .keyboardShortcut(KeyEquivalent("\\"), modifiers: .command)
                        .padding(EdgeInsets(top: 0, leading: -40, bottom: 0, trailing: 0))
                        .opacity((slateManager.slates.count < 2 || (!commonContext.shouldMoveCurrentSlateToLast && currentSlate.wrappedValue != slateManager.slates.count - 1)) ? 0 : 1)
                        .onHover{
                            hovering in
                                switchClosSlateIcon = hovering
                        }
                        .buttonStyle(PlainButtonStyle()) // Use a plain style to avoid the default button style

                        Spacer() // Adjust the height as needed for your layout

                        VStack {
                            Button(action: {
                                isMovingUp = true
                                withAnimation(.easeInOut) {
                                    if commonContext.shouldMoveCurrentSlateToLast && currentSlate.wrappedValue < slateManager.slates.count - 1 {
                                        slateManager.moveCurrentSlateToLast(from: currentSlate.wrappedValue)
                                        currentSlate.wrappedValue = slateManager.slates.count - 2
                                    } else if !commonContext.shouldMoveCurrentSlateToLast {
                                        currentSlate.wrappedValue = max(currentSlate.wrappedValue - 1, 0)
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.up")
                            }
                            .padding(EdgeInsets(top: -22, leading: 0, bottom: 0, trailing: 0))
                            .opacity((currentSlate.wrappedValue == 0 && !commonContext.shouldMoveCurrentSlateToLast) ? 0.01 : 1.0)
                            .keyboardShortcut(KeyEquivalent("j"), modifiers: .command)

                            Button(action: {
                                isMovingUp = false
                                withAnimation(.easeInOut) {
                                    currentSlate.wrappedValue = min(currentSlate.wrappedValue + 1, slateManager.slates.count - 1)
                                }
                            }) {
                                Image(systemName: "arrow.down")
                            }
                            .padding(EdgeInsets(top: -3, leading: 0, bottom: 0, trailing: 0))
                            .opacity((currentSlate.wrappedValue == slateManager.slates.count - 1 || commonContext.shouldMoveCurrentSlateToLast) ? 0.01 : 1.0)
                            .keyboardShortcut(KeyEquivalent("k"), modifiers: .command)

                        }

                        Spacer()
                    }
                }
            }
            PaletteView(url: slateManager.slates[currentSlate.wrappedValue].url?.absoluteString ?? "")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 39))

        }

    }
}
