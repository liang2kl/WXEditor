//
//  FileGenerator.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/4.
//

import Foundation

struct FileGenerator {
    static func generate(fromRoot rootComponent: Component) -> Data? {
        do {
            let data = try JSONEncoder().encode(rootComponent)
            return data
        } catch {
            print(error)
        }
        return nil
    }
    
    static func read(_ data: Data) -> Component? {
        do {
            let rootComponent = try JSONDecoder().decode(Component.self, from: data)
            return rootComponent
        } catch {
            print(error)
        }
        return nil
    }
}
