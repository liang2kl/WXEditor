//
//  Component.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import Foundation

enum HTMLComponent: Int, CaseIterable, Identifiable {
    var id: Int { rawValue }
    
    case p, span, section, h1, h2, blockquote, img, footer, br, hr, root
    var head: String {
        switch self {
        case .p: return "p"
        case .section: return "section"
        case .span: return "span"
        case .h1: return "h1"
        case .h2: return "h2"
        case .blockquote: return "blockquote"
        case .img: return "img"
        case .footer: return "footer"
        case .br: return "br"
        case .hr: return "hr"
        case .root: return "root"
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
        case .footer: return "footer"
        case .img: return nil
        case .br: return nil
        case .hr: return nil
        case .root: return nil
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
        case .root: return ""
        case .footer: return "text.append"
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


