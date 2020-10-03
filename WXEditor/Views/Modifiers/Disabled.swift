//
//  Disabled.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/20.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct Disabled: ViewModifier {
    @Binding var isDisabled: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            if isDisabled {
                Color("disabled")
            }
        }
        .disabled(isDisabled)
    }
}
