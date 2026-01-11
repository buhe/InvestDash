//
//  InvestSchedule.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/9/20.
//

import Foundation
import UserNotifications
import SwiftUI

struct InvestSchedule {
    static let shared: InvestSchedule = InvestSchedule()

    func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge, .carPlay], completionHandler: { (granted, error) in
                    if granted {
                        print("允許")
                    } else {
                        print("不允許")
                    }
                })
    }
    func stop(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }
    func send(cycle: String) -> String {
        let id = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "Update your equity"
        
        content.sound = UNNotificationSound.default
        content.badge = 1
        var c = 61.0
        if cycle == "monthly" {
            c = 60.0 * 60.0 * 24.0 * 30.0
            content.subtitle = "It's time for monthly reminders"
        } else {
            c = 7.0 * 24.0 * 60.0 * 60.0
            content.subtitle = "It's time for weekly reminders"
        }
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: c, repeats: true)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        return id
    }
}
