//
//  Scheduler.swift
//  Alarm-ios-swift
//
//  Created by longyutao on 16/1/15.
//  Copyright (c) 2016年 LongGames. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

@objc public class Scheduler : NSObject
{
    var alarmModel: Alarms = Alarms()
    
    @objc public override init(){}
    
    private func syncAlarmModel() {
        alarmModel = Alarms()
    }
    
    @objc public func scheduleForSnooze(_ alarm: Alarm) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let snoozeTime = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: alarm.snoozeInterval, to: now, options:.matchStrictly)!
        var alarm = alarm
        alarm.date = snoozeTime
        schedule(alarm)
    }
    
    @objc public func reSchedule() {
        //cancel all and register all is often more convenient
        //UIApplication.shared.cancelAllLocalNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        syncAlarmModel()
        let now = Date()
        
        for i in 0..<alarmModel.count{
            let alarm = alarmModel.alarms[i]
            
            if alarm.date < now {
                alarm.enabled = false
                print("alarm date \(alarm.date) is less that now \(now)")
            }
            
            if alarm.enabled {
                self.createNotification(alarm)
            }
        }
        
        alarmModel.persist()
    }
        
    @objc public func schedule(_ alarm: Alarm){
        syncAlarmModel()
        let otherIndex = alarmModel.alarms.index(){ (it:Alarm) in it.id == alarm.id }
        if(otherIndex != nil){
            alarmModel.alarms.remove(at: otherIndex!)
        }
        alarmModel.alarms.append(alarm)
        self.reSchedule()
    }
    
    @objc public func cancel(_ id: Int){
        syncAlarmModel()
        alarmModel.alarms.forEach(){
            (it:Alarm) in
            if(it.id == id){
                var p = it
                p.enabled = false
            }
        }
        alarmModel.persist()
    
        self.reSchedule()
    }
    
    @objc public func cancelAll(){
        syncAlarmModel()
        alarmModel.alarms.forEach(){
            (it:Alarm) in
            var p = it
            p.enabled = false
        }
        alarmModel.persist()
        
        self.reSchedule()
    }
    
    @objc public func show(_ alarm: Alarm){
        let calendar = Calendar.current
        var date = Date()
        alarm.date = calendar.date(byAdding: .second, value: 2, to: date)!
        alarm.now = true
        self.schedule(alarm)
    }
    
    @objc public func removeNotificaton(){
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func createNotification(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = alarm.alertTitle
        content.body = alarm.alertBody
        
        if alarm.soundName != "" { 
            content.sound = UNNotificationSound.init(named: "\(alarm.soundName).mp3")
        } else {
            content.sound = UNNotificationSound.default()
        }
        
        content.userInfo = ["id": alarm.id]
        content.categoryIdentifier = alarm.categoty
        
        
        var actions: [UNNotificationAction] = []
        
        
        if alarm.showButtonOk {
            let action = UNNotificationAction(identifier: "OK_ACTION", title: alarm.buttonOkText, options: UNNotificationActionOptions(rawValue: 0))
            actions.append(action)
        }
        
        if alarm.showButtonSnooze && alarm.snoozeEnabled {
            let action = UNNotificationAction(identifier: "SNOOZE_ACTION", title: alarm.buttonSnoozeText, options: UNNotificationActionOptions(rawValue: 0))
            actions.append(action)
        }
        
        if alarm.showButtonOpen {
            let action = UNNotificationAction(identifier: "OK_OPEN", title: alarm.buttonOpenText, options: UNNotificationActionOptions(rawValue: 0))
            actions.append(action)
        }
        
        let center = UNUserNotificationCenter.current()
        
        if !actions.isEmpty {
            let custonCategory = UNNotificationCategory(identifier: alarm.categoty,
                                                     actions: actions,
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
            
            center.setNotificationCategories([custonCategory])
        }

        
        // Configure the trigger for a 7am wakeup.
        let calendar = Calendar.current
        var dateInfo = DateComponents()
        dateInfo.year = calendar.component(Calendar.Component.year, from: alarm.date)
        dateInfo.month = calendar.component(Calendar.Component.month, from: alarm.date)
        dateInfo.day = calendar.component(Calendar.Component.day, from: alarm.date)
        dateInfo.hour = calendar.component(Calendar.Component.hour, from: alarm.date)
        dateInfo.minute = calendar.component(Calendar.Component.minute, from: alarm.date)
        dateInfo.second = calendar.component(Calendar.Component.second, from: alarm.date)
        
        print("notification time \(dateInfo)")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "\(alarm.categoty)_\(alarm.id)", content: content, trigger: trigger)
        
        
        
        center.add(request, withCompletionHandler: {
            error in
            if let e = error {
                print("error on add notification center: \(e.localizedDescription)")
            }
        })
    }
    
    @objc public func getAlarms() -> [Alarm] {
        syncAlarmModel()
        return alarmModel.alarms
    }
    
    /*
    @objc public func setupNotificationSettings(_ alarm: Alarm) -> UIUserNotificationSettings {
        // Specify the notification types.
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
        
        // Specify the notification actions.
        
        var actionsArray: [UIUserNotificationAction] = []
        
        if(alarm.showButtonOk){
            let stopAction = UIMutableUserNotificationAction()
            stopAction.identifier = Id.stopIdentifier
            stopAction.title = alarm.buttonOkText
            stopAction.activationMode = UIUserNotificationActivationMode.background
            stopAction.isDestructive = false
            stopAction.isAuthenticationRequired = false
            actionsArray.append(stopAction)
        }
        
        if(alarm.showButtonSnooze && alarm.snoozeEnabled){
            let snoozeAction = UIMutableUserNotificationAction()
            snoozeAction.identifier = Id.snoozeIdentifier
            snoozeAction.title = alarm.buttonSnoozeText
            snoozeAction.activationMode = UIUserNotificationActivationMode.background
            snoozeAction.isDestructive = false
            snoozeAction.isAuthenticationRequired = false
            actionsArray.append(snoozeAction)
        }
        
        //let actionsArray = alarm.snoozeEnabled ? [UIUserNotificationAction](arrayLiteral: snoozeAction, stopAction) : [UIUserNotificationAction](arrayLiteral: stopAction)
        //let actionsArrayMinimal = alarm.snoozeEnabled ? [UIUserNotificationAction](arrayLiteral: snoozeAction, stopAction) : [UIUserNotificationAction](arrayLiteral: stopAction)
        // Specify the category related to the above actions.
        let alarmCategory = UIMutableUserNotificationCategory()
        alarmCategory.identifier = alarm.categoty
        alarmCategory.setActions(actionsArray, for: .default)
        //alarmCategory.setActions(actionsArray, for: .minimal)
        
        
        let categoriesForSettings = Set(arrayLiteral: alarmCategory)
        // Register the notification settings.
        let newNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: categoriesForSettings)
        UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
        return newNotificationSettings
    }
    
    private func correctDate(_ date: Date, onWeekdaysForNotify weekdays:[Int]) -> [Date]
    {
        var correctedDate: [Date] = [Date]()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let flags: NSCalendar.Unit = [NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.day]
        let dateComponents = (calendar as NSCalendar).components(flags, from: date)
        let weekday:Int = dateComponents.weekday!
        
        //no repeat
        if weekdays.isEmpty {
            //scheduling date is eariler than current date
            if date < now {
                //plus one day, otherwise the notification will be fired righton
                correctedDate.append((calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 1, to: date, options:.matchStrictly)!)
            }
            else { //later
                correctedDate.append(date)
            }
            return correctedDate
        }
            //repeat
        else {
            let daysInWeek = 7
            correctedDate.removeAll(keepingCapacity: true)
            for wd in weekdays {
                
                var wdDate: Date!
                //schedule on next week
                if compare(weekday: wd, with: weekday) == .before {
                    wdDate =  (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd+daysInWeek-weekday, to: date, options:.matchStrictly)!
                }
                    //schedule on today or next week
                else if compare(weekday: wd, with: weekday) == .same {
                    //scheduling date is eariler than current date, then schedule on next week
                    if date.compare(now) == ComparisonResult.orderedAscending {
                        wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: daysInWeek, to: date, options:.matchStrictly)!
                    }
                    else { //later
                        wdDate = date
                    }
                }
                    //schedule on next days of this week
                else { //after
                    wdDate =  (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd-weekday, to: date, options:.matchStrictly)!
                }
                
                //fix second component to 0
                wdDate = Scheduler.correctSecondComponent(date: wdDate, calendar: calendar)
                correctedDate.append(wdDate)
            }
            return correctedDate
        }
    }
    
    @objc public static func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian))->Date {
        let second = calendar.component(.second, from: date)
        let d = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.second, value: -second, to: date, options:.matchStrictly)!
        return d
    }
    
    @objc public func setNotificationWithAlarm(_ alarm: Alarm) {
        let AlarmNotification: UILocalNotification = UILocalNotification()
        AlarmNotification.alertBody = alarm.alertBody
        AlarmNotification.alertAction = alarm.alertBody
        AlarmNotification.category = alarm.categoty
        AlarmNotification.soundName = alarm.soundName + ".mp3"
        AlarmNotification.timeZone = TimeZone.current
        //let repeating: Bool = !alarm.weekdays.isEmpty
        AlarmNotification.userInfo = ["id": alarm.id]
        //repeat weekly if repeat weekdays are selected
        //no repeat with snooze notification
        /*
         if !alarm.weekdays.isEmpty && !notification.onSnooze{
         AlarmNotification.repeatInterval = NSCalendar.Unit.weekOfYear
         }*/
        
        let datesForNotification = alarm.now ? [alarm.date] : correctDate(alarm.date, onWeekdaysForNotify: [])
        
        let index = alarmModel.alarms.index(){
            (it:Alarm) in it.id == alarm.id
        }
        
        syncAlarmModel()
        for d in datesForNotification {
            if alarm.onSnooze {
                alarmModel.alarms[index!].date = Scheduler.correctSecondComponent(date: alarmModel.alarms[index!].date)
            }
            else {
                alarmModel.alarms[index!].date = d
            }
            AlarmNotification.fireDate = d
            print("** \(AlarmNotification.fireDate)")
            UIApplication.shared.scheduleLocalNotification(AlarmNotification)
        }
        setupNotificationSettings(alarm)
        
    }
    
    // workaround for some situation that alarm model is not setting properly (when app on background or not launched)
    @objc public func checkNotification() {
        alarmModel = Alarms()
        let notifications = UIApplication.shared.scheduledLocalNotifications
        if notifications!.isEmpty {
            for i in 0..<alarmModel.count {
                alarmModel.alarms[i].enabled = false
            }
        }
        else {
            for (i, alarm) in alarmModel.alarms.enumerated() {
                var isOutDated = true
                if alarm.onSnooze {
                    isOutDated = false
                }
                for n in notifications! {
                    if alarm.date >= n.fireDate! {
                        isOutDated = false
                    }
                }
                if isOutDated {
                    alarmModel.alarms[i].enabled = false
                }
            }
        }
    }
    
    private enum weekdaysComparisonResult {
        case before
        case same
        case after
    }
    
    private func compare(weekday w1: Int, with w2: Int) -> weekdaysComparisonResult
    {
        if w1 != 1 && w2 == 1 {return .before}
        else if w1 == w2 {return .same}
        else {return .after}
    }
    
    private func minFireDateWithIndex(notifications: [UILocalNotification]) -> (Date, Int)? {
        if notifications.isEmpty {
            return nil
        }
        var minIndex = -1
        var minDate: Date = notifications.first!.fireDate!
        for n in notifications {
            let index = n.userInfo!["index"] as! Int
            if(n.fireDate! <= minDate) {
                minDate = n.fireDate!
                minIndex = index
            }
        }
        return (minDate, minIndex)
    }
    */

}
