//
//  AlarmSchedulerDelegate.swift
//  Alarm-ios-swift
//
//  Created by natsu1211 on 2017/02/01.
//  Copyright © 2017年 LongGames. All rights reserved.
//

import Foundation
import UIKit

public protocol AlarmSchedulerDelegate {
    func setNotificationWithAlarm(_ alarm: Alarm)
    //helper
    func setNotificationForSnooze(_ alarm: Alarm)
    func setupNotificationSettings(_ alarm: Alarm) -> UIUserNotificationSettings
    func reSchedule()
    func checkNotification()
}

