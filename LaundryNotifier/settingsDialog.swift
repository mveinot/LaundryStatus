//
//  settingsDialog.swift
//  LaundryNotifier
//
//  Created by Mark Veinot on 2016-01-18.
//  Copyright © 2016 Mark Veinot. All rights reserved.
//

import Cocoa

class settingsDialog: NSWindowController {

    @IBOutlet weak var broker: NSTextField!
    @IBOutlet weak var port: NSTextField!
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSTextField!
    
    override func windowDidLoad() {
        
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        
        let settings = NSUserDefaults.standardUserDefaults()
        let mqtthost = settings.objectForKey("MQTTServer") as? String ?? "192.168.5.10"
        let mqttport = settings.objectForKey("MQTTPort") as? Int ?? 1883
        let mqttusername = settings.objectForKey("MQTTUsername") as? String ?? "username"
        let mqttpassword = settings.objectForKey("MQTTPassword") as? String ?? "password"
        broker.stringValue = mqtthost
        port.stringValue = String(mqttport)
        username.stringValue = mqttusername
        password.stringValue = mqttpassword

    }
    
    @IBAction func saveSettings(sender: NSButton) {
        let settings = NSUserDefaults.standardUserDefaults()
        settings.setObject(broker.stringValue, forKey: "MQTTServer")
        settings.setInteger(port.integerValue, forKey: "MQTTPort")
        settings.setObject(username.stringValue, forKey: "MQTTUsername")
        settings.setObject(password.stringValue, forKey: "MQTTPassword")
        self.close()
    }
}
