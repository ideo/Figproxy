//
//  CGKeyCodeInitializers.swift
//
//  Created by John Scott on 09/02/2022.
//  Found here: https://stackoverflow.com/questions/1918841/how-to-convert-ascii-character-to-cgkeycode/64344453#64344453
//

import Foundation
import AppKit

extension CGKeyCode {
    public init?(character: String) {
        if let keyCode = Initializers.shared.characterKeys[character] {
            self = keyCode
        } else {
            return nil
        }
    }

    public init?(modifierFlag: NSEvent.ModifierFlags) {
        if let keyCode = Initializers.shared.modifierFlagKeys[modifierFlag] {
            self = keyCode
        } else {
            return nil
        }
    }
    
    public init?(specialKey: NSEvent.SpecialKey) {
        if let keyCode = Initializers.shared.specialKeys[specialKey] {
            self = keyCode
        } else {
            return nil
        }
    }
    
    private struct Initializers {
        let specialKeys: [NSEvent.SpecialKey:CGKeyCode]
        let characterKeys: [String:CGKeyCode]
        let modifierFlagKeys: [NSEvent.ModifierFlags:CGKeyCode]
        
        static let shared = Initializers()
        
        init() {
            var specialKeys = [NSEvent.SpecialKey:CGKeyCode]()
            var characterKeys = [String:CGKeyCode]()
            var modifierFlagKeys = [NSEvent.ModifierFlags:CGKeyCode]()

            for keyCode in (0..<128).map({ CGKeyCode($0) }) {
                guard let cgevent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else { continue }
                guard let nsevent = NSEvent(cgEvent: cgevent) else { continue }

                var hasHandledKeyCode = false
                if nsevent.type == .keyDown {
                    if let specialKey = nsevent.specialKey {
                        hasHandledKeyCode = true
                        // Check if the specialKey already exists and only update if new keyCode is lower
                        if let existingKeyCode = specialKeys[specialKey], existingKeyCode > keyCode {
                            specialKeys[specialKey] = keyCode
                        } else if specialKeys[specialKey] == nil {
                            specialKeys[specialKey] = keyCode
                        }
                    } else if let characters = nsevent.charactersIgnoringModifiers, !characters.isEmpty && characters != "\u{0010}" {
                        hasHandledKeyCode = true
                        // Check if the characters key already exists and only update if new keyCode is lower
                        if let existingKeyCode = characterKeys[characters], existingKeyCode > keyCode {
                            characterKeys[characters] = keyCode
                        } else if characterKeys[characters] == nil {
                            characterKeys[characters] = keyCode
                        }
                    }
                } else if nsevent.type == .flagsChanged, let modifierFlag = nsevent.modifierFlags.first(.capsLock, .shift, .control, .option, .command, .help, .function) {
                    hasHandledKeyCode = true
                    // Check if the modifierFlag already exists and only update if new keyCode is lower
                    if let existingKeyCode = modifierFlagKeys[modifierFlag], existingKeyCode > keyCode {
                        modifierFlagKeys[modifierFlag] = keyCode
                    } else if modifierFlagKeys[modifierFlag] == nil {
                        modifierFlagKeys[modifierFlag] = keyCode
                    }
                }
                if !hasHandledKeyCode {
                    #if DEBUG
                    print("Unhandled keycode \(keyCode): \(nsevent)")
                    #endif
                }
            }
            self.specialKeys = specialKeys
            self.characterKeys = characterKeys
            self.modifierFlagKeys = modifierFlagKeys
        }
    }

}

extension NSEvent.ModifierFlags: Hashable { }

extension OptionSet {
    public func first(_ options: Self.Element ...) -> Self.Element? {
        for option in options {
            if contains(option) {
                return option
            }
        }
        return nil
    }
}
