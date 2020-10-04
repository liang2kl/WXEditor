//
//  HTMLGenerator.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import Foundation

class HTMLGenerator {
    var rootComponent: RootComponent
    func generateHTML() -> String {
        let string = """
            <html>
                <head>
                    <meta charset='UTF-8'>
                </head>
                <link rel="stylesheet" type="text/css" href="\(Bundle.main.url(forResource: "style", withExtension: "css")!.absoluteString)">
                <body>
                    \(getComponents())
                </body>
            </html>
            """
        print(string)
        return string
    }
    
    func getComponents() -> String {
        var string: String = ""
        for component in rootComponent.childs {
            string.append(component.makeComponent())
            string.append("\n")
        }
        return string
    }
    
    init() {
        let rootComponent = RootComponent(childs: [])
        let component1 = P(string: "String", parent: rootComponent)
        rootComponent.childs.append(component1)
        let child = P(string: "String", parent: component1)
        component1.childs.append(child)
        self.rootComponent = rootComponent
    }
}
