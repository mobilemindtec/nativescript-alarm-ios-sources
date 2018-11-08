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
    
    var alarmScheduler:Scheduler = Scheduler()
    var alarmModel: Alarms = Alarms()
    //var segueInfo: SegueInfo!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var txtAlarms: UILabel!

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
        let tempAlarm = Alarm()
        tempAlarm.id = 3
        tempAlarm.date = timePicker.date
        tempAlarm.enabled = true
        tempAlarm.snoozeEnabled = true
        tempAlarm.onSnooze = false    
        tempAlarm.alertTitle = "title"
        tempAlarm.alertBody = "body"
        tempAlarm.soundName = "bell"
        tempAlarm.showButtonSnooze = false
        tempAlarm.showButtonOk = false
        tempAlarm.showButtonOpen = true
        alarmScheduler.schedule(tempAlarm)
    }
    
    @IBAction func onShow(sender: UIButton){
        var tempAlarm = Alarm()
        tempAlarm.id = 2
        tempAlarm.enabled = true
        tempAlarm.alertTitle = "title"
        tempAlarm.alertBody = "body"
        alarmScheduler.show(tempAlarm)
    }
    @IBAction func onCancel(sender: UIButton){
        alarmScheduler.cancelAll()
        alarmScheduler.removeNotificaton()
    }
    
    @IBAction func onGetAlarms(sender: UIButton){
        print(alarmScheduler.getAlarms())
    }


}

