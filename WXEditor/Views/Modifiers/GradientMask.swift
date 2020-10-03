//
//  GradientMask.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/29.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct GradientMask: ViewModifier {
    var gradient: LinearGradient
    func body(content: Content) -> some View {
        content
            .foregroundColor(.clear)
            .overlay(
                gradient
                    .mask(content)
            )
    }
}
