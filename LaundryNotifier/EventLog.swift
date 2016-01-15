//
//  EventLog.swift
//  LaundryNotifier
//
//  Created by Mark Veinot on 2016-01-15.
//  Copyright © 2016 Mark Veinot. All rights reserved.
//

import Cocoa

class EventLog: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
}
