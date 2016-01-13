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
    var mqtt: CocoaMQTT?
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var actionMenu: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
        
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        
        statusItem.image = icon
        statusItem.menu = actionMenu
        mqttSetting()
        mqtt!.connect()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func webUI(sender: NSMenuItem) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://smartlaundry.local")!)
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    func mqttSetting()
    {
        let clientIdPid = "CocoaMQTT"
        mqtt = CocoaMQTT(clientId: clientIdPid, host: "192.168.5.10", port: 1883)
        if let mqtt = mqtt {
            mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
            mqtt.keepAlive = 90
            mqtt.delegate = self
        }
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
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
        print("didReceivedMessage: \(message.string) with id \(id)")
        if let mqttMessage = message.string
        {
            let notification:NSUserNotification = NSUserNotification()
            notification.title = "Laundry Notification"
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
        print("didPing")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        _console("mqttDidDisconnect: \(err!.description) ")
    }
    
    func _console(info: String) {
        print("Delegate: \(info)")
    }
}

