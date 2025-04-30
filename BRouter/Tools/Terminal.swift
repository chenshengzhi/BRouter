//
//  Terminal.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

protocol TerminalProtocol {
    static var appName: String { get }
    static func launchAndWriteText(_ text: String)
}

struct iTerm: TerminalProtocol {
    static var appName: String {
        "iTerm"
    }
    
    static func launchAndWriteText(_ text: String) {
        let name = appName
        
        let script = """
        tell application "System Events"
            set isRunning to (count of (every process whose name is "\(name)")) > 0
        end tell
        
        if not isRunning then
            tell application "\(name)"
                activate
            end tell
        end if
        
        tell application "\(name)"
            tell current window
                create tab with default profile
            end tell
            tell current session of current window
                \(text)
            end tell
        end tell
        """
        
        AppleScript.run(script)
    }
}
