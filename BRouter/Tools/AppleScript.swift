//
//  AppleScript.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

struct AppleScript {
    static func run(_ script: String) {
        DispatchQueue.global().async {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
}
