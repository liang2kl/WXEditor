//
//  BlankView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/4.
//

import SwiftUI

struct BlankView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("<")
                .foregroundColor(.gray)
            Text("Editor")
            Text(">")
                .foregroundColor(.gray)
            Text(NSLocalizedString("Select an Element", comment: ""))
                .bold()
            Text("</")
                .foregroundColor(.gray)
            Text("Editor")
            Text(">")
                .foregroundColor(.gray)
            
        }
        .font(Font(UIFont.monospacedSystemFont(ofSize: 15, weight: .regular) as CTFont))
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankView()
    }
}
