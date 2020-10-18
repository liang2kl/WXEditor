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
                                .font(Font(UIFont.monospacedSystemFont(ofSize: 20, weight: .medium) as CTFont))
                        }
                    }
                }
                .animation(.spring())
                .padding(.horizontal)
            }
            if componentState.type != .br {
                HStack(alignment: .center) {
                    Text(NSLocalizedString("Class", comment: ""))
                        .bold()
                        .padding(.leading)
                        .font(Font(UIFont.monospacedSystemFont(ofSize: 22, weight: .bold) as CTFont))
                    TextField("No Class", text: $componentState.className, onCommit: {
                        viewController?.updatePreview()
                    })
                    .padding(3)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                    .padding(.trailing)
                    .labelsHidden()
                    .keyboardType(.default)
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular) as CTFont))
                }
                .animation(.spring())
                .padding(.top)
            }
            if componentState.type != .br &&
                componentState.type != .hr {
                let title = (componentState.type == .img || componentState.type == .a) ? NSLocalizedString("URL", comment: "") : NSLocalizedString("Content", comment: "");
                TableSection(title: title) {
                    MyTextEditorView(didChange: {textEditorDidChange(string: $0)}, didFinish: textEditorDidFinish, string: componentState.string)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                        .padding(.horizontal)
                        .frame(minHeight: 40)
                }
                .animation(.spring())
            }
            Spacer()
            if componentState.type == .br ||
                componentState.type == .hr ||
                componentState.type == .img {
                Text(NSLocalizedString("Nested elements will be ignored.", comment: ""))
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .animation(.spring())
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 14, weight: .regular) as CTFont))
                    .lineLimit(1)
            }
            BorderedButton(action: {
                viewController?.updatePreview()
            }) {
                Label(NSLocalizedString("Update Preview", comment: ""), systemImage: "arrow.2.squarepath")
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .semibold) as CTFont))
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
        .disabled(isTutorial)
    }
}

extension ComponentEditorView {
    func textEditorDidChange(string: String) {
        viewController!.updateComponent(component: viewController!.component, type: componentState.type, className: componentState.className, string: string, refreshSideBar: false)
    }
    
    func textEditorDidFinish() {
        viewController!.updateSideBar(id: viewController!.component.id)
        viewController?.updatePreview()
    }
    
}
