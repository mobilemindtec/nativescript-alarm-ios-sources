//
//  Identifier.swift
//  Alarm-ios-swift
//
//  Created by natsu1211 on 2017/02/02.
//  Copyright © 2017年 LongGames. All rights reserved.
//

import Foundation

@objc public class Id: NSObject {
    @objc public static let stopIdentifier = "Alarm-ios-swift-stop"
    @objc public static let snoozeIdentifier = "Alarm-ios-swift-snooze"
    @objc public static let addSegueIdentifier = "addSegue"
    @objc public static let editSegueIdentifier = "editSegue"
    @objc public static let saveSegueIdentifier = "saveEditSegue"
    @objc public static let soundSegueIdentifier = "soundSegue"
    @objc public static let labelSegueIdentifier = "labelEditSegue"
    @objc public static let weekdaysSegueIdentifier = "weekdaysSegue"
    @objc public static let settingIdentifier = "setting"
    @objc public static let musicIdentifier = "musicIdentifier"
    @objc public static let alarmCellIdentifier = "alarmCell"
    
    @objc public static let labelUnwindIdentifier = "labelUnwindSegue"
    @objc public static let soundUnwindIdentifier = "soundUnwindSegue"
    @objc public static let weekdaysUnwindIdentifier = "weekdaysUnwindSegue"

    @objc public override init(){}
}
