//
//  KeyboardMonitor.swift
//  BRouter
//
//  Created by csz on 2023/8/28.
//

import Cocoa
import Foundation

class KeyboardMonitor {
    enum Modifier: String, CaseIterable {
        case capsLock
        case shift
        case control
        case option
        case command
        case numericPad
        case help
        case function
        case deviceIndependentFlagsMask
        
        var flag: NSEvent.ModifierFlags {
            switch self {
            case .capsLock:
                return .capsLock
            case .shift:
                return .shift
            case .control:
                return .control
            case .option:
                return .option
            case .command:
                return .command
            case .numericPad:
                return .numericPad
            case .help:
                return .help
            case .function:
                return .function
            case .deviceIndependentFlagsMask:
                return .deviceIndependentFlagsMask
            }
        }
    }
    
    static let shared = KeyboardMonitor()
    
    /// 只会存储 `Modifier` 支持的类型
    private(set) var modifierFlags: NSEvent.ModifierFlags = []
    
    var isControlDown: Bool {
        modifierFlags.contains(.control)
    }

    var isCommandDown: Bool {
        modifierFlags.contains(.command)
    }

    var isOptionDown: Bool {
        modifierFlags.contains(.option)
    }

    var isShiftDown: Bool {
        modifierFlags.contains(.shift)
    }
    
    func setup() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.update(event: event)
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.update(event: event)
            return event
        }
    }
    
    func match(modifiers ms: [String]?) -> Bool {
        let modifiers: [String] = ms ?? []
        var flags: NSEvent.ModifierFlags = []
        for name in modifiers {
            if name.isEmpty {
                continue
            }
            guard let modifier = Modifier(rawValue: name) else {
                return false
            }
            flags.insert(modifier.flag)
        }
        if modifierFlags == flags {
            return true
        }
        return false
    }
    
    private func update(event: NSEvent) {
        var flags: NSEvent.ModifierFlags = []
        Modifier.allCases.map { $0.flag }.forEach { flag in
            if event.modifierFlags.contains(flag) {
                flags.insert(flag)
            }
        }
        modifierFlags = flags
    }
}
