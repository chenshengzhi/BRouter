//
//  File.swift
//  BRouter
//
//  Created by csz on 2023/8/26.
//

import Foundation

typealias RunShellResult = (Int32, String?)

@discardableResult
func runShellAndOutput(_ shell: String) -> RunShellResult {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", shell]
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    
    task.waitUntilExit()
    
    return (task.terminationStatus, output)
}

extension String {
    func runShell() -> RunShellResult {
        runShellAndOutput(self)
    }
}

extension Command {
    func run(_ arguments: String) -> RunShellResult {
        runShellAndOutput("\(commandPath) \(arguments)")
    }
}
