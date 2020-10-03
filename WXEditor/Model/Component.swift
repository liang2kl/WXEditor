//
//  Component.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import Foundation

enum HTMLComponent: CaseIterable {
    case p, section, span, h1, h2, blockquote, img, br, hr
    var head: String {
        switch self {
        case .p: return "p"
        case .section: return "section"
        case .span: return "span"
        case .h1: return "h1"
        case .h2: return "h2"
        case .blockquote: return "blockquote"
        case .img: return "img"
        case .br: return "br"
        case .hr: return "hr"
        }
    }
    var tail: String? {
        switch self {
        case .p: return "p"
        case .section: return "section"
        case .span: return "span"
        case .h1: return "h1"
        case .h2: return "h2"
        case .blockquote: return "blockquote"
        case .img: return nil
        case .br: return nil
        case .hr: return nil
        }
    }
    var imageName: String {
        switch self {
        case .h1: return "1.square"
        case .h2: return "2.square"
        case .blockquote: return "text.quote"
        case .br: return "arrow.turn.down.left"
        case .hr: return "minus"
        case .img: return "photo"
        case .section: return "square.dashed"
        case .p: return "text.justify"
        case .span: return "text.justify"
        }
    }

}

protocol Component {
    var id: UUID { get set }
    var childs: [Component] { get set }
    var string: String? { get set }
    var htmlComponent: HTMLComponent { get }
    func makeComponent() -> String
}

extension Component {
    var nestedInFront: Bool { false }
    func makeComponent() -> String {
        let frontChilds = childs.filter({$0.nestedInFront})
        let backChilds = childs.filter({!$0.nestedInFront})
        let frontStrings = frontChilds.map({$0.makeComponent()})
        let backStrings = backChilds.map({$0.makeComponent()})
        var frontString = ""
        var backString = ""
        for string in frontStrings {
            frontString.append(string)
        }
        for string in backStrings {
            backString.append(string)
        }
        return
            "<\(htmlComponent.head)>" +
            frontString +
            "\(string ?? "")" +
            backString +
            "\(htmlComponent.tail != nil ? "</\(htmlComponent.tail!)>" : "")"
    }
}

struct P: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .p
}

struct Section: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .section
}

struct Span: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .span
}

struct H1: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .h1
}

struct H2: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .h2
}

struct BlockQuote: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .blockquote
}

struct IMG: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String?
    var htmlComponent: HTMLComponent = .img
    func makeComponent() -> String {
        return "<img src=\"\(string ?? "")\">"
    }
    
    init(url: String, id: UUID?) {
        self.string = url
        self.id = id ?? UUID()
    }
}

struct BR: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String? = nil
    var htmlComponent: HTMLComponent = .br
}

struct HR: Component {
    var id: UUID = UUID()
    var childs: [Component] = []
    var string: String? = nil
    var htmlComponent: HTMLComponent = .hr
}
