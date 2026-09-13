#!/usr/bin/swift
import Foundation

let stateFile = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".config/aerospace/.workspace-state")
let aerospace = "/opt/homebrew/bin/aerospace"

guard FileManager.default.fileExists(atPath: stateFile.path) else { exit(0) }

// Wait for AeroSpace to re-render windows after wake
Thread.sleep(forTimeInterval: 3)

// Read saved state: bundle-id|title|workspace
let savedContent = try String(contentsOf: stateFile, encoding: .utf8)
var savedMap: [String: String] = [:] // "bundle-id|title" → workspace
for line in savedContent.components(separatedBy: "\n") {
    let parts = line.split(separator: "|", maxSplits: 2)
    guard parts.count == 3 else { continue }
    let key = "\(parts[0])|\(parts[1])"
    savedMap[key] = String(parts[2])
}

// Get current windows: window-id|bundle-id|title|workspace
let listProc = Process()
listProc.executableURL = URL(fileURLWithPath: aerospace)
listProc.arguments = ["list-windows", "--all", "--format", "%{window-id}|%{app-bundle-id}|%{window-title}|%{workspace}"]

let pipe = Pipe()
listProc.standardOutput = pipe
listProc.standardError = FileHandle.nullDevice
try? listProc.run()
listProc.waitUntilExit()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
let currentContent = String(data: data, encoding: .utf8) ?? ""

// Match and move misplaced windows
for line in currentContent.components(separatedBy: "\n") {
    let parts = line.split(separator: "|", maxSplits: 3)
    guard parts.count == 4 else { continue }
    let wid = String(parts[0])
    let bundleId = String(parts[1])
    let title = String(parts[2])
    let currentWs = String(parts[3])

    let key = "\(bundleId)|\(title)"
    guard let targetWs = savedMap[key], targetWs != currentWs else { continue }

    let moveProc = Process()
    moveProc.executableURL = URL(fileURLWithPath: aerospace)
    moveProc.arguments = ["move-node-to-workspace", "--window-id", wid, targetWs]
    try? moveProc.run()
    moveProc.waitUntilExit()
}

try? FileManager.default.removeItem(at: stateFile)
