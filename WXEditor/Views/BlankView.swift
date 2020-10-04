//
//  BlankView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/4.
//

import SwiftUI

struct BlankView: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.left.slash.chevron.right")
                .font(.system(size: 25, weight: .bold, design: .rounded))
                .foregroundColor(Color(UIColor.tint))
                .padding()
            Text(NSLocalizedString("Select a Component", comment: ""))
                .font(.system(.headline, design: .rounded))
        }
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankView()
    }
}
