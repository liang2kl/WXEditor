//
//  Component.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import Foundation

enum HTMLComponent: Int, CaseIterable, Identifiable {
    var id: Int { rawValue }
    
    case p, span, section, h1, h2, blockquote, img, br, hr
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
        case .p: return "paragraphsign"
        case .span: return "text.justify"
        }
    }

}

protocol Component {
    var id: UUID { get set }
    var className: String { get set }
    var childs: [Component] { get set }
    var parent: Component? { get set }
    var string: String? { get set }
    var htmlComponent: HTMLComponent { get }
    func makeComponent() -> String
}

extension Component {
    var nestedInFront: Bool { false }
    func makeComponent() -> String {
        var frontString = ""
        var backString = ""
        if htmlComponent != .img &&
            htmlComponent != .hr &&
            htmlComponent != .br {
            let frontChilds = childs.filter({$0.nestedInFront})
            let backChilds = childs.filter({!$0.nestedInFront})
            let frontStrings = frontChilds.map({$0.makeComponent()})
            let backStrings = backChilds.map({$0.makeComponent()})
            for string in frontStrings {
                frontString.append(string)
            }
            for string in backStrings {
                backString.append(string)
            }
        }
        let className = self.className == "" ? "" : "class=\"\(self.className)\""
        return
            "<\(htmlComponent.head + className)>" +
            frontString +
            "\(string ?? "")" +
            backString +
            "\(htmlComponent.tail != nil ? "</\(htmlComponent.tail!)>" : "")"
    }
    
    mutating func append(_ newComponent: Component) {
        childs.append(newComponent)
    }
    
    mutating func remove(id: UUID) {
        guard let index = childs.firstIndex(where: {$0.id == id}) else { return }
        childs.remove(at: index)
    }
}

class RootComponent: Component {
    var id: UUID = UUID()
    var className: String = ""
    var childs: [Component]
    var parent: Component? = nil
    var string: String?
    var htmlComponent: HTMLComponent = .hr
    
    init(childs: [Component]) {
        self.childs = childs
    }
}

class P: Component {
    var id: UUID
    var className: String
    var childs: [Component]
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .p
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
    }
}

class Section: Component {
    var id: UUID
    var className: String
    var childs: [Component]
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .section
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
    }
}

class Span: Component {
    var id: UUID
    var className: String
    var childs: [Component]
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .span
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
    }
}

class H1: Component {
    var id: UUID
    var className: String
    var childs: [Component]
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .h1
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
    }
}

class H2: Component {
    var id: UUID
    var className: String
    var childs: [Component]
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .h2
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
    }
}

class BlockQuote: Component {
    var id: UUID
    var className: String
    var childs: [Component]
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .blockquote
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
    }
}

class IMG: Component {
    var id: UUID = UUID()
    var className: String
    var childs: [Component] = []
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .img
    func makeComponent() -> String {
        let className = self.className == "" ? "" : "class=\"\(self.className)\""
        print("<img \(className) src=\"\(string ?? "")\">")
        return "<img \(className) src=\"\(string ?? "")\">"
    }
    
    init(url: String = "", id: UUID = UUID(), className: String = "", childs: [Component] = [], parent: Component) {
        self.string = url
        self.id = id
        self.childs = childs
        self.parent = parent
        self.className = className
    }
}

class BR: Component {
    var id: UUID
    var childs: [Component] = []
    var className: String = ""
    var parent: Component?
    var string: String? = nil
    var htmlComponent: HTMLComponent = .br
    init(id: UUID = UUID(), childs: [Component] = [], parent: Component) {
        self.id = id
        self.parent = parent
        self.childs = childs
    }
}

class HR: Component {
    var id: UUID
    var className: String
    var childs: [Component] = []
    var parent: Component?
    var string: String? = nil
    var htmlComponent: HTMLComponent = .hr
    init(id: UUID = UUID(), className: String = "", childs: [Component] = [], parent: Component) {
        self.id = id
        self.parent = parent
        self.childs = childs
        self.className = className
    }
}
