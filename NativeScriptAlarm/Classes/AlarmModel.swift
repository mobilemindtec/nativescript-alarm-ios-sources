//
//  AlarmModel.swift
//  Alarm-ios-swift
//
//  Created by longyutao on 15-2-28.
//  Updated on 17-01-24
//  Copyright (c) 2015年 LongGames. All rights reserved.
//

import Foundation
import MediaPlayer

public  struct Alarm: PropertyReflectable {
    public var date: Date = Date()
    public var enabled: Bool = false
    public var snoozeEnabled: Bool = false
    //var repeatWeekdays: [Int] = []
    //var uuid: String = ""
    //var mediaID: String = ""
    //var mediaLabel: String = "bell"
    //var label: String = "Alarm"
    //var onSnooze: Bool = false
    
    
    public var id: Int = 0
    public var soundName: String = ""
    public var snoozeInterval: Int = 15
    public var repeatIntervalHours: Int = 0
    public var repeatIntervalDays: Int = 0
    
    public var buttonOkText: String = "OK"
    public var buttonSnoozeText: String = "Soneca"
    public var alertBody: String = ""
    public var alertAction: String = "Abrir"
    
    public var onSnooze: Bool = false
    //var weekdays: [Int] = []
    
    var categoty: String = "myAlarmCategory"
    
    
    public init(){}

    
    public init(id:Int, date:Date, enabled:Bool, snoozeEnabled:Bool){
        self.id = id
        self.date = date
        self.enabled = enabled
        self.snoozeEnabled = snoozeEnabled
    }
    
    public init(_ dict: PropertyReflectable.RepresentationType){
        date = dict["date"] as! Date
        enabled = dict["enabled"] as! Bool
        snoozeEnabled = dict["snoozeEnabled"] as! Bool
        //repeatWeekdays = dict["repeatWeekdays"] as! [Int]
        //uuid = dict["uuid"] as! String
        //mediaID = dict["mediaID"] as! String
        //mediaLabel = dict["mediaLabel"] as! String
        //label = dict["label"] as! String
        onSnooze = dict["onSnooze"] as! Bool
        id = dict["id"] as! Int
        
        soundName = dict["soundName"] as! String
        snoozeInterval = dict["snoozeInterval"] as! Int
        repeatIntervalHours = dict["repeatIntervalHours"] as! Int
        repeatIntervalDays = dict["repeatIntervalDays"] as! Int
        
        buttonOkText = dict["buttonOkText"] as! String
        buttonSnoozeText = dict["buttonSnoozeText"] as! String
        alertBody = dict["alertBody"] as! String
        alertAction = dict["alertAction"] as! String
    }
    
    public static var propertyCount: Int = 14
}

public extension Alarm {
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self.date)
    }
}

//This can be considered as a viewModel
public class Alarms: Persistable {
    public let ud: UserDefaults = UserDefaults.standard
    public let persistKey: String = "myAlarmKey"
    public var alarms: [Alarm] = [] {
        //observer, sync with UserDefaults
        didSet{
            persist()
        }
    }
    
    private func getAlarmsDictRepresentation()->[PropertyReflectable.RepresentationType] {
        return alarms.map {$0.propertyDictRepresentation}
    }
    
    public init() {
        alarms = getAlarms()
    }
    
    public func persist() {
        ud.set(getAlarmsDictRepresentation(), forKey: persistKey)
        ud.synchronize()
    }
    
    public func unpersist() {
        for key in ud.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
    }
    
    public var count: Int {
        return alarms.count
    }
    
    //helper, get all alarms from Userdefaults
    private func getAlarms() -> [Alarm] {
        let array = UserDefaults.standard.array(forKey: persistKey)
        guard let alarmArray = array else{
            return [Alarm]()
        }
        if let dicts = alarmArray as? [PropertyReflectable.RepresentationType]{
            if dicts.first?.count == Alarm.propertyCount {
                return dicts.map{Alarm($0)}
            }
        }
        unpersist()
        return [Alarm]()
    }
}
