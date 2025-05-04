//
//  ContentViewModel.swift
//  OMSDemo
//
//  Created by Takuto Nakamura on 2024/03/02.
//

import OpenMultitouchSupport
import SwiftUI

import Cocoa

// Common key codes
let kVK_Return: CGKeyCode = 36
let kVK_Tab: CGKeyCode = 48
let kVK_Space: CGKeyCode = 49
let kVK_Delete: CGKeyCode = 51
let kVK_Escape: CGKeyCode = 53
let kVK_LeftArrow: CGKeyCode = 123
let kVK_RightArrow: CGKeyCode = 124
let kVK_DownArrow: CGKeyCode = 125
let kVK_UpArrow: CGKeyCode = 126

let left_thumb_on = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"left_thumb\":1}'
"""

let left_thumb_off = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"left_thumb\":0}'
"""

let right_thumb_on = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"right_thumb\":1}'
"""

let right_thumb_off = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"right_thumb\":0}'
"""

let left_thumb_1_on = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"left_1_thumb\":1}'
"""

let left_thumb_1_off = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"left_1_thumb\":0}'
"""

let right_thum_1b_on = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"right_1_thumb\":1}'
"""

let right_thum_1b_off = """
'/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli' --set-variables '{\"right_1_thumb\":0}'
"""

func run_bash(command: String)
{
    let on = Process()
    on.executableURL = URL(fileURLWithPath: "/bin/bash")
    on.arguments = ["-c", command]
    
    do {
        try on.run()
        on.waitUntilExit()
        if on.terminationStatus == 0 {
//            print(command)
        } else {
            print("Command failed with exit code \(String(describing: on.terminationStatus))")
        }
    } catch {
        print("Failed to run command: \(error)")
    }

}


func sendOptionDeleteKeyEvent()
{
    // Create a CGEvent for Option+Delete
    let flags = CGEventFlags.maskAlternate
    
    // Delete key (backspace) has keycode 51
    guard let deleteEvent = CGEvent(keyboardEventSource: nil, virtualKey: 51, keyDown: true) else {
        print("Failed to create keyDown event")
        return
    }
    
    // Set the option modifier flag
    deleteEvent.flags = flags
    
    // Post the key down event
    deleteEvent.post(tap: .cghidEventTap)
    
    // Create and post the key up event
    guard let deleteUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 51, keyDown: false) else {
        print("Failed to create keyUp event")
        return
    }
    deleteUpEvent.flags = flags
    deleteUpEvent.post(tap: .cghidEventTap)
}



@MainActor
final class ContentViewModel: ObservableObject {
    @Published var touchData = [OMSTouchData]()
    @Published var isListening: Bool = false
    @Published var SpaceFnMode: Bool = false
    
    @Published var LeftThumb: Bool = false
    @Published var RightThumb: Bool = false
    @Published var LeftThumb1: Bool = false
    @Published var RightThumb1: Bool = false

    @Published var isThumbing: Bool = false

    @Published var LeftThumbTouch: Bool = false
    @Published var RightThumbTouch: Bool = false
    @Published var LeftThumb1Touch: Bool = false
    @Published var RightThumb1Touch: Bool = false
    

    private let manager = OMSManager.shared
    private var task: Task<Void, Never>?


    init() {
        
        manager.startListening()
    }

    
    func onAppear() {
        task = Task { [weak self, manager] in
            for await touchData in manager.touchDataStream {
                await MainActor.run {
                    
                    self?.touchData = touchData
                    
 
                    self?.isThumbing = false

                    self?.LeftThumbTouch = false
                    self?.RightThumbTouch = false
                    self?.LeftThumb1Touch = false
                    self?.RightThumb1Touch = false

                    for data in touchData
                    {
//                       print(data.position.x, data.position.y)

                        if (data.position.x > 0.2 && data.position.x < 0.8 && data.position.y > 0.82)
                        {
                            // NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: performanceTime)
                                                    
                            self?.isThumbing = true
                            if (data.position.x < 0.4)
                            {
                                self?.LeftThumbTouch = true
                                if (self?.LeftThumb == false)
                                {
                                    self?.LeftThumb = true;
                                    run_bash(command: left_thumb_on)
                                }
                            }
                            if (data.position.x > 0.4)
                            {
                                self?.RightThumbTouch = true
                                
                                if (self?.RightThumb == false)
                                {
                                    self?.RightThumb = true;
                                    run_bash(command: right_thumb_on)
                                }
                            }
                        }
                        
                    }
                    
                    if (self?.LeftThumb == true && self?.LeftThumbTouch == false)
                    {
                        self?.LeftThumb = false
                        run_bash(command: left_thumb_off)
                    }

                    if (self?.RightThumb == true && self?.RightThumbTouch == false)
                    {
                        self?.RightThumb = false
                        run_bash(command: right_thumb_off)
                    }
                }
            }
        }
    }

    func onDisappear() {
        task?.cancel()
    }
}
