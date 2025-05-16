//
//  AlarmViewModel.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import Foundation
import Combine

class AlarmViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []
    
    func addAlarm(time: Date, label: String) {
        let newAlarm = Alarm(time: time, label: label, isOn: true)
        alarms.append(newAlarm)
    }
    
    func removeAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        alarm.isOn.toggle()
    }
}
