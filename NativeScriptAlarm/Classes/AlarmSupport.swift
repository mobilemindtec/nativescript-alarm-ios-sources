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



public class AlarmSupport : NSObject, AVAudioPlayerDelegate{
    
    public var audioPlayer: AVAudioPlayer?
    public var audioPlayerDelegate: AVAudioPlayerDelegate?
    public let scheduler: Scheduler = Scheduler()

    
    public static func initAVAudioSession(){
        
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
    }
    
    //AlarmApplicationDelegate protocol
    //
    public func playSound(_ soundName: String, vibrate: Bool, numberOfLoops: Int) {
        
        if vibrate {
            //vibrate phone first
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            //set vibrate callback
            AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                                  nil,
                                                  { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                                                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            },
                                                  nil)
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
    
    public func stopSound(){
        if audioPlayer != nil {
            if audioPlayer!.isPlaying {
                audioPlayer!.stop()
            }
        }
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
    }
    
    //AVAudioPlayerDelegate protocol
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if audioPlayerDelegate != nil {
            audioPlayerDelegate?.audioPlayerDidFinishPlaying?(player, successfully: flag)
        }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur: \(error)")
        if audioPlayerDelegate != nil {
            audioPlayerDelegate?.audioPlayerDecodeErrorDidOccur?(player, error: error)
        }
    }
    
    // executa quando o app está em segundo plano e a opção soneca é pressionada
    public func processSnooze(handleActionWithIdentifier identifier: String?, for notification: UILocalNotification) {
        
        var alarm: Alarm? = findAlarmByNotification(notification)
        if alarm != nil {
            alarm!.onSnooze = false
            if identifier == Id.snoozeIdentifier {
                scheduler.setNotificationForSnooze(alarm!)
                alarm!.onSnooze = true
            }
        }        
    }
    
    public func findAlarmByNotification(_ notification: UILocalNotification) -> Alarm? {
        
        let alarmModel = Alarms()
        var alarm: Alarm?
        
        if let userInfo = notification.userInfo {
            alarm = alarmModel.alarms.first(){
                it in it.id == userInfo["id"] as! Int
            }
        }
        
        return alarm
    }
    
}
