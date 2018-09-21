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

@objc public class Alarm : NSObject, PropertyReflectable {
    @objc public var date: Date = Date()
    @objc public var enabled: Bool = false
    @objc public var snoozeEnabled: Bool = false
    @objc public var id: Int = 0
    @objc public var soundName: String = ""
    @objc public var snoozeInterval: Int = 15
    @objc public var repeatIntervalHours: Int = 0
    @objc public var repeatIntervalDays: Int = 0
    @objc public var buttonOkText: String = "OK"
    @objc public var buttonSnoozeText: String = "Soneca"
    @objc public var buttonOpenText: String = "Abrir"
    @objc public var alertTitle: String = ""
    @objc public var alertBody: String = ""
    @objc public var onSnooze: Bool = false
    @objc public var showButtonOk: Bool = false
    @objc public var showButtonSnooze: Bool = false
    @objc public var showButtonOpen: Bool = false
    @objc public var now: Bool = false
    @objc public var categoty: String = "myAlarmCategory"
    
    @objc public override init(){}

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
        onSnooze = dict["onSnooze"] as! Bool
        id = dict["id"] as! Int
        soundName = dict["soundName"] as! String
        snoozeInterval = dict["snoozeInterval"] as! Int
        repeatIntervalHours = dict["repeatIntervalHours"] as! Int
        repeatIntervalDays = dict["repeatIntervalDays"] as! Int
        buttonOkText = dict["buttonOkText"] as! String
        buttonSnoozeText = dict["buttonSnoozeText"] as! String
        buttonOpenText = dict["buttonOpenText"] as! String
        alertBody = dict["alertBody"] as! String
        alertTitle = dict["alertTitle"] as! String        
        showButtonOk = dict["showButtonOk"] as! Bool
        showButtonOpen = dict["showButtonOpen"] as! Bool
        showButtonSnooze = dict["showButtonSnooze"] as! Bool
        now = dict["now"] as! Bool
        categoty = dict["categoty"] as! String
    }
    
    @objc public static var propertyCount: Int = 19
}

public extension Alarm {
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self.date)
    }
}

//This can be considered as a viewModel
@objc public class Alarms : NSObject, Persistable {
    @objc public let ud: UserDefaults = UserDefaults.standard
    @objc public let persistKey: String = "myAlarmKey"
    @objc public var alarms: [Alarm] = [] {
        //observer, sync with UserDefaults
        didSet{
            persist()
        }
    }
    
    private func getAlarmsDictRepresentation()->[PropertyReflectable.RepresentationType] {
        let items = alarms.filter(){
            (it:Alarm) in it.enabled
        }
        return items.map {$0.propertyDictRepresentation}
    }
    
    @objc public override init() {        
        super.init()
        alarms = self.getAlarms()
    }
    
    @objc public func persist() {
        var items = getAlarmsDictRepresentation()
        ud.set(items, forKey: persistKey)
        ud.synchronize()
    }
    
    @objc public func unpersist() {
        for key in ud.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
    }
    
    @objc public var count: Int {
        let items = alarms.filter(){
            (it:Alarm) in it.enabled
        }
        return items.count
    }
    
    //helper, get all alarms from Userdefaults
    private func getAlarms() -> [Alarm] {
        let array = UserDefaults.standard.array(forKey: persistKey)
        guard let alarmArray = array else{
            return [Alarm]()
        }
        if let dicts = alarmArray as? [PropertyReflectable.RepresentationType]{
            
            var results: [Alarm] = []
            
            dicts.forEach(){
                it in
                if (it.count == Alarm.propertyCount){
                    results.append(Alarm(it))
                }
            }
            /*
            if dicts.first?.count == Alarm.propertyCount {
                var results = dicts.map{Alarm($0)}
                return results.filter(){
                    (it:Alarm) in it.enabled
                }
            }*/
            return results.filter(){
                (it:Alarm) in it.enabled
            }
        }
        unpersist()
        return [Alarm]()
    }
}
