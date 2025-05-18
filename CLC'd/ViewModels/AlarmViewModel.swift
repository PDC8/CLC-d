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
    @Published var activeAlarm: Alarm?
    private var cancellables = Set<AnyCancellable>()

    init() {
        startTimer()
    }
    
    func addAlarm(time: Date, label: String) {
        let newAlarm = Alarm(time: time, label: label, isOn: true)
        alarms.append(newAlarm)
        NotificationManager.scheduleNotification(for: newAlarm) // Schedule notification
    }
    
    func removeAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
    
    func toggleAlarm(_ alarm: Alarm) {
        alarm.isOn.toggle()
    }
    
    private func startTimer() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkAlarms()
            }
            .store(in: &cancellables)
    }

    private func checkAlarms() {
        let now = Date()
        for alarm in alarms where !alarm.isTriggered && alarm.isOn {
            if Calendar.current.isDate(alarm.time, equalTo: now, toGranularity: .minute) {
                alarm.isTriggered = true
                print("hello", alarm.isTriggered, alarm.isOn)
                activeAlarm = alarm
                AudioManager.shared.playSound()
            }
        }
    }
}
