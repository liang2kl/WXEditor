//
//  Component.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import Foundation

enum HTMLComponent: Int, CaseIterable, Identifiable {
    var id: Int { rawValue }
    enum Classification: Int, CaseIterable {
        case paragraph, header, list, otherUseful, other
    }
    case p, section, span, h1, h2, h3, h4, h5, h6, blockquote, ol, ul, li, br, hr, figure, figcaption, img, a, code, pre, footer, div, root
    var head: String {
        switch self {
        case .p: return "p"
        case .span: return "span"
        case .h1: return "h1"
        case .h2: return "h2"
        case .blockquote: return "blockquote"
        case .img: return "img"
        case .footer: return "footer"
        case .br: return "br"
        case .hr: return "hr"
        case .root: return "root"
        case .section: return "section"
        case .h3: return "h3"
        case .h4: return "h4"
        case .h5: return "h5"
        case .h6: return "h6"
        case .ol: return "ol"
        case .ul: return "ul"
        case .li: return "li"
        case .figure: return "figure"
        case .figcaption: return "figcaption"
        case .a: return "a"
        case .code: return "code"
        case .pre: return "pre"
        case .div: return "div"
        }
    }
    var tail: String? {
        switch self {
        case .p: return "p"
        case .span: return "span"
        case .h1: return "h1"
        case .h2: return "h2"
        case .blockquote: return "blockquote"
        case .footer: return "footer"
        case .img: return nil
        case .br: return nil
        case .hr: return nil
        case .root: return nil
        case .section: return "section"
        case .h3: return "h3"
        case .h4: return "h4"
        case .h5: return "h5"
        case .h6: return "h6"
        case .ol: return "ol"
        case .ul: return "ul"
        case .li: return "li"
        case .figure: return "figure"
        case .figcaption: return "figcaption"
        case .a: return "a"
        case .code: return "code"
        case .pre: return "pre"
        case .div: return "div"
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
        case .p: return "paragraphsign"
        case .span: return "text.justify"
        case .root: return ""
        case .footer: return "dock.rectangle"
        case .section: return "text.append"
        case .h3: return "3.square"
        case .h4: return "4.square"
        case .h5: return "5.square"
        case .h6: return "6.square"
        case .ol: return "list.number"
        case .ul: return "list.bullet"
        case .li: return "list.bullet.below.rectangle"
        case .figure: return "squares.below.rectangle"
        case .figcaption: return "ellipsis.rectangle"
        case .a: return "link"
        case .code: return "curlybraces"
        case .pre: return "text.redaction"
        case .div: return "text.append"
        }
    }
    
    var classification: Classification {
        switch self {
        case .p, .section, .span, .blockquote: return .paragraph
        case .h1, .h2, .h3, .h4, .h5, .h6: return .header
        case .ol, .ul, .li: return .list
        case .img, .figcaption, .br, .hr: return .otherUseful
        default: return .other
        }
    }

}

class Component: NSObject, Codable {
    var id: UUID = UUID()
    var className: String = ""
    var childs: [Component] = []
    var parent: Component?
    var string: String?
    var htmlComponent: HTMLComponent = .p
    var nestedInFront = false
    
    init(type: HTMLComponent, id: UUID = UUID(), className: String = "", childs: [Component] = [], string: String? = nil, parent: Component?) {
        self.id = id
        self.childs = childs
        self.string = string
        self.parent = parent
        self.className = className
        self.htmlComponent = type
    }

    
    func makeComponent() -> String {
        let className = self.className == "" ? "" : " class=\"\(self.className)\" "
        if self.htmlComponent == .img {
            return "<img\(className)src=\"\(string ?? "")\">"
        }
        if htmlComponent == .a {
            return "<a\(className)href=\"\(string ?? "")\">"
        }
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
        return
            "<\(htmlComponent.head + className)>" +
            frontString +
            "\(string ?? "")" +
            backString +
            "\(htmlComponent.tail != nil ? "</\(htmlComponent.tail!)>" : "")"

    }
    
    func append(_ newComponent: Component) {
        childs.append(newComponent)
    }
    
    func remove(id: UUID) {
        guard let index = childs.firstIndex(where: {$0.id == id}) else { return }
        childs.remove(at: index)
    }
    
    func remove(at index: Int) {
        childs.remove(at: index)
    }
    
    func insert(_ child: Component, at index: Int) {
        childs.insert(child, at: index)
    }
    
    func componentCopy(parent: Component) -> Component {
        let newComponent = Component(type: self.htmlComponent, className: self.className, childs: [], string: self.string, parent: self.parent)
        let childs = copiedChilds(ofParent: self, newParent: newComponent)
        newComponent.childs = childs
        return newComponent
    }
    
    private func copiedChilds(ofParent parent: Component, newParent: Component) -> [Component] {
        var childs = [Component]()
        for child in parent.childs {
            let newChild = Component(type: child.htmlComponent, className: child.className, childs: [], string: child.string, parent: newParent)
            newChild.childs = copiedChilds(ofParent: child, newParent: newChild)
            childs.append(newChild)
        }
        return childs
    }

    static func getComponent(id: UUID, rootComponent: Component) -> Component? {
        if let component = rootComponent.childs.first(where: {$0.id == id}) {
            return component
        } else {
            for child in rootComponent.childs {
                let component = getComponent(id: id, rootComponent: child)
                if component != nil {
                    return component
                }
            }
        }
        return nil
    }
    
    //MARK: - Codable

    enum CodingKeys: CodingKey {
        case className, childs, parent, string, type, front
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(className, forKey: .className)
        try container.encode(childs, forKey: .childs)
        try container.encode(string, forKey: .string)
        try container.encode(htmlComponent.rawValue, forKey: .type)
        try container.encode(nestedInFront, forKey: .front)
    }

    required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        className = try values.decode(String.self, forKey: .className)
        childs = try values.decode([Component].self, forKey: .childs)
        string = try values.decode((String?).self, forKey: .string)
        htmlComponent = HTMLComponent(rawValue: try values.decode(Int.self, forKey: .type))!
        nestedInFront = try values.decode(Bool.self, forKey: .front)
        for child in childs {
            child.parent = self
        }
    }

}


