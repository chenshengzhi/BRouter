//
//  String+Utils.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

extension String {
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var pathExtension: String {
        (self as NSString).pathExtension
    }
    
    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }
    
    var deletingLastPathComponent: String {
        (self as NSString).deletingLastPathComponent
    }
    
    var lastPathComponent: String {
        (self as NSString).lastPathComponent
    }
    
    var expandingTildeInPath: String {
        (self as NSString).expandingTildeInPath
    }
    
    func appendingPathComponent(_ component: String) -> String {
        (self as NSString).appendingPathComponent(component)
    }
}
