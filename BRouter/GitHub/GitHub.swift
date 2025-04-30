//
//  GitHub.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import AppKit
import Foundation
import RegexBuilder

struct GitHub {
    private(set) static var repoMap: [String: String] = [:]
    private(set) static var lastVc: NSWindowController?
    
    static func refresh() {
        Config.shared.github?.localDirs.forEach { dir in
            let directory = dir.expandingTildeInPath
            let result = FileManager.default.findIn(directory, folderName: ".git", depth: 1)
            result.forEach { path in
                let dir = path.deletingLastPathComponent
                let command = "\(Command.git) -C \(dir) config --get remote.origin.url"
                let (code, result) = runShellAndOutput(command)
                guard code == 0, let https = result?.trim() else {
                    return
                }
                let identity = GitHub.identityFromURLString(https)
                repoMap[identity] = dir
            }
        }
    }
}

// MARK: - public
extension GitHub {
    static func shouldIntercept(_ url: URL) -> Bool {
        return url.host() == "github.com"
    }
    
    static func allowedActions(for url: URL) -> [GitHub.Action] {
        if isPullRequest(url: url) {
            return GitHub.Action.allCases
        } else {
            return [
                .directory, .openWeb,
            ]
        }
    }
}

extension GitHub: Intercepter {
    func perform(url: URL) {
        guard let config = Config.shared.github else {
            Router.openWeb(url: url)
            return
        }
        
        guard KeyboardMonitor.shared.match(modifiers: config.modifiers) else {
            Router.openWeb(url: url)
            return
        }
        
        guard url.matchAny(formats: config.menuMatchs) else {
            Router.openWeb(url: url)
            return
        }
        
        Self.lastVc?.close()
        let windowController = GitHubWindowController(url: url)
        windowController.showWindow(nil)
        Self.lastVc = windowController
    }
}

// MARK: - private
fileprivate extension GitHub {
    static func directory(for url: URL) -> String {
        let identity = identityFromURLString(url.absoluteString)
        if let dir = repoMap[identity] {
            return dir
        }
        return "~"
    }
    
    static func prID(from url: URL) -> String {
        let path = url.path()
        let regex = Regex {
            "/pull/"
            Capture {
                OneOrMore(.digit)
            }
        }
        if let result = try? regex.firstMatch(in: path) {
            return String(result.1)
        }
        return ""
    }
    
    static func identityFromURLString(_ urlString: String) -> String {
        var https = urlString
        https = https.replacingOccurrences(of: "git@github.com:", with: "")
        https = https.replacingOccurrences(of: "https://github.com/", with: "")
        let suffix = ".git"
        if https.hasSuffix(suffix) {
            https = String(https.dropLast(suffix.count))
        }
        let components = https.components(separatedBy: "/")
        if components.count >= 2 {
            return components[0 ..< 2].joined(separator: "/")
        } else {
            return components.joined(separator: "/")
        }
    }
    
    static func isPullRequest(url: URL) -> Bool {
        return url.path().contains("/pull/")
    }
}

// MARK: - github action
extension GitHub {
    enum Action: String, CaseIterable {
        case openWeb = "Open Web"
        case directory = "Directory"
        case view = "View PR"
        case diff = "Diff PR"
        case approve = "Approve PR"
        case merge = "Merge PR"
        case mergeAndDelete = "Merge PR (-d)"
    }
}

extension GitHub.Action {
    func perform(_ url: URL) {
        switch self {
        case .directory:
            Self.gotoDirectory(url: url)
        case .view:
            Self.viewPR(url: url)
        case .diff:
            Self.diffPR(url: url)
        case .approve:
            Self.approve(url: url)
        case .merge:
            Self.merge(url: url, deleteBranch: false)
        case .mergeAndDelete:
            Self.merge(url: url, deleteBranch: true)
        case .openWeb:
            Router.openWeb(url: url)
        }
    }
    
    static func gotoDirectory(url: URL) {
        let directory = GitHub.directory(for: url)
        let fullDirectory = directory.expandingTildeInPath
        
        let text = """
            write text "cd \(fullDirectory)"
        """
        iTerm.launchAndWriteText(text)
    }
    
    static func viewPR(url: URL) {
        let directory = GitHub.directory(for: url)
        let fullDirectory = directory.expandingTildeInPath
        let prID = GitHub.prID(from: url)
        
        let text = """
            write text "cd \(fullDirectory)"
            write text "gh pr view '\(prID)'"
        """
        iTerm.launchAndWriteText(text)
    }
    
    static func diffPR(url: URL) {
        let directory = GitHub.directory(for: url)
        let fullDirectory = directory.expandingTildeInPath
        let prID = GitHub.prID(from: url)
        
        let text = """
            write text "cd \(fullDirectory)"
            write text "gh pr diff '\(prID)'"
        """
        iTerm.launchAndWriteText(text)
    }
    
    static func approve(url: URL) {
        let directory = GitHub.directory(for: url)
        let fullDirectory = directory.expandingTildeInPath
        let prID = GitHub.prID(from: url)
        
        let text = """
            write text "cd \(fullDirectory)"
            write text "gh pr review -a '\(prID)'"
        """
        iTerm.launchAndWriteText(text)
    }
    
    static func merge(url: URL, deleteBranch: Bool) {
        let directory = GitHub.directory(for: url)
        let fullDirectory = directory.expandingTildeInPath
        let prID = GitHub.prID(from: url)
        var mergeCommand = "gh pr merge -m"
        if deleteBranch {
            mergeCommand.append(" -d")
        }
        mergeCommand.append(" \(prID)")
        
        let text = """
            write text "cd \(fullDirectory)"
            write text "\(mergeCommand)"
        """
        iTerm.launchAndWriteText(text)
    }
}
