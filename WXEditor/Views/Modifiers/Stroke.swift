//
//  Stroke.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/21.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct Stroke: ViewModifier {
    @Binding var cornerRadius: CGFloat
    var lineWidth: CGFloat
    var color: Color
    func body(content: Content) -> some View {
        ZStack {
            content
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(lineWidth: lineWidth)
                .foregroundColor(color)
        }
    }
}
