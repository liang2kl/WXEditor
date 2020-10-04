//
//  EditorView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import SwiftUI

struct ComponentEditorView: View {
    @ObservedObject var componentState: ComponentState
    var viewController: ComponentEditorViewController?
    var body: some View {
        VStack {
            TableSection(title: NSLocalizedString("Type", comment: "")) {
                Picker("", selection: $componentState.type) {
                    ForEach(HTMLComponent.allCases) { componentType in
                        Label(componentType.head, systemImage: componentType.imageName)
                            .tag(componentType)
                    }
                }
                .padding(.horizontal)
            }
            if componentState.type != .br &&
                componentState.type != .hr {
                TableSection(title: componentState.type == .img ? NSLocalizedString("URL", comment: "") : NSLocalizedString("Content", comment: "")) {
                    TextEditor(text: $componentState.string)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                        .padding(.horizontal)
                        .frame(minHeight: 100)
                }
            }
            if componentState.type == .br ||
                componentState.type == .hr ||
                componentState.type == .img {
                Text(NSLocalizedString("Children will be ignored in this component.", comment: ""))
                    .padding()
            }
            Spacer()
            BorderedButton(action: {
                viewController?.updatePreview()
            }) {
                Label(NSLocalizedString("Update Preview", comment: ""), systemImage: "checkmark")
            }
            .padding()
        }
    }
}


