//
//  EventLog.swift
//  LaundryNotifier
//
//  Created by Mark Veinot on 2016-01-15.
//  Copyright © 2016 Mark Veinot. All rights reserved.
//

import Cocoa

class EventLog: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var eventTable: NSTableView!
    
    var events: [LaundryEvent] = []
    let dateFormatter = NSDateFormatter()

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        eventTable.setDelegate(self)
        eventTable.setDataSource(self)
    }
    
    func setEventList(eventList: [LaundryEvent])
    {
        events = eventList
        print("loaded events: \(events.count)")
        if (eventTable != nil)
        {
            eventTable.reloadData()
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if (tableColumn != nil) {
            switch (tableColumn!.identifier) {
                case "time":
                    return (dateFormatter.stringFromDate(events[row].eventTime!))
                case "topic":
                    return (events[row].eventTopic)
                case "message":
                    return (events[row].eventMessage)
                default:
                    return "No data"
            }
        } else {
            return "nil"
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return events.count
    }
}
