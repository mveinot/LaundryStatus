//
//  LaundryEvent.swift
//  LaundryNotifier
//
//  Created by Mark Veinot on 2016-01-15.
//  Copyright © 2016 Mark Veinot. All rights reserved.
//

import Foundation

class LaundryEvent {
    var eventMessage: String?
    var eventTopic: String?
    var eventTime: NSDate?
    
    func log()
    {
        if let time = eventTime?.description, topic = eventTopic, message = eventMessage {
            print("Event: \(time) - \(topic) - \(message)")
        }
    }
}
