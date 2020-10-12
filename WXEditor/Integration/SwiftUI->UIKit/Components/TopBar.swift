//
//  TopBar.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/22.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct TopBar: View {
    var title: String
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .bold()
                .lineLimit(1)
                .modifier(CenterHorizontally())
                .padding(.horizontal)
                .padding(.top)
            Divider()
        }
    }
}
