//
//  CircularProgressView.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/21.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct CircularProgressView: View {
    @Binding var progress: Double
    var desiredWidth: CGFloat
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(UIColor.secondarySystemFill), lineWidth: desiredWidth * 0.15)
            CircularPathProgressView(progress: $progress, color: color, lineWidth: desiredWidth * 0.15)
            Text("\(Int(progress * 100)) %")
                .font(.system(size: desiredWidth / 4, weight: .bold, design: .rounded))
        }
        .animation(.spring())
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: desiredWidth, maxHeight: desiredWidth)
    }
    
}

struct CircularPathProgressView: View {
    @Binding var progress: Double
    var color: Color
    var lineWidth: CGFloat
    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(progress))
            .rotation(.init(degrees: -90), anchor: .center)
            .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            .animation(.spring())
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: .constant(0.7), desiredWidth: 100, color: Color("Tint"))
            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
