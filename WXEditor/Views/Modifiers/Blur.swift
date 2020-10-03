//
//  Blur.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/21.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct Blur: ViewModifier {
    var style: UIBlurEffect.Style
    var ignoreSafeArea: Bool = false
    @Binding var shown: Bool
    func body(content: Content) -> some View {
        ZStack {
            if shown {
                BlurView(style: style)
            }
            content
        }
    }
}
