//
//  AppDelegate.swift
//  BRouter
//
//  Created by csz on 2023/8/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var refreshItem: NSMenuItem!
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createStatusBarItem()
        refreshApp()
        KeyboardMonitor.shared.setup()
        NSApplication.shared.hide(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func application(_ application: NSApplication, open urls: [URL]) {
        handleOpen(urls: urls)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
    
    func application(_: NSApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return userActivityType == NSUserActivityTypeBrowsingWeb
    }
    
    func application(
        _: NSApplication,
        continue userActivity: NSUserActivity,
        restorationHandler _: @escaping ([NSUserActivityRestoring]) -> Void
    ) -> Bool {
        if userActivity.activityType != NSUserActivityTypeBrowsingWeb {
            return false
        }
        
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        handleOpen(urls: [url])
        return true
    }
    
    func application(_: NSApplication, didFailToContinueUserActivityWithType _: String, error _: Error) {}
}

extension AppDelegate {
    func createStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = NSImage(named: NSImage.Name("Safari"))
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        menu.addItem(withTitle: "Folder", action: #selector(revealConfig), keyEquivalent: "f")
        menu.addItem(withTitle: "Edit", action: #selector(editConfig), keyEquivalent: "e")
        refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshApp), keyEquivalent: "r")
        menu.addItem(refreshItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        statusBarItem.menu = menu
        
        if let button = statusBarItem.button {
            button.target = self
            button.action = #selector(showMenu)
        }
    }
}

extension AppDelegate {
    func handleOpen(urls: [URL]) {
        urls.forEach { url in
            let maped = Router.preMaped(url: url)
            
            if let intercepter = Router.intercepter(for: maped) {
                intercepter.perform(url: maped)
                
            } else {
                Router.openWeb(url: maped)
            }
        }
    }
    
    @objc
    func showMenu() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        statusBarItem.menu?.popUp(
            positioning: nil,
            at: NSPoint.zero,
            in: statusBarItem.button!
        )
    }
    
    @objc
    func quitApp() {
        NSApp.terminate(nil)
    }
    
    @objc
    func refreshApp() {
        refreshItem.isEnabled = false
        Task {
            await Router.refresh()
            refreshItem.isEnabled = true
        }
    }
    
    @objc
    func revealConfig() {
        Config.reveal()
    }
    
    @objc
    func editConfig() {
        Config.edit()
    }
}
