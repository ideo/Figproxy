//  FigproxyController.swift
//  Created by Dave Vondle
//  Copyright (c) 2024 IDEO. All rights reserved.
//
//  Contains code from ORSSerialPortSwiftDemo created by Andrew Madsen on 10/31/14.
//  Copyright (c) 2014 Open Reel Software. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//	
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa
import ORSSerial
import UserNotifications
import UniformTypeIdentifiers

class FigproxyController: NSObject, ORSSerialPortDelegate, NSUserNotificationCenterDelegate {
	@objc let serialPortManager = ORSSerialPortManager.shared()
	@objc let availableBaudRates = [300, 1200, 2400, 4800, 9600, 14400, 19200, 28800, 38400, 57600, 115200, 230400]
	@objc dynamic var shouldAddLineEnding = false
	
	@objc dynamic var serialPort: ORSSerialPort? {
		didSet {
			oldValue?.close()
			oldValue?.delegate = nil
			serialPort?.delegate = self
		}
	}
	
	@IBOutlet weak var sendTextField: NSTextField!
	@IBOutlet weak var sendButton: NSButton!
	@IBOutlet var receivedDataTextView: NSTextView!
    @IBOutlet var receivedDataHexView: NSTextView!
	@IBOutlet weak var openCloseButton: NSButton!
    @IBOutlet weak var selectRealBrowserButton: NSButton!
	@IBOutlet weak var lineEndingPopUpButton: NSPopUpButton!
    @IBOutlet weak var dataOptionsView: NSStackView!
    @IBOutlet weak var browserSetupView: NSStackView!
    @IBOutlet weak var pinStatesView: NSStackView!
    @IBOutlet weak var sendAndReceiveView: NSStackView!
    
	var lineEndingString: String {
		let map = [0: "\r", 1: "\n", 2: "\r\n"]
		if let result = map[self.lineEndingPopUpButton.selectedTag()] {
			return result
		} else {
			return "\n"
		}
	}
	
