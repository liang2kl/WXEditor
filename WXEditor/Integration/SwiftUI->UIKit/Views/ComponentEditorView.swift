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
            TypePicker(type: $componentState.type)
            if componentState.type != .br {
                ClassEditorView(className: $componentState.className, onCommit: {viewController?.updatePreview()})
            }
            if componentState.type != .br &&
                componentState.type != .hr {
                let title = (componentState.type == .img || componentState.type == .a) ? NSLocalizedString("URL", comment: "") : NSLocalizedString("Content", comment: "")
                TableSection(title: title) {
                    MyTextEditorView(didChange: textEditorDidChange, didFinish: textEditorDidFinish, string: componentState.string)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                        .padding(.horizontal)
                        .frame(minHeight: 80)
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
                    .font(.headline)
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

extension ComponentEditorView {
    struct TypePicker: View {
        @Binding var type: HTMLComponent
        var body: some View {
            Picker("", selection: $type) {
                ForEach(HTMLComponent.allCases) { componentType in
                    if componentType != .root {
                        Label(componentType.head, systemImage: componentType.imageName)
                            .tag(componentType)
                            .font(Font(UIFont.monospacedSystemFont(ofSize: 20, weight: .medium)))
                    }
                }
            }
            .animation(.spring())
            .padding(.horizontal)
            .overlay(
                Text(NSLocalizedString("Type", comment: ""))
                    .sectionTitle()
                    .modifier(TopLeading())
                    .padding(.top)
            )
        }
    }
    
    struct ClassEditorView: View {
        @Binding var className: String
        var onCommit: () -> Void
        var body: some View {
            HStack(alignment: .center) {
                Text(NSLocalizedString("Class", comment: ""))
                    .sectionTitle()
                TextField("No Class", text: $className, onCommit: onCommit)
                    .padding(3)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
                    .padding(.trailing)
                    .padding(.leading, 3)
                    .labelsHidden()
                    .keyboardType(.default)
                    .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)))
            }
            .animation(.spring())
        }
    }
}


extension Text {
    func sectionTitle() -> some View {
        return self
            .font(.title2)
            .bold()
            .padding(.leading)
    }
}
