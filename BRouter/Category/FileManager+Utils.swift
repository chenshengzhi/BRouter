//
//  FileManager+Utils.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

extension FileManager {
    func isDirectory(_ dir: String) -> Bool {
        var isDir = ObjCBool(booleanLiteral: false)
        let exist = fileExists(atPath: dir, isDirectory: &isDir)
        return exist && isDir.boolValue
    }
    
    func findIn(_ dir: String, folderName: String, depth: Int) -> [String] {
        guard depth >= 0 else {
            return []
        }
        
        guard let contents = try? contentsOfDirectory(atPath: dir) else {
            return []
        }
        
        var result: [String] = []
        for name in contents {
            let subPath = dir.appendingPathComponent(name)
            if name == folderName {
                if isDirectory(subPath) {
                    result.append(subPath)
                }
            }
            
            let subResult = findIn(subPath, folderName: folderName, depth: depth - 1)
            result.append(contentsOf: subResult)
        }
        
        return result
    }
}
