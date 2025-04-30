//
//  Config.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Cocoa
import Foundation

struct Config: Codable {
    struct Dispatcher: Codable {
        var matchs: [String]
        var browsers: [Browser]
    }
    
    struct Github: Codable {
        var localDirs: [String]
        var menuMatchs: [String]
        var modifiers: [String]?
    }
    
    struct Browser: Codable {
        var appName: String
        var modifiers: [String]?
    }
    
    private(set) static var shared: Config!
    
    static func refresh() {
        shared = load()
    }
    
    private(set) var browserAppName: String?
    private(set) var editor: String?
    private(set) var github: Github?
    private(set) var dispatchers: [Dispatcher]?
}

extension Config {
    static let configFilePath = "~/.config/BRouter/config.js".expandingTildeInPath
    
    static func load() -> Config {
        do {
            guard FileManager.default.fileExists(atPath: configFilePath) else {
                return Config()
            }
            let data = try Data(contentsOf: URL(fileURLWithPath: configFilePath))
            let decoder = JSONDecoder()
            let config = try decoder.decode(Config.self, from: data)
            return config
        } catch {
            print(error)
            
            DispatchQueue.main.async {
                let alert = NSAlert(error: error)
                alert.alertStyle = .critical
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            
            return Config()
        }
    }
}

extension Config {
    static func edit() {
        if let editor = Config.shared.editor {
            let script = """
            tell application "\(editor)"
                activate
                open "\(Config.configFilePath)"
            end tell
            """
            AppleScript.run(script)
        } else {
            runShellAndOutput("open \(Config.configFilePath)")
        }
    }

    static func reveal() {
        runShellAndOutput("open -R \(Config.configFilePath)")
    }
}
