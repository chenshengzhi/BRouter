//
//  Router.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

enum Router {
    static let appIDMap: [String: String] = [
        "Safari": "com.apple.Safari",
        "Google Chrome": "com.google.Chrome",
        "Firefox": "org.mozilla.firefox",
        "Microsoft Edge": "com.microsoft.edgemac",
        "Edge": "com.microsoft.edgemac",
    ]
    
    static func refresh() async {
        await withUnsafeContinuation { continuation in
            Config.refresh()
            GitHub.refresh()
            continuation.resume()
        }
    }
    
    static func preMaped(url: URL) -> URL {
        if url.absoluteString.starts(with: "https://www.google.com/url?q=") {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let realURLString = components?.queryItems?.first(where: { $0.name == "q" })?.value,
               let realURL = URL(string: realURLString)
            {
                return realURL
            }
        }
        
        return url
    }
    
    static func intercepter(for url: URL) -> Intercepter? {
        if GitHub.shouldIntercept(url) {
            return GitHub()
        }
        return nil
    }
    
    static func openWeb(url: URL) {
        let appName = appName(for: url)
        let script: String
        if let id = appIDMap[appName] {
            script = """
            tell application id "\(id)"
                activate
                open location "\(url)"
            end tell
            """
        } else {
            script = """
            tell application "\(appName)"
                activate
                open location "\(url)"
            end tell
            """
        }
        AppleScript.run(script)
    }
}

extension Router {
    static func defaultAppName() -> String {
        if let appName = Config.shared.browserAppName {
            return appName
        }
        return "Safari"
    }
    
    static func appName(for url: URL) -> String {
        guard let dispatchers = Config.shared.dispatchers else {
            return defaultAppName()
        }
        guard let browsers = dispatchers.first(where: ({ url.matchAny(formats: $0.matchs) }))?.browsers else {
            return defaultAppName()
        }
        if let browser = browsers.first(where: { KeyboardMonitor.shared.match(modifiers: $0.modifiers) }) {
            return browser.appName
        }
        if let browser = browsers.first(where: { $0.modifiers == nil || $0.modifiers == [] }) {
            return browser.appName
        }
        return defaultAppName()
    }
}
