//  AppDelegate.swift
//  Created by Dave Vondle
//  Copyright (c) 2024 IDEO. All rights reserved.

//  Contains code from ORSSerialPortSwiftDemo created by Andrew Madsen on 10/31/14.
//  Copyright (c) 2014 Open Reel Software. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa
import UserNotifications
import ApplicationServices
import UniformTypeIdentifiers

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var window: NSWindow!
    var promptUserToSetDefault: Bool = false
    
    var selectedBrowserBundleID: String? {
        didSet {
            UserDefaults.standard.set(selectedBrowserBundleID, forKey: "selectedBrowserBundleID")
            #if DEBUG
            print("selectedBrowserBundleID= \(String(describing: selectedBrowserBundleID))")
            #endif
        }
    }
    
    override init() {
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "selectedBrowserBundleID")
        #endif
        super.init()
        selectedBrowserBundleID = UserDefaults.standard.string(forKey: "selectedBrowserBundleID")
        promptUserToSetDefault=selectedBrowserBundleID==nil
    }
    
    func applicationDidBecomeActive(_ aNotification: Notification) {
        //set as the default browser on launch
        set_default_handler("http", "com.ideo.figproxy")
        set_default_handler("https", "com.ideo.figproxy")
    }
        
    func applicationDidFinishLaunching(_ aNotification: Notification) {        
        // if accessibility permissions are not allowed yet
        if !AXIsProcessTrusted() {
            print("accessibility is not set")
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options)
            
            if !accessEnabled {
                print("Access not enabled. Please grant accessibility permissions.")
            }
        }
        
        if (promptUserToSetDefault){
            UserSettingsManager.shared.checkAndPromptForDefaultBrowser(window: window)
        }
        
    }
    
    @objc func handleBundleIDSelected(_ notification: Notification) {
        if let bundleID = notification.object as? String {
            selectedBrowserBundleID = bundleID
        }
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        if urls.isEmpty {
            print("No URLs to process")
        }
        for url in urls {
            let prefix = "https://www.figma.com/exit?url=http%3A%2F%2Fsend%20"
            if url.absoluteString.hasPrefix(prefix){
                let startIndex = url.absoluteString.index(url.absoluteString.startIndex, offsetBy: prefix.count)
                let message = String(url.absoluteString[startIndex...])
                if message.hasPrefix("0x") {
                    // Parse the hexadecimal string to Data
                    if let data = parseHexStringToData(message) {
                        // Post the notification with Data if parsing succeeds
                        NotificationCenter.default.post(name: .sendSerialMessage, object: nil, userInfo: ["data": data])
                        
                    }else{
                        print("invalid hex string")
                    }
                } else {
                    // Post the notification with String message directly
                    NotificationCenter.default.post(name: .sendSerialMessage, object: nil, userInfo: ["message": message])
                }
                activateRunningApplication(withBundleIdentifier: "com.figma.Desktop")
            } else {
                if let bundleIdentifier = selectedBrowserBundleID {
                    openURLInBrowser(url, withBrowserBundleIdentifier: bundleIdentifier)
                } else {
                    print("No browser bundle ID selected")
                    let bundleIdentifier = "com.apple.Safari"
                    openURLInBrowser(url, withBrowserBundleIdentifier: bundleIdentifier)
                    // Optionally handle the case where no browser is selected
                }
            }
        }
    }
    
    func openURLInBrowser(_ url: URL, withBrowserBundleIdentifier bundleIdentifier: String) {
        guard let browserURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            print("Browser not found")
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: browserURL, configuration: configuration, completionHandler: nil)
    }

    
    func activateRunningApplication(withBundleIdentifier bundleIdentifier: String) {
        let workspace = NSWorkspace.shared
        // Filter the running applications to find one with the specified bundle identifier.
        let apps = workspace.runningApplications.filter { $0.bundleIdentifier == bundleIdentifier }
        if let runningApp = apps.first {
            // If the app is found running, activate it.
            runningApp.activate(options: [.activateIgnoringOtherApps])
        } else {
            // If the app is not found, it means it's not running as expected.
            print("No running instance of the application found.")
        }
    }
    
    func parseHexStringToData(_ hexString: String) -> Data? {
        var hex = hexString
        // Ensure the hex string starts with "0x" and remove it
        if hex.hasPrefix("0x") {
            hex.removeFirst(2)
        }
        
        // Ensure the hex string has an even number of characters
        guard hex.count % 2 == 0 else {
            print("Hex string must have an even number of characters")
            return nil
        }
        
        // Convert hex string to bytes
        var bytes = [UInt8]()
        bytes.reserveCapacity(hex.count / 2)
        var index = hex.startIndex
        for _ in 0..<hex.count / 2 {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let b = UInt8(hex[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                print("Error parsing hex string")
                return nil
            }
            index = nextIndex
        }
        
        return Data(bytes)
    }
}

