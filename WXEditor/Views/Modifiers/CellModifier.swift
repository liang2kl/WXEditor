//
//  CellModifier.swift
//  Whiz
//
//  Created by 梁业升 on 2020/9/19.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct CellModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    func body(content: Content) -> some View {
        content
            .background(
                Color(UIColor.quaternarySystemFill)
                    .cornerRadius(cornerRadius)
            )
    }
}
