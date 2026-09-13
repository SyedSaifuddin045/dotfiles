#!/usr/bin/swift
import Foundation

let stateFile = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config/aerospace/.workspace-state")
let aerospace = "/opt/homebrew/bin/aerospace"

var sleeping = false

while true {
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/bin/bash")
    proc.arguments = ["-c", "pmset -g assertions 2>/dev/null | awk '/PreventSystemSleep/{print $NF}'"]

    let pipe = Pipe()
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    try? proc.run()
    proc.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if output == "0" || output.isEmpty {
        if !sleeping {
            // Save bundle-id|title|workspace for each window
            let listProc = Process()
            listProc.executableURL = URL(fileURLWithPath: aerospace)
            listProc.arguments = ["list-windows", "--all", "--format", "%{app-bundle-id}|%{window-title}|%{workspace}"]

            let listPipe = Pipe()
            listProc.standardOutput = listPipe
            listProc.standardError = FileHandle.nullDevice
            try? listProc.run()
            listProc.waitUntilExit()

            let listData = listPipe.fileHandleForReading.readDataToEndOfFile()
            try? listData.write(to: stateFile)

            sleeping = true
        }
    } else {
        sleeping = false
    }

    Thread.sleep(forTimeInterval: 30)
}
