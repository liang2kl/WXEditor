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
            Group {
                Text("<")
                    .font(.custom("Menlo", size: 15, relativeTo: .body))
                    .foregroundColor(.gray)
                Text("Editor")
                    .font(.custom("Menlo", size: 15, relativeTo: .body))
                Text(">")
                    .font(.custom("Menlo", size: 15, relativeTo: .body))
                    .foregroundColor(.gray)
            }
            Text(NSLocalizedString("Select an Element", comment: ""))
                .font(.custom("Menlo", size: 15, relativeTo: .body))
                .bold()
            Group {
                Text("</")
                    .font(.custom("Menlo", size: 15, relativeTo: .body))
                    .foregroundColor(.gray)
                Text("Editor")
                    .font(.custom("Menlo", size: 15, relativeTo: .body))
                Text(">")
                    .font(.custom("Menlo", size: 15, relativeTo: .body))
                    .foregroundColor(.gray)
            }

        }
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankView()
    }
}
