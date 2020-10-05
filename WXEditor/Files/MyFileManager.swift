//
//  MyFileManager.swift
//  Whiz
//
//  Created by 梁业升 on 2020/8/13.
//  Copyright © 2020 梁业升. All rights reserved.
//

import Foundation

class MyFileManager {
    let fileManager = FileManager.default
    var url: URL
    
    func directoryUrls() throws -> [URL] {
        do {
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter({$0.hasDirectoryPath})
            do {
                let sortedUrls = try urlsSortedByModificationDate(urls)
                return sortedUrls
            } catch {
                print(error)
                return urls
            }
        } catch {
            print(error)
        }
        return []
    }
    
    func urls(forType typeName: String) throws -> [URL] {
        do {
            let urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter({$0.pathExtension == typeName})
            do {
                let sortedUrls = try urlsSortedByModificationDate(urls)
                return sortedUrls
            } catch {
                print(error)
                return urls
            }
        } catch {
            print(error)
        }
        return []
    }
    
    func urls(exceptTypes typeNames: [String]) throws -> [URL] {
            do {
                var urls = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                for typeName in typeNames {
                    urls.removeAll(where: {$0.pathExtension == typeName})
                }
                urls.removeAll(where: {$0.hasDirectoryPath})
                let sortedUrls = try urlsSortedByModificationDate(urls)
                return sortedUrls
            } catch {
                print(error)
            }
        return []
    }
    
    private func urlsSortedByModificationDate(_ urls: [URL]) throws -> [URL] {
        do {
            let sortedUrls = try urls.sorted(by: { try $0.resourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate! >  $1.resourceValues(forKeys:[.contentModificationDateKey]).contentModificationDate!})
            return sortedUrls
        } catch {
            print(error)
            return urls
        }
    }
    
    func availableURL(directoryURL: URL) throws -> URL {
        var isNamed = true
        let lastPathComponent = directoryURL.lastPathComponent
        var desUrl = self.url.appendingPathComponent(lastPathComponent)
        while isNamed {
            do {
                _ = try desUrl.checkResourceIsReachable()
                let directoryName = desUrl.lastPathComponent
                let newName = copyName(directoryName)
                desUrl = self.url.appendingPathComponent(newName)
            } catch {
                isNamed = false
            }
        }

        return desUrl
    }
    
    func availableURL(forURL url: URL) throws -> URL {
        var isNamed = true
        var lastPathComponent = url.lastPathComponent
        let exten = url.pathExtension
        var desUrl = self.url.appendingPathComponent(lastPathComponent)
        while isNamed {
            do {
                _ = try desUrl.checkResourceIsReachable()
                let fileName = desUrl.deletingPathExtension().lastPathComponent
                let newName = copyName(fileName)
                lastPathComponent = newName + "." + exten
                desUrl = self.url.appendingPathComponent(lastPathComponent)
            } catch {
                isNamed = false
            }
        }
        return desUrl
    }
    
    private func copyName(_ name: String) -> String {
        let length = lengthOfIndex(of: name)
        let last = String(name.suffix(length + 1))
        
        if name.count >= 3, last.prefix(1) == "#", let num = Int(name.suffix(length)) {
            var newName = name
            newName.removeLast(length)
            newName.append(String(num + 1))
            return newName
        } else {
            let newName = name.appending(" #1")
            return newName
        }
    }
    
    private func lengthOfIndex(of name: String) -> Int {
        var finalIndex = 0
        var bit = 0
        for i in 1...name.count {
            let last = name.suffix(i)
            if let index = Int(last) {
                finalIndex = index
                continue
            } else {
                break
            }
        }
        while finalIndex != 0 {
            finalIndex = Int(finalIndex / 10)
            bit += 1
        }
        return bit
    }
    
    func addFiles(_ urls: [URL], type: FileProcessType) throws {
        for url in urls {
            let desUrl = self.url.appendingPathComponent(url.lastPathComponent)
            print(url.lastPathComponent)
            do {
                var finalDesUrl = try availableURL(forURL: desUrl)
                _ = url.startAccessingSecurityScopedResource()
                if type == .copy {
                    try fileManager.copyItem(at: url, to: finalDesUrl)
                    finalDesUrl.setModificationDate()
                } else {
                    try fileManager.moveItem(at: url, to: finalDesUrl)
                    finalDesUrl.setModificationDate()
                }
                url.stopAccessingSecurityScopedResource()
            } catch {
                print(error)
            }
            
        }
    }
    
    func createFile(from data: Data, fileName: String, pathExtension: String) throws -> URL? {
        do {
            let desUrl = self.url.appendingPathComponent(fileName).appendingPathExtension(pathExtension)
            var finalUrl = try availableURL(forURL: desUrl)
            fileManager.createFile(atPath: finalUrl.path, contents: data, attributes: nil)
            finalUrl.setModificationDate()
            return finalUrl
        } catch {
            print(error)
            return nil
        }
    }
    
    func newFolder(name: String) throws {
        let url = self.url.appendingPathComponent(name, isDirectory: true)
        do {
            var finalUrl = try availableURL(directoryURL: url)
            try fileManager.createDirectory(at: finalUrl, withIntermediateDirectories: false)
            finalUrl.setModificationDate()
            print(finalUrl)
        } catch {
            print(error)
        }
    }
    
    
    func rename(url: URL, newName: String) throws {
        guard newName != "" && newName != url.deletingPathExtension().lastPathComponent else { return }
        let desUrl = self.url.appendingPathComponent(newName).appendingPathExtension(url.pathExtension)
        do {
            var finalDesUrl = try self.availableURL(forURL: desUrl)
            try self.fileManager.moveItem(at: url, to: finalDesUrl)
            finalDesUrl.setModificationDate()
        } catch {
            print(error)
        }
    }
    
    func delete(_ urls: [URL]) throws {
        for url in urls {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print(error)
            }
        }
    }
    
    
    init(url: URL) {
        self.url = url
    }
}

extension MyFileManager {
    enum FileProcessType { case copy, move }
}

extension URL {
    mutating func setModificationDate() {
        do {
            var resourceValue = URLResourceValues()
            resourceValue.contentModificationDate = Date()
            try self.setResourceValues(resourceValue)
        } catch {
            print(error)
        }
    }
}

