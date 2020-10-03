//
//  CardModifier.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/21.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct CardModifier: ViewModifier {
    @Binding var isSelected: Bool
    @Binding var isDisabled: Bool
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(Color(isSelected ? UIColor(named: "Tint")! : UIColor(named: "card")!))
            .modifier(Disabled(isDisabled: $isDisabled))
            .cornerRadius(cornerRadius)
            .padding()
            .shadow(radius: 7.5)
    }
}

