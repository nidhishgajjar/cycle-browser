
//  Created by Nidhish Gajjar on 2023-06-11.
//

import SwiftUI
import WebKit

struct Item: Identifiable {
    var id = UUID()
}


struct TabView: View {
    @EnvironmentObject var tabManager: TabManagerViewModel
    @EnvironmentObject var commonContext: ContextViewModel
    
    @State private var switchClosTabIcon: Bool = false
    @State private var isMovingUp: Bool = false
    @State private var isPassButtonLoading: Bool = false
    @Namespace private var transition
    
    @Environment(\.colorScheme) var colorScheme
    

    var body: some View {
        let currentTab = Binding<Int>(
            get: { tabManager.currentTabIndex },
            set: {
                let safeIndex = min(max($0, 0), tabManager.tabs.count - 1)
                tabManager.currentTabIndex = safeIndex
                tabManager.updateLastUsedTimestamp(for: tabManager.currentTabIndex)
                if !commonContext.shouldMoveCurrentTabToLast {
                    tabManager.navTabTimer()
                } else {
                    commonContext.shouldMoveCurrentTabToLast = false
                }
            }
        )

        return VStack (spacing: 0) {
            if !tabManager.tabs.isEmpty {
                HStack {
                    ZStack {
                        ForEach(tabManager.tabs.indices, id: \.self) { index in
                                if index == currentTab.wrappedValue {
                                    ChooseTypeOfTabView(tab: $tabManager.tabs[index])
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
                    }.id(tabManager.version)
                    
                    VStack {
                        Spacer().frame(height: 5)

                        Button(action: {
                            if tabManager.tabs.count > 1 {
                                  tabManager.closeCurrentTab()
                              }
                        }) {
                            if switchClosTabIcon {
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
                        .opacity((tabManager.tabs.count < 2 || (!commonContext.shouldMoveCurrentTabToLast && currentTab.wrappedValue != tabManager.tabs.count - 1)) ? 0 : 1)
                        .onHover{
                            hovering in
                                switchClosTabIcon = hovering
                        }
                        .buttonStyle(PlainButtonStyle()) // Use a plain style to avoid the default button style

                        Spacer() // Adjust the height as needed for your layout

                        VStack {
                            Button(action: {
                                isMovingUp = true
                                withAnimation(.easeInOut) {
                                    if commonContext.shouldMoveCurrentTabToLast && currentTab.wrappedValue < tabManager.tabs.count - 1 {
                                        tabManager.moveCurrentTabToLast(from: currentTab.wrappedValue)
                                        currentTab.wrappedValue = tabManager.tabs.count - 2
                                    } else if !commonContext.shouldMoveCurrentTabToLast {
                                        currentTab.wrappedValue = max(currentTab.wrappedValue - 1, 0)
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.up")
                            }
                            .padding(EdgeInsets(top: -22, leading: 0, bottom: 0, trailing: 0))
                            .opacity((currentTab.wrappedValue == 0 && !commonContext.shouldMoveCurrentTabToLast) ? 0.01 : 1.0)
                            .keyboardShortcut(KeyEquivalent("j"), modifiers: .command)

                            Button(action: {
                                isMovingUp = false
                                withAnimation(.easeInOut) {
                                    currentTab.wrappedValue = min(currentTab.wrappedValue + 1, tabManager.tabs.count - 1)
                                }
                            }) {
                                Image(systemName: "arrow.down")
                            }
                            .padding(EdgeInsets(top: -3, leading: 0, bottom: 0, trailing: 0))
                            .opacity((currentTab.wrappedValue == tabManager.tabs.count - 1 || commonContext.shouldMoveCurrentTabToLast) ? 0.01 : 1.0)
                            .keyboardShortcut(KeyEquivalent("k"), modifiers: .command)

                        }

                        Spacer()
                    }
                }
            }
            PaletteView(url: tabManager.tabs[currentTab.wrappedValue].url?.absoluteString ?? "")
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 39))

        }

    }
}
