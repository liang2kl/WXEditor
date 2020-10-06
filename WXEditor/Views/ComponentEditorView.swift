//
//  EditorView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import SwiftUI

struct ComponentEditorView: View {
    @ObservedObject var componentState: ComponentState
    var isTutorial: Bool = false
    var viewController: ComponentEditorViewController?
    var body: some View {
        VStack {
            TableSection(title: NSLocalizedString("Type", comment: "")) {
                Picker("", selection: $componentState.type) {
                    ForEach(HTMLComponent.allCases) { componentType in
                        if componentType != .root {
                            Label(componentType.head, systemImage: componentType.imageName)
                                .tag(componentType)
                        }
                    }
                }
                .padding(.horizontal)
            }
            if componentState.type != .br {
                HStack(alignment: .center) {
                    Text(NSLocalizedString("Class", comment: ""))
                        .font(.title2)
                        .bold()
                        .padding(.leading)
                    TextField("No Class", text: $componentState.className, onCommit: {
                        viewController?.updatePreview()
                    })
                    .padding(3)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                    .padding(.trailing)
                    .labelsHidden()
                    .keyboardType(.default)
                }
                .padding(.top)
            }
            if componentState.type != .br &&
                componentState.type != .hr {
                TableSection(title: componentState.type == .img ? NSLocalizedString("URL", comment: "") : NSLocalizedString("Content", comment: "")) {
                    MyTextEditorView(vc: viewController!)
//                    TextEditor(text: $componentState.string)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                        .padding(.horizontal)
                        .frame(minHeight: 40)
//                        .keyboardType(.default)
                }
            }
            Spacer()
            if componentState.type == .br ||
                componentState.type == .hr ||
                componentState.type == .img {
                Text(NSLocalizedString("Children will be ignored in this element.", comment: ""))
                    .padding(.horizontal)
                    .padding(.top)
            }
            BorderedButton(action: {
                viewController?.updatePreview()
            }) {
                Label(NSLocalizedString("Update Preview", comment: ""), systemImage: "arrow.2.squarepath")
            }
            .animation(.none)
            .padding()
        }
        .animation(.spring())
        .disabled(isTutorial)
    }
}


