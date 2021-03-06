//
//  AppDelegate.swift
//  AlarmManager
//
//  Created by Ricardo Bocchi on 12/09/2018.
//  Copyright © 2018 Ricardo Bocchi. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AudioToolbox
import AVFoundation
import NativeScriptAlarm
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let alarmSupport: AlarmSupport = AlarmSupport()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        alarmSupport.onNotificationReceived  = {
            alarm in
            print("onNotificationReceived \(alarm)")
        }
        
        alarmSupport.onNotificationActionOk  = {
            alarm in
            print("onNotificationActionOk \(alarm)")
        }

        alarmSupport.onNotificationActionSnooze  = {
            alarm in
            print("onNotificationActionSnooze \(alarm)")
        }
        
        alarmSupport.onNotificationClick  = {
            alarm in
            print("onNotificationClick \(alarm)")
            print("onNotificationClick id \(alarm.id)")
        }
        
        alarmSupport.onNotificationActionOpen  = {
            alarm in
            print("onNotificationActionOpen \(alarm)")
            print("onNotificationActionOpen id \(alarm.id)")
        }

        AlarmSupport.setUpNotifications(alarmSupport)
        AlarmSupport.requestAuthorization(nil)
        
        return true
    }

    
    
    /*
        
    // executa quando o app está em primeiro plano
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        print("did receive notification")
        
        //show an alert window
        let storageController = UIAlertController(title: "Alarm", message: nil, preferredStyle: .alert)
        
        var alarm: Alarm? = alarmSupport.findAlarmByNotification(notification)
        
        alarmSupport.playSound(alarm!.soundName, true, -1)
        
        //schedule notification for snooze
        if alarm!.snoozeEnabled {
            let snoozeOption = UIAlertAction(title: alarm!.buttonSnoozeText, style: .default) {
                (action:UIAlertAction)->Void in self.alarmSupport.stopSound()
                self.alarmSupport.scheduler.setNotificationForSnooze(alarm!)
            }
            storageController.addAction(snoozeOption)
        }
        
        let stopOption = UIAlertAction(title: alarm!.buttonOkText, style: .default) {
            (action:UIAlertAction)->Void in self.alarmSupport.stopSound()
            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
            
            alarm!.onSnooze = false
            //change UI
            var mainVC = self.window?.visibleViewController as? ViewController //MainAlarmViewController
            if mainVC == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                mainVC = storyboard.instantiateViewController(withIdentifier: "Alarm") as? ViewController
            }
            //mainVC!.changeSwitchButtonState(index: index)
        }
        
        storageController.addAction(stopOption)
        window?.visibleViewController?.navigationController?.present(storageController, animated: true, completion: nil)
    }
    
    // executa quando o app está em segundo plano e a opção soneca é pressionada
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        let alarmSupport: AlarmSupport = AlarmSupport()
        alarmSupport.processSnooze(handleActionWithIdentifier: identifier, for: notification)
        completionHandler()
    }
 */
    
    @objc public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                             willPresent notification: UNNotification,
                                             withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        print("userNotificationCenter1 ")
        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    @objc public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                             didReceive response: UNNotificationResponse,
                                             withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("userNotificationCenter2 ")
    }
    
    //print out all registed NSNotification for debug
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        //print(notificationSettings.types.rawValue)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }

    // MARK: - Core Data stack
    
    /*
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AlarmManager")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
 
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    */
}

