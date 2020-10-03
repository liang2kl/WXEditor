//
//  EditorView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import SwiftUI

struct EditorView: View {
    var type: HTMLComponent
    @State var text: String = ""
    var body: some View {
        Group {
            HStack {
                ScrollView {
                    TableSection(title: NSLocalizedString("Configure Component", comment: "")) {
                        ListCell(title: NSLocalizedString("Text", comment: "")) {
                            TextEditor(text: $text)
                        }
                        .padding(.horizontal)
                        ListCell(title: NSLocalizedString("Children", comment: ""), showsIndicator: true) {
                            Button(action: {
                                
                            }) {
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(type: .blockquote)
    }
}