	override init() {
		super.init()
		
		let nc = NotificationCenter.default
        #if DEBUG
		nc.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
		nc.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
        #endif
        nc.addObserver(self, selector: #selector(handleSendSerialMessage(notification:)), name: .sendSerialMessage, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
    @IBAction func toggleBrowserSetup(_ sender: NSButton) {
        let shouldHide = sender.state == .off // .on state means show, .off means hide
        browserSetupView.isHidden = shouldHide
    }
    @IBAction func toggleDataOptions(_ sender: NSButton) {
        let shouldHide = sender.state == .off // .on state means show, .off means hide
        dataOptionsView.isHidden = shouldHide
    }
    @IBAction func toggleSendAndReceive(_ sender: NSButton) {
        let shouldHide = sender.state == .off // .on state means show, .off means hide
        sendAndReceiveView.isHidden = shouldHide
    }
    @IBAction func togglePinStatesView(_ sender: NSButton) {
        let shouldHide = sender.state == .off // .on state means show, .off means hide
        pinStatesView.isHidden = shouldHide
    }
    
	@IBAction func send(_: Any) {
		var string = self.sendTextField.stringValue
		if self.shouldAddLineEnding && !string.hasSuffix("\n") {
			string += self.lineEndingString
		}
		if let data = string.data(using: String.Encoding.utf8) {
			self.serialPort?.send(data)
		}
	}
	
	@IBAction func returnPressedInTextField(_ sender: Any) {
		sendButton.performClick(sender)
	}
	
	@IBAction func openOrClosePort(_ sender: Any) {
		if let port = self.serialPort {
			if (port.isOpen) {
				port.close()
			} else {
				port.open()
                if(!sendAndReceiveView.isHidden){
                    self.receivedDataTextView.textStorage?.mutableString.setString("")
                    self.receivedDataHexView.textStorage?.mutableString.setString("")
                }
                //arduino need RTS on macOS so we do this by default
                port.rts = true
			}
		}
	}
    
    @IBAction func selectRealBrowser(_ sender: Any) {
        UserSettingsManager.shared.showOpenPanelForBrowserSelection()
    }
	
	@IBAction func clear(_ sender: Any) {
		self.receivedDataTextView.string = ""
        self.receivedDataHexView.string = ""
	}
    
    @objc func handleSendSerialMessage(notification: Notification) {
        // First, check if there's data directly provided in the notification
        if let data = notification.userInfo?["data"] as? Data {
            self.serialPort?.send(data)
        }
        // Then, check if there's a string message that needs to be sent as UTF-8 data
        else if let message = notification.userInfo?["message"] as? String {
            if let data = message.data(using: .utf8) {
                self.serialPort?.send(data)
            }
        }
        // Fallback or error handling if neither expected type is found
        else {
            print("Notification userInfo did not contain expected 'data' or 'string message'.")
        }
    }
    
    func postUserNotificationForConnectedPort(_ port: ORSSerialPort) {
        let content = UNMutableNotificationContent()
        content.title = "Serial Port Connected"
        content.body = "Serial Port \(port.name) was connected to your Mac."
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil) // Use nil trigger for immediate delivery
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
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
    
	
	func serialPortWasOpened(_ serialPort: ORSSerialPort) {
		self.openCloseButton.title = "Close"
	}
	
	func serialPortWasClosed(_ serialPort: ORSSerialPort) {
		self.openCloseButton.title = "Open"
	}
	
    // this is called when a byte is recieved
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        // Accommodate dark and light modes
        if let string = String(data: data, encoding: .utf8) { // Convert data to string directly
            if(!sendAndReceiveView.isHidden){
                let textColor: NSColor = self.receivedDataTextView.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .white : .black
                let attributedString = NSAttributedString(string: string, attributes: [.foregroundColor: textColor])
                
                // Calculate the range that needs to be removed to keep the final length within 1000 characters
                if let textStorage = self.receivedDataTextView.textStorage {
                    let newLength = textStorage.length + attributedString.length
                    if newLength > 1000 {
                        let rangeToRemove = NSRange(location: 0, length: newLength - 1000)
                        textStorage.deleteCharacters(in: rangeToRemove)
                    }
                    textStorage.append(attributedString)
                }
                self.receivedDataTextView.needsDisplay = true
            }
            
            // Attempt to simulate keypresses based on the received string - only if figma proto is the front most app
            let frontmostApp = NSWorkspace.shared.frontmostApplication
            if (frontmostApp?.localizedName == "Figma"){
                simulateKeyPress(for: string)
            }
        }

        // Display received data as hex string
        if(!sendAndReceiveView.isHidden){
            let textColor: NSColor = self.receivedDataTextView.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .white : .black
            let hexString = data.map { String(format: "%02hhX ", $0) }.joined()
            let attributedHexString = NSAttributedString(string: hexString, attributes: [.foregroundColor: textColor])
            if let textStorage = self.receivedDataHexView.textStorage {
                let newLength = textStorage.length + attributedHexString.length
                if newLength > 1000 {
                    let rangeToRemove = NSRange(location: 0, length: newLength - 1000)
                    textStorage.deleteCharacters(in: rangeToRemove)
                }
                
                textStorage.append(attributedHexString)
            }
            self.receivedDataHexView.needsDisplay = true
        }
        
    }

    func simulateKeyPress(for string: String) {
        // First, attempt to find a direct match for the character
        if let keyCode = CGKeyCode(character: string) {
            simulateKeyPress(keyCode: keyCode)
        } else if let keyCode = CGKeyCode(character: string.lowercased()) {
            // If a lowercase match is found, simulate a Shift key press alongside it
            if let shiftKeyCode = CGKeyCode(modifierFlag: .shift) {
                simulateModifierKeyPress(modifierKeyCode: shiftKeyCode, characterKeyCode: keyCode)
            } else {
                print("Error: Unable to find key code for Shift modifier.")
            }
        } else {
            print("No match for keycode")
            //TO DO: add in other modifier keys if needed... different keyboard layouts make this annoying
        }
    }

    func simulateKeyPress(keyCode: CGKeyCode) {
        let eventDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
        eventDown?.post(tap: .cghidEventTap)
        let eventUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
        eventUp?.post(tap: .cghidEventTap)
    }

    func simulateModifierKeyPress(modifierKeyCode: CGKeyCode, characterKeyCode: CGKeyCode) {
        let eventShiftDown = CGEvent(keyboardEventSource: nil, virtualKey: modifierKeyCode, keyDown: true)
        eventShiftDown?.post(tap: .cghidEventTap)
        simulateKeyPress(keyCode: characterKeyCode)
        let eventShiftUp = CGEvent(keyboardEventSource: nil, virtualKey: modifierKeyCode, keyDown: false)
        eventShiftUp?.post(tap: .cghidEventTap)
    }

	func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
		self.serialPort = nil
		self.openCloseButton.title = "Open"
	}
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("SerialPort \(serialPort) encountered an error: \(error)")
    }
    
    #if DEBUG
	@objc func serialPortsWereConnected(_ notification: Notification) {
		if let userInfo = notification.userInfo {
			let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
			print("Ports were connected: \(connectedPorts)")
			//self.postUserNotificationForConnectedPorts(connectedPorts)
		}
	}
	
	@objc func serialPortsWereDisconnected(_ notification: Notification) {
		if let userInfo = notification.userInfo {
			let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
			print("Ports were disconnected: \(disconnectedPorts)")
			//self.postUserNotificationForDisconnectedPorts(disconnectedPorts)
		}
	}
    #endif
}
