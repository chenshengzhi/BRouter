//
//  URL+Regex.swift
//  BRouter
//
//  Created by csz on 2023/9/2.
//

import Foundation

extension URL {
    func match(format: String) -> Bool {
        var patten = format.replacingOccurrences(of: ".", with: "\\.")
        patten = patten.replacingOccurrences(of: "*", with: ".*")
        do {
            let regex = try Regex(patten)
            if absoluteString.contains(regex) {
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    func matchAny(formats: [String]) -> Bool {
        for format in formats {
            if match(format: format) {
                return true
            }
        }
        return false
    }
}
