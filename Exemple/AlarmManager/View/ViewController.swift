//
//  ViewController.swift
//  AlarmManager
//
//  Created by Ricardo Bocchi on 12/09/2018.
//  Copyright © 2018 Ricardo Bocchi. All rights reserved.
//

import Foundation
import UIKit
import NativeScriptAlarm

class ViewController: UIViewController {
    
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    //var segueInfo: SegueInfo!
    @IBOutlet var timePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alarmModel=Alarms()
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onAgendar(sender: UIButton){
        
        print("\(timePicker.date)")
        
        let date = Scheduler.correctSecondComponent(date: timePicker.date)
        
        print("\(date)")
        
        //let index = segueInfo.curCellIndex
        var tempAlarm = Alarm()
        tempAlarm.date = date
        //tempAlarm.label = segueInfo.label
        tempAlarm.enabled = true
        //tempAlarm.mediaLabel = segueInfo.mediaLabel
        //tempAlarm.mediaID = segueInfo.mediaID
        tempAlarm.snoozeEnabled = true
        //tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
        //tempAlarm.uuid = UUID().uuidString
        tempAlarm.onSnooze = false
        tempAlarm.soundName = "bell"
        /*
        if segueInfo.isEditMode {
            alarmModel.alarms[index] = tempAlarm
        }*/
        //else {
            alarmModel.alarms.append(tempAlarm)
        //}
        
        alarmScheduler.reSchedule()
        
    }
    
}

