//
//  Layout.swift
//  Whiz
//
//  Created by 梁业升 on 2020/7/20.
//  Copyright © 2020 梁业升. All rights reserved.
//

import SwiftUI

struct CenterHorizontally: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct CenterVertically: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            content
            Spacer()
        }
    }
}


struct Leading: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct Trailing: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

struct BottomTrailing: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                content
            }
        }
    }
}

struct Top: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            content
            Spacer()
        }
    }
}

struct TopLeading: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            HStack {
                content
                Spacer()
            }
            Spacer()
        }
    }
}


struct ExpandToFullScreen: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}
