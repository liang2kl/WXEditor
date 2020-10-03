//
//  LabelButtonView.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/22.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct LabelButtonView: View {
    var text: String
    var imageName: String
    @Binding var isFilled: Bool
    @Binding var isDisabled: Bool
    var body: some View {
        Group {
            Image(systemName: imageName)
            Text(text)
                .bold()
                .lineLimit(1)
        }
        .modifier(ButtonModifier(isFilled: $isFilled, isDisabled: $isDisabled))
    }
}

