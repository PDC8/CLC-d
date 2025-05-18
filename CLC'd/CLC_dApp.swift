//
//  CLC_dApp.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/14/25.
//

import SwiftUI

@main
struct LeetCodeAlarmClockApp: App {
    @StateObject var alarmViewModel = AlarmViewModel()
    
    init() {
       NotificationManager.requestPermission()
   }
    
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environmentObject(alarmViewModel)
        }
    }
}
 
