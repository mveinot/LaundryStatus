//
//  AppDelegate.swift
//  LaundryNotifier
//
//  Created by Mark Veinot on 2016-01-12.
//  Copyright © 2016 Mark Veinot. All rights reserved.
//

import Cocoa
import CocoaMQTT

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CocoaMQTTDelegate {
    var mqtt: CocoaMQTT
    
    override init()
    {
        let host: NSHost
        host = NSHost.currentHost()
        
        let settings = NSUserDefaults.standardUserDefaults()
        let mqtthost = settings.objectForKey("MQTTServer") as? String ?? "192.168.5.10"
        let mqttport = settings.objectForKey("MQTTPort") as? UInt16 ?? 1883
        let mqttusername = settings.objectForKey("MQTTUsername") as? String ?? "username"
        let mqttpassword = settings.objectForKey("MQTTPassword") as? String ?? "password"
        
        var clientIdPid = "LaundryMonitor";
        if let hostname = host.name {
            clientIdPid = clientIdPid+"-"+hostname
        }
        print(clientIdPid)
        self.mqtt = CocoaMQTT(clientId: clientIdPid)
        
        self.mqtt.host = mqtthost
        self.mqtt.port = mqttport
        self.mqtt.username = mqttusername
        self.mqtt.password = mqttpassword

        self.mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
    }
    
    var events = [LaundryEvent]()
    var eventLog: EventLog = EventLog(windowNibName: "EventLog")
    var settingDlg: settingsDialog = settingsDialog(windowNibName: "settingsDialog")
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var actionMenu: NSMenu!
    @IBOutlet weak var menuStatusItem: NSMenuItem!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)

        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        
        statusItem.image = icon
        statusItem.menu = actionMenu

        mqtt.delegate = self
        mqtt.connect()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func webUI(sender: NSMenuItem) {
        if let url = NSURL(string: "http://smartlaundry.local") {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    @IBAction func openPrefs(sender: NSMenuItem) {
        settingDlg.showWindow(nil)
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func reconnect(sender: NSMenuItem) {
        mqtt.connect()
    }
    
    @IBAction func viewLog(sender: NSMenuItem) {
        eventLog.showWindow(nil)
        eventLog.setEventList(events)
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
        menuStatusItem.title = "Status: connected"
        mqtt.publish("laundry/Client", withString: "Monitor connected")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(ack.rawValue)")
        if ack == .ACCEPT {
            mqtt.subscribe("laundry/#", qos: CocoaMQTTQOS.QOS1)
            mqtt.ping()
        }
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        let event: LaundryEvent = LaundryEvent()
        let topic = message.topic.stringByReplacingOccurrencesOfString("laundry/", withString: "")
        
        print("didReceivedMessage: \(message.string) with id \(id)")
        if let mqttMessage = message.string
        {
            event.eventMessage = message.string
            event.eventTopic = topic
            event.eventTime = NSDate()
            
            events.append(event)
            eventLog.setEventList(events)
            
            let notification:NSUserNotification = NSUserNotification()
            notification.title = "Laundry Notification"
            notification.subtitle = topic
            notification.informativeText = mqttMessage
            
            notification.soundName = NSUserNotificationDefaultSoundName
            notification.deliveryDate = NSDate(timeIntervalSinceNow: 2)
            let notificationcenter:NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
            notificationcenter.scheduleNotification(notification)
        }
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        menuStatusItem.title = "Status: ping!"
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        menuStatusItem.title = "Status: connected"
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        _console("mqttDidDisconnect: \(err!.description) ")
        
        let alert = NSAlert()
        alert.messageText = "Laundry Monitor"
        alert.addButtonWithTitle("OK")
        alert.informativeText = "Connection to the message server was lost. Check connection and click reconnect from the menu"
        alert.runModal()

        menuStatusItem.title = "Status: disconnected"
    }
    
    func _console(info: String) {
        print("Delegate: \(info)")
    }
}

