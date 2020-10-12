//
//  CircularButton.swift
//  Whiz
//
//  Created by 梁业升 on 2020/8/17.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct CircularButton: View {
    var imageName: String
    var imageColor: Color? = .tint
    var backgroundColor: Color = Color(UIColor.systemGray3)
    var shadowed = false
    var preferredWidth: CGFloat
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(imageColor)
                .background(
                    Circle()
                        .foregroundColor(backgroundColor)
                        .scaleEffect(sqrt(2) * 1.5)
                        .shadow(radius: shadowed ? preferredWidth / 8 : 0)
                )
        }
        .frame(width: preferredWidth, height: preferredWidth)
    }
}

//struct CircularButton_Previews: PreviewProvider {
//    static var previews: some View {
//    }
//}
