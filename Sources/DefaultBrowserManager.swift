//
//  DefaultBrowserManager.swift
//  Figproxy
//
//  Created by Dave Vondle on 4/16/24.
//

import Foundation
import Cocoa
import UniformTypeIdentifiers

class UserSettingsManager {
    static let shared = UserSettingsManager()
    
    private init() {}

    func checkAndPromptForDefaultBrowser(window: NSWindow) {
        if UserDefaults.standard.string(forKey: "selectedBrowserBundleID") == nil {
            let alert = NSAlert()
            alert.messageText = "Configure Default Browser"
            alert.informativeText = "Figproxy works by acting as a proxy browser accepting links and re-routing links formatted in a certain way from Figma. All other links are routed to a secondary default browser. Please select this default browser."
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .informational
            
            alert.beginSheetModal(for: window) { response in
                if response == .alertFirstButtonReturn {
                    self.showOpenPanelForBrowserSelection()
                }
            }
        }
    }

    func showOpenPanelForBrowserSelection() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowedContentTypes = [UTType.application]  // Specify allowed content types using UTType
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)

        openPanel.begin { response in
            if response == .OK, let url = openPanel.url, let bundleID = Bundle(url: url)?.bundleIdentifier {
                // Use the selected application's bundle ID as needed
                if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                    appDelegate.selectedBrowserBundleID = bundleID
                }
                UserDefaults.standard.set(bundleID, forKey: "selectedBrowserBundleID")
            }
        }
    }
}
