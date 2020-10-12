//
//  ListCell.swift
//  Whiz
//
//  Created by 梁业升 on 2020/8/14.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct ListCell<BodyView>: View where BodyView: View {
    var title: String
    var systemImageName: String? = nil
    var subTitle: String? = nil
    var showsIndicator: Bool = false
    var footer: String?
    var bodyView: () -> BodyView
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .bold()
                    .modifier(Leading())
                    .fixedSize()
                bodyView()
                    .padding(.leading, 3)
                    .layoutPriority(1)
                if let subTitle = self.subTitle {
                    Text(subTitle)
                        .font(.system(.footnote))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                if showsIndicator {
                    Image(systemName: "chevron.right")
                        .font(.system(.footnote))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
            }
            if let footer = footer {
                Text(footer)
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .padding(.top, 3)
                    .modifier(Trailing())
            }
        }
        .padding()
        .background(
            Color(UIColor.quaternarySystemFill)
                .cornerRadius(12)
        )
        .padding(.top)
    }
    
    init(title: String, systemImageName: String? = nil, subTitle: String? = nil, showsIndicator: Bool = false, footer: String? = nil, @ViewBuilder body: @escaping () -> BodyView) {
        self.title = title
        self.systemImageName = systemImageName
        self.subTitle = subTitle
        self.showsIndicator = showsIndicator
        self.footer = footer
        self.bodyView = body
    }

    
}

struct ListCell_Previews: PreviewProvider {
    static var previews: some View {
        ListCell(title: "Title", systemImageName: "apple", subTitle: "Subtitle", showsIndicator: true) {
            TextField("", text: .constant("text"))
        }
    }
}
