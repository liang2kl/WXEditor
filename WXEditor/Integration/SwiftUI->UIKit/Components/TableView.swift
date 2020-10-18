//
//  TableView.swift
//  Whiz
//
//  Created by 梁业升 on 2020/8/14.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

fileprivate let minWidth: CGFloat = 175
fileprivate let maxWidth: CGFloat = 300
fileprivate let proposedWidth: CGFloat = 200
fileprivate let cornerRadius: CGFloat = 15

struct TableSection<Content>: View where Content: View {
    var title: String
    var displaysEditButton: Bool
    @Binding var isEditing: Bool
    var content: () -> Content
    var body: some View {
        TableHeader(title: title, displaysEditButton: displaysEditButton, isEditing: $isEditing)
        content()
    }
    
    init(title: String, displaysEditButton: Bool = false, isEditing: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.displaysEditButton = displaysEditButton
        self._isEditing = isEditing
        self.content = content
    }
}

fileprivate struct TableHeader: View {
    var title: String
    var displaysEditButton: Bool
    @Binding var isEditing: Bool
    var body: some View {
        HStack {
            Text(title)
                .font(Font(UIFont.monospacedSystemFont(ofSize: 22, weight: .bold) as CTFont))
                .bold()
            Spacer()
            if displaysEditButton {
                Button(action: {
                    isEditing.toggle()
                }) {
                    if isEditing {
                        Text(NSLocalizedString("Done", comment: ""))
                            .bold()
                            .accentColor(.tint)
                    } else {
                        Text(NSLocalizedString("Edit", comment: ""))
                            .accentColor(.tint)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}


struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableHeader(title: "Title", displaysEditButton: true, isEditing: .constant(true))
    }
}
