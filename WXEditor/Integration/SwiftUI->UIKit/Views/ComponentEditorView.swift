//
//  EditorView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import SwiftUI

struct ComponentEditorView: View {
    @ObservedObject var componentState: ComponentState
    @State var isEditingClassAndStyles: Bool = false
    var isTutorial: Bool = false
    var viewController: ComponentEditorViewController?
    var body: some View {
        VStack(spacing: 0) {
            if !isEditingClassAndStyles {
                TypePicker(type: $componentState.type)
            }
            ClassAndStylesView(isEditing: $isEditingClassAndStyles, className: $componentState.className, styles: $componentState.styles, updatePreview: {viewController?.updatePreview()})
                .padding(.top)
                .padding(.bottom, isEditingClassAndStyles ? nil : 0)
                .animation(.default)
            if componentState.type != .br &&
                componentState.type != .hr {
                if isEditingClassAndStyles {
                    ClassAndStylesEditorView(showsClassEditor: componentState.type != .br, className: $componentState.className, styles: $componentState.styles, updatePreview: {viewController?.updatePreview()})
                        .animation(.default)
                } else {
                    let title = (componentState.type == .img || componentState.type == .a) ? NSLocalizedString("URL", comment: "") : NSLocalizedString("Content", comment: "")
                    TableSection(title: title) {
                        MyTextEditorView(didChange: textEditorDidChange, didFinish: textEditorDidFinish, string: componentState.string)
                            .bordered()
                            .padding(.horizontal)
                            .padding(.top)
                            .frame(minHeight: 80)
                    }
                    .animation(.default)
                }
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
        viewController!.updateComponent(component: viewController!.component, type: componentState.type, className: componentState.className, string: string, styles: componentState.styles, refreshSideBar: false)
    }
    
    func textEditorDidFinish() {
        viewController!.updateSideBar(id: viewController!.component.id)
        viewController?.updatePreview()
    }
    
}

extension ComponentEditorView {
    struct ClassAndStylesEditorView: View {
        var showsClassEditor: Bool
        @Binding var className: String
        @Binding var styles: String
        var updatePreview: () -> Void
        var body: some View {
            VStack {
                if showsClassEditor {
                    TextFieldView(string: $className, title: "Class", onCommit: updatePreview)
                        .padding(.vertical, 5)
                }
                Text(NSLocalizedString("Styles", comment: ""))
                    .sectionTitle()
                    .modifier(Leading())
                MyTextEditorView(didChange: { string in styles = string }, didFinish: updatePreview, string: styles)
                    .bordered()
                    .padding(.horizontal)
            }
        }
    }
    
    struct ClassAndStylesView: View {
        @Binding var isEditing: Bool
        @Binding var className: String
        @Binding var styles: String
        var updatePreview: () -> Void
        var body: some View {
            HStack {
                if isEditing {
                    Text(NSLocalizedString("Class And Styles", comment: ""))
                        .sectionTitle()
                } else {
                    let classString = className == "" ? "None" : className
                    let styleString = styles == "" ? "None" : styles.replacingOccurrences(of: "\n", with: " ")
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Class ")
                                .bold()
                            Text(classString)
                                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)))
                                .foregroundColor(className == "" ? .gray : nil)
                                .lineLimit(1)
                        }
                        HStack {
                            Text("Styles ")
                                .bold()
                            Text(styleString)
                                .font(Font(UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)))
                                .foregroundColor(styles == "" ? .gray : nil)
                                .lineLimit(1)
                        }
                    }
                    .padding(.leading)
                }
                Spacer()
                Button(action: {
                    isEditing.toggle()
                    if !isEditing {
                        updatePreview()
                    }
                }) {
                    if !isEditing {
                        Text(NSLocalizedString("Edit", comment: ""))
                    } else {
                        Text(NSLocalizedString("Done", comment: ""))
                            .bold()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
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
    
    struct TextFieldView: View {
        @Binding var string: String
        var title: String
        var onCommit: () -> Void
        var body: some View {
            HStack(alignment: .center) {
                Text(NSLocalizedString(title, comment: ""))
                    .sectionTitle()
                TextField("No Class", text: $string, onCommit: onCommit)
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

extension MyTextEditorView {
    func bordered() -> some View {
        return self
            .overlay(RoundedRectangle(cornerRadius: 5).stroke().foregroundColor(Color(UIColor.systemFill)))
    }
}
