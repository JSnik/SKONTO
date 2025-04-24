//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by venu Gopal on 23/02/23.
//

import UIKit
import UserNotifications
import UserNotificationsUI
//import MoEngageRichNotification

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set App Group ID
//        MoEngageSDKRichNotification.setAppGroupID("com.easemytrades.stockkdaddy")
    }
  
    
    func didReceive(_ notification: UNNotification) {
        // Method to add template to UI
//        MoEngageSDKRichNotification.addPushTemplate(toController: self, withNotification: notification)
    }

}
