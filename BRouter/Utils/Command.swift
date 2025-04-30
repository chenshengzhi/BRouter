//
//  Command.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

struct Command {
    static let git = Command(name: "git")
    static let grep = Command(name: "grep")
    static let pod = Command(name: "pod")
    static let mkdir = Command(name: "mkdir")
    static let cp = Command(name: "cp")
    
    let commandPath: String
    
    init(name: String) {
        commandPath = Self.commandPath(forName: name)
    }
    
    init(commandPath: String) {
        self.commandPath = commandPath
    }
}

private extension Command {
    static func commandPath(forName name: String) -> String {
        let (_, result) = runShellAndOutput("/usr/bin/which \(name)")
        guard let result = result,
              let first = result.trim().split(separator: "\n").first,
              first.contains(name) else {
            return name
        }
        return String(first)
    }
}

extension Command: CustomStringConvertible {
    var description: String {
        return commandPath
    }
}
