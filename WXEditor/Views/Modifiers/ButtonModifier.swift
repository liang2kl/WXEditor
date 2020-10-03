//
//  ButtonModifier.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/22.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    @Binding var isFilled: Bool
    @Binding var isDisabled: Bool
    var backgroundColor: Color = Color(UIColor(named: "Tint")!)
    var foregroundColor = Color(UIColor.systemBackground)
    static let cornerRadius: CGFloat = 12
    func body(content: Content) -> some View {
        content
            .modifier(CenterHorizontally())
            .font(.headline)
            .foregroundColor(isFilled ? foregroundColor : backgroundColor)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: ButtonModifier.cornerRadius)
                    .conditionalStroke(!isFilled, lineWidth: 3)
                    .foregroundColor(backgroundColor)
            )
            .modifier(Disabled(isDisabled: $isDisabled))
            .cornerRadius(ButtonModifier.cornerRadius)
    }
}

extension RoundedRectangle {
    func conditionalStroke(_ set: Bool, lineWidth: CGFloat) -> some View {
        Group {
            if set {
                self.strokeBorder(style: .init(lineWidth: lineWidth))
            } else {
                self
            }
        }
    }
}
