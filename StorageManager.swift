// © 2026 Stuart Thomas (stuart.thomas@mac.com)
// Licensed under MIT License
// Copyright, Designs and Patents Act 1988

import Foundation

class StorageManager {
    static let shared = StorageManager()
    private let url: URL
    private let queue = DispatchQueue(label: "com.scratchpad.storage", qos: .background)
    
    init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("Scratchpad", isDirectory: true)
        
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        url = appDirectory.appendingPathComponent("scratchpad.txt")
        print("Scratchpad data store: \(url.path)")
    }
    
    func readText() -> String {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return "" // Expected on first launch
        }
    }
    
    func saveText(_ text: String) {
        // Dispatch to background thread to ensure zero typing latency
        queue.async {
            do {
                try text.write(to: self.url, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to save scratchpad text: \(error)")
            }
        }
    }
}
