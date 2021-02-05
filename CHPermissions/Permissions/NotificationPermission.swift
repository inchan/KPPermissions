//
//  NotificationPermission.swift
//  Permissions
//
//  Created by kay on 2021/01/20.
//

import Foundation
import UIKit
import UserNotifications

struct NotificationPermission: CHPermissionable {
        
    var status: CHStatus {
        switch fetchNotificationStatus() {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .provisional, .ephemeral: return .restricted
        default: return .denied
        }
    }
    
    func request(completion: @escaping CHClouser.Void) {
        if #available(iOS 10.0, tvOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                completion()
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            completion()
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func fetchNotificationStatus() -> UNAuthorizationStatus? {
        var NotificationSettings: UNNotificationSettings?
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
            UNUserNotificationCenter.current().getNotificationSettings { setttings in
                NotificationSettings = setttings
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return NotificationSettings?.authorizationStatus
    }
}