//
//  cobacloudkitApp.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 26/03/25.
//

//
//  cobacloudkitApp.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 26/03/25.
//

import SwiftUI
import SwiftData
import UserNotifications


class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct cobacloudkitApp: App {
    @State private var launchQuery: String? = UserDefaults.standard.string(forKey: "launchSearchQuery")

    // Step 2: Instantiate the delegate
    let notificationDelegate = NotificationDelegate()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self, Report.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Step 3: Assign the delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                NotificationManager.shared.requestPermission()
                UserDefaults.standard.removeObject(forKey: "launchSearchQuery")
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
