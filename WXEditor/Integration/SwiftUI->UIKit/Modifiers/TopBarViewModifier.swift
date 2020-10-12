//
//  TopBarViewModifier.swift
//  Whiz
//
//  Created by 梁业升 on 2020/9/19.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct TopBarViewModifier: ViewModifier {
    var title: String
    var topSpacing: Bool = true
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            TopBar(title: title)
            if UIDevice.current.userInterfaceIdiom == .phone {
                content
            } else {
                if topSpacing {
                    VStack(spacing: 0) {
                        content
                    }
                    .padding(8)
                } else {
                    VStack(spacing: 0) {
                        content
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                }
            }
        }
        
    }
}
