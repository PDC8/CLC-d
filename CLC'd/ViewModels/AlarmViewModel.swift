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
    @Published var failureMessage: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startTimer()
    }

    func addAlarm(hour: Int, minute: Int, label: String, problemType: ProblemType, repeatDays: Set<Days>) {
        let newAlarm = Alarm(hour: hour, minute: minute, label: label, problemType: problemType, isOn: true, repeatDays: repeatDays)
        alarms.append(newAlarm)
        NotificationManager.scheduleNotification(for: newAlarm)
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
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentSecond = calendar.component(.second, from: now)
        let currentWeekday = calendar.component(.weekday, from: now) - 1
        let currentWeekdayEnum = Days(rawValue: currentWeekday)!
        for alarm in alarms where alarm.isOn &&
            (alarm.repeatDays.contains(currentWeekdayEnum) || alarm.repeatDays.isEmpty) {
            if alarm.hour == currentHour && alarm.minute == currentMinute && currentSecond == 0{
                switch alarm.problemType {
                case .daily:
                    LeetCodeAPI.shared.getDailyQuestion { [weak self] title in
                        self?.handleAlarmTrigger(alarm: alarm, title: title)
                    }
                case .easy, .medium, .hard:
                    if let difficulty = alarm.problemType.apiDifficulty {
                        LeetCodeAPI.shared.getRandomQuestion(difficulty: difficulty) { [weak self] title in
                            self?.handleAlarmTrigger(alarm: alarm, title: title)
                        }
                    }
                case .random:
                    let difficulties = ["EASY", "MEDIUM", "HARD"]
                    let randomDiff = difficulties.randomElement()!
                    LeetCodeAPI.shared.getRandomQuestion(difficulty: randomDiff) { [weak self] title in
                        self?.handleAlarmTrigger(alarm: alarm, title: title)
                    }
                }
                alarm.isTriggered = true
                activeAlarm = alarm
                AudioManager.shared.playSound()
            }
        }
    }

    private func handleAlarmTrigger(alarm: Alarm, title: String?) {
        guard let title = title else { return }
        DispatchQueue.main.async {
            alarm.title = title
            alarm.isTriggered = true
            self.activeAlarm = alarm
            AudioManager.shared.playSound()
        }
    }

    func checkLatestSubmission(username: String, alarmTime: Date, completion: @escaping (Bool) -> Void) {
        LeetCodeAPI.shared.checkLatestSubmission(username: username,
                                                 alarmTime: alarmTime,
                                                 activeAlarm: activeAlarm) { [weak self] success, failureReason in
            DispatchQueue.main.async {
                self?.failureMessage = failureReason
                completion(success)
            }
        }
    }
}
