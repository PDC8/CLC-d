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
    
    func addAlarm(time: Date, label: String, problemType: String) {
        let newAlarm = Alarm(time: time, label: label, problemType: problemType, isOn: true)
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
                activeAlarm = alarm
                AudioManager.shared.playSound()
//                startSubmissionCheck(for: alarm)
            }
        }
    }
    
//    private func startSubmissionCheck(for alarm: Alarm) {
////        guard let username = UserDefaults.standard.string(forKey: "LeetCodeUsername") else {
////            return
////        }
//        let username = "peidongchen2004"
//        //Poll every 30 sec
//        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] timer in
//            self?.checkLatestSubmission(username: username, alarmTime: alarm.time) { solved in
//                if solved {
//                    timer.invalidate()
//                    AudioManager.shared.stopSound()
//                    alarm.isTriggered = false
//                }
//            }
//        }
//    }
    
    func checkLatestSubmission(username: String, alarmTime: Date, completion: @escaping (Bool) -> Void) {
        var validTime = false
        var validStatus = false
        let query = """
            query recentAcSubmissions($username: String!) {
              recentAcSubmissionList(username: $username, limit: 1) {
                timestamp
                statusDisplay
              }
            }
            """
        let variables: [String: Any] = ["username": username]
        let body: [String: Any] = ["query": query, "variables": variables]
        
        guard let url = URL(string: "https://leetcode.com/graphql") else {
            DispatchQueue.main.async {
                completion(validTime && validStatus)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    DispatchQueue.main.async {
                        completion(validTime && validStatus)
                    }
                    return
            }
            if let dataDict = json["data"] as? [String: Any],
               let submissions = dataDict["recentAcSubmissionList"] as? [[String: Any]],
               let latestSubmission = submissions.first,
               let status = latestSubmission["statusDisplay"] as? String,
               let timestamp = latestSubmission["timestamp"] as? String {
                let submissionTime = Int(timestamp)!
                let alarmUnixTime = Int(alarmTime.timeIntervalSince1970)
                if submissionTime >= alarmUnixTime {
                    validTime = true
                }
                if status == "Accepted" {
                    validStatus = true
                }
                print(validTime, validStatus)
            }
            else {
                print("Something went wrong decoding the JSON.")
            }

            DispatchQueue.main.async {
                completion(validTime && validStatus)
            }
        }.resume()
    }
}
