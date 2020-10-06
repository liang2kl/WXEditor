//
//  HoverButton.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/23.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct BorderedButton<Content>: View where Content: View {
    var color: Color
    @Binding var isFilled: Bool
    @Binding var isDisabled: Bool
    var action: () -> Void
    var content: () -> Content
    var body: some View {
        Button(action: action) {
            content()
                .modifier(ButtonModifier(isFilled: $isFilled, isDisabled: $isDisabled, backgroundColor: color))
        }
        .disabled(isDisabled)
    }
    
    init(color: Color = .tint, action: @escaping () -> Void, isFilled: Binding<Bool> = . constant(true), isDisabled: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping () -> Content) {
        self.color = color
        self.action = action
        self._isFilled = isFilled
        self._isDisabled = isDisabled
        self.content = content
    }
}

