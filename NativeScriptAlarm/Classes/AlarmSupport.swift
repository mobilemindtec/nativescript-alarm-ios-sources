//
//  AlarmSupport.swift
//  AlarmManager
//
//  Created by Ricardo Bocchi on 14/09/2018.
//  Copyright © 2018 Ricardo Bocchi. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AudioToolbox
import AVFoundation
import UserNotifications

@objc public class AlarmSupport : NSObject, AVAudioPlayerDelegate, UNUserNotificationCenterDelegate{
    
    @objc public var audioPlayer: AVAudioPlayer?
    @objc public var audioPlayerDelegate: AVAudioPlayerDelegate?
    @objc public let scheduler: Scheduler = Scheduler()
    
    @objc public var onNotificationReceived: ((_ alarm: Alarm) -> Void)?
    @objc public var onNotificationClick: ((_ alarm: Alarm) -> Void)?
    @objc public var onNotificationActionOk: ((_ alarm: Alarm) -> Void)?
    @objc public var onNotificationActionOpen: ((_ alarm: Alarm) -> Void)?
    @objc public var onNotificationActionSnooze: ((_ alarm: Alarm) -> Void)?

    @objc public override init(){}
    
    @objc public static func setUpNotifications(_ alarmSupport: AlarmSupport){
        
        var error: NSError?
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error1 as NSError{
            error = error1
            print("could not set session. err:\(error!.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError{
            error = error1
            print("could not active session. err:\(error!.localizedDescription)")
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = alarmSupport
    }
  
    
    @objc public func playSound(_ soundName: String, _ vibrate: Bool, _ numberOfLoops: Int) {
        
        if vibrate {
            //vibrate phone first
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //set vibrate callback
            AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                                  nil,
                                                  { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                                                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                                                  }, nil)
        }
        
        var bundle = Bundle(for: Scheduler.self)
        let url = URL(fileURLWithPath: bundle.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
            
        }
        
        //negative number means loop infinity
        audioPlayer!.numberOfLoops = numberOfLoops
        audioPlayer!.play()        
    }
    
    @objc public func stopSound(){
        if audioPlayer != nil {
            if audioPlayer!.isPlaying {
                audioPlayer!.stop()
            }
        }
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
    }
    
    //AVAudioPlayerDelegate protocol
    @objc public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if audioPlayerDelegate != nil {
            audioPlayerDelegate?.audioPlayerDidFinishPlaying?(player, successfully: flag)
        }
    }
    
    @objc public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur: \(error)")
        if audioPlayerDelegate != nil {
            audioPlayerDelegate?.audioPlayerDecodeErrorDidOccur?(player, error: error)
        }
    }
    
    @objc public func findAlarmByNotification(_ notification: UNNotification) -> Alarm? {
        
        let alarmModel = Alarms()
        var alarm: Alarm?
        let userInfo = notification.request.content.userInfo

        alarm = alarmModel.alarms.first(){
            it in it.id == userInfo["id"] as! Int
        }
        
        return alarm
    }
    
    @objc public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        print("userNotificationCenter 1")
        let alarm: Alarm? = self.findAlarmByNotification(notification)
        
        if self.onNotificationReceived != nil && alarm != nil {
                self.onNotificationReceived!(alarm!)
        }
        
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    @objc public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("userNotificationCenter 2")
        let alarm: Alarm? = self.findAlarmByNotification(response.notification)
        let dismiss: String = "GENERAL_DISMISS"
        let category: String = response.notification.request.content.categoryIdentifier
        
        if alarm != nil && (category == alarm!.categoty || category == dismiss) {
            
            if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                
                if self.onNotificationClick != nil {
                    self.onNotificationClick!(alarm!)
                }
                
            } else if response.actionIdentifier == "OK_ACTION" {
                if self.onNotificationActionOk != nil {
                   self.onNotificationActionOk!(alarm!)
                }
            } else if response.actionIdentifier == "SNOOZE_ACTION" {
                if self.onNotificationActionSnooze != nil {
                    self.onNotificationActionSnooze!(alarm!)
                }
            } else if response.actionIdentifier == "OK_OPEN" {
                if self.onNotificationActionOpen != nil {
                    self.onNotificationActionOpen!(alarm!)
                }
            }
        }
        
        completionHandler()
    }
    
    @objc public static func makeDate(_ year: Int, _ month: Int, _ day: Int, _ hr: Int, _ min: Int, _ sec: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        // calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)!
    }
    
    @objc public static func getDateComponents(_ alarm:Alarm) -> DateComponents {
        let calendar = Calendar.current
        var dateInfo = DateComponents()
        dateInfo.year = calendar.component(Calendar.Component.year, from: alarm.date)
        dateInfo.month = calendar.component(Calendar.Component.month, from: alarm.date)
        dateInfo.day = calendar.component(Calendar.Component.day, from: alarm.date)
        dateInfo.hour = calendar.component(Calendar.Component.hour, from: alarm.date)
        dateInfo.minute = calendar.component(Calendar.Component.minute, from: alarm.date)
        dateInfo.second = calendar.component(Calendar.Component.second, from: alarm.date)
        return dateInfo
    }
    
    @objc public static func requestAuthorization(_ completionHandler: ((Bool, Error?) -> Swift.Void)?) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if completionHandler != nil {
                completionHandler!(granted, error)
            }
        }
    }
}
