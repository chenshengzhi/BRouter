//
//  GitHubWindowController.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Cocoa

class GitHubWindowController: NSWindowController {
    let url: URL
    
    init(url: URL) {
        self.url = url
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 180, height: 200),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        
        super.init(window: window)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        window?.delegate = self
        setupButtons()
        layoutsWindow()
    }
    
    func setupButtons() {
        let buttons = GitHub.allowedActions(for: url).map { action in
            let view = InsetedButton(
                title: action.rawValue,
                target: self,
                action: #selector(buttonClicked(_:))
            )
            view.bezelStyle = .flexiblePush
            view.font = NSFont.systemFont(ofSize: 16)
            return view
        }
        
        let stackView = NSStackView(views: buttons)
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.alignment = .centerX
        stackView.setHuggingPriority(.dragThatCannotResizeWindow, for: .horizontal)
        stackView.needsLayout = true
        stackView.layoutSubtreeIfNeeded()
        
        window?.setContentSize(CGSize(width: 180, height: stackView.frame.height))
        window?.contentView = stackView
    }
    
    func layoutsWindow() {
        if let window = window {
            let mouseLocation = NSEvent.mouseLocation
            let windowSize = window.frame.size
            
            window.setFrameOrigin(NSPoint(
                x: mouseLocation.x - windowSize.width / 2,
                y: mouseLocation.y + 20
            ))
        }
    }
    
    @objc
    func buttonClicked(_ sender: NSButton) {
        guard let action = GitHub.Action(rawValue: sender.title) else {
            return
        }
        action.perform(url)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .microseconds(1)) { [self] in
            window?.close()
        }
    }
}

extension GitHubWindowController: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {}
}
