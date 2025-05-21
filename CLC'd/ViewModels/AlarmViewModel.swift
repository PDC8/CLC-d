//
//  AlarmViewModel.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

//import Foundation
//import Combine
//
//class AlarmViewModel: ObservableObject {
//    @Published var alarms: [Alarm] = []
//    @Published var activeAlarm: Alarm?
//    private var cancellables = Set<AnyCancellable>()
//
//    init() {
//        startTimer()
//    }
//    
//    func addAlarm(time: Date, label: String, problemType: ProblemType) {
//        let newAlarm = Alarm(time: time, label: label, problemType: problemType, isOn: true)
//        alarms.append(newAlarm)
//        NotificationManager.scheduleNotification(for: newAlarm)
//    }
//    
//    func removeAlarm(at offsets: IndexSet) {
//        alarms.remove(atOffsets: offsets)
//    }
//    
//    func toggleAlarm(_ alarm: Alarm) {
//        alarm.isOn.toggle()
//    }
//    
//    private func startTimer() {
//        Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                self?.checkAlarms()
//            }
//            .store(in: &cancellables)
//    }
//
//    private func checkAlarms() {
//        let now = Date()
//        for alarm in alarms where !alarm.isTriggered && alarm.isOn {
//            if Calendar.current.isDate(alarm.time, equalTo: now, toGranularity: .minute) {
//                switch alarm.problemType {
//                case .daily:
//                    getDailyQuestion { [weak self] title in
//                        self?.handleAlarmTrigger(alarm: alarm, title: title)
//                    }
//                case .easy, .medium, .hard:
//                    if let difficulty = alarm.problemType.apiDifficulty {
//                        getRandomQuestion(difficulty: difficulty) { [weak self] title in
//                            self?.handleAlarmTrigger(alarm: alarm, title: title)
//                        }
//                    }
//                case .random:
//                    let difficulties = ["EASY", "MEDIUM", "HARD"]
//                    let randomDiff = difficulties.randomElement()!
//                    getRandomQuestion(difficulty: randomDiff) { [weak self] title in
//                        self?.handleAlarmTrigger(alarm: alarm, title: title)
//                    }
//                }
//                alarm.isTriggered = true
//                activeAlarm = alarm
//                AudioManager.shared.playSound()
//                
//            }
//        }
//    }
//    
//    private func handleAlarmTrigger(alarm: Alarm, title: String?) {
//        guard let title = title else { return }
//        
//        DispatchQueue.main.async {
//            alarm.title = title
//            alarm.isTriggered = true
//            self.activeAlarm = alarm
//            AudioManager.shared.playSound()
//        }
//    }
//    
//    private func getDailyQuestion(completion: @escaping (String?) -> Void) {
//        let query = """
//            query getDailyProblem {
//                activeDailyCodingChallengeQuestion {
//                    question {
//                        title
//                    }
//                }
//            }
//            """
//        let body: [String: Any] = ["query": query]
//        
//        guard let url = URL(string: "https://leetcode.com/graphql") else {
//            print("URL error")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, _, _ in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                    print("JSON error")
//                    return
//            }
//            if let dataDict = json["data"] as? [String: Any],
//               let dailyChallenge = dataDict["activeDailyCodingChallengeQuestion"] as? [String: Any],
//               let question = dailyChallenge["question"] as? [String: Any],
//               let title = question["title"] as? String {
//                completion(title)
//            } else {
//                print("Something went wrong decoding the JSON.")
//                return
//            }
//        }.resume()
//    }
//    
//    private func getTotalQuestion(difficulty: String, completion: @escaping (Int?) -> Void) {
//        let query = """
//            query getProblems($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionListFilterInput) {
//                problemsetQuestionList: questionList(
//                    categorySlug: $categorySlug
//                    limit: $limit
//                    skip: $skip
//                    filters: $filters
//                ) {
//                    total: totalNum
//                }
//            }
//            """
//        let variables: [String: Any] = [
//                "categorySlug": "",
//                "limit": 1,
//                "skip": 0,
//                "filters": ["difficulty": difficulty]
//            ]
//        let body: [String: Any] = ["query": query, "variables": variables]
//        
//        guard let url = URL(string: "https://leetcode.com/graphql") else {
//            print("URL error")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, _, _ in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                    print("JSON error")
//                    return
//            }
//            if let dataDict = json["data"] as? [String: Any],
//               let problemList = dataDict["problemsetQuestionList"] as? [String: Any],
//               let total = problemList["total"] as? Int {
//                completion(total)
//            }
//            else {
//                print("Something went wrong decoding the JSON.")
//                return
//            }
//        }.resume()
//    }
//    
//    private func getRandomQuestion(difficulty: String, completion: @escaping (String?) -> Void) {
//        getTotalQuestion(difficulty: difficulty) { total in
//            guard let total = total
//            else {
//                print("getTotalQuestion error")
//                return
//            }
//
//            func fetchQuestion() {
//                let query = """
//                    query getProblems($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionListFilterInput) {
//                        problemsetQuestionList: questionList(
//                            categorySlug: $categorySlug
//                            limit: $limit
//                            skip: $skip
//                            filters: $filters
//                        ) {
//                            questions: data {
//                                difficulty
//                                isPaidOnly
//                                title
//                            }
//                        }
//                    }
//                    """
//                let variables: [String: Any] = [
//                    "categorySlug": "",
//                    "limit": 1,
//                    "skip": Int.random(in: 0..<total),
//                    "filters": ["difficulty": difficulty]
//                ]
//                let body: [String: Any] = ["query": query, "variables": variables]
//                
//                guard let url = URL(string: "https://leetcode.com/graphql") else {
//                    print("URL error")
//                    return
//                }
//                
//                var request = URLRequest(url: url)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//                
//                URLSession.shared.dataTask(with: request) { data, _, _ in
//                    if let data = data,
//                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let dataDict = json["data"] as? [String: Any],
//                       let problemList = dataDict["problemsetQuestionList"] as? [String: Any],
//                       let questions = problemList["questions"] as? [[String: Any]],
//                       let question = questions.first,
//                       let title = question["title"] as? String,
//                       let isPaidOnly = question["isPaidOnly"] as? Int {
//                        if isPaidOnly == 0 {
//                            completion(title)
//                        } else {
//                            print("Paid question, retrying...")
//                            fetchQuestion()
//                        }
//                    }
//                    else {
//                        print("Something went wrong decoding the JSON.")
//                        return
//                    }
//                }.resume()
//            }
//            fetchQuestion()
//        }
//    }
//
//    
//    func checkLatestSubmission(username: String, alarmTime: Date, completion: @escaping (Bool) -> Void) {
//        var validTime = false
//        var validStatus = false
//        var validTitle = false
//        let query = """
//            query recentAcSubmissions($username: String!) {
//                recentAcSubmissionList(username: $username, limit: 1) {
//                    timestamp
//                    statusDisplay
//                    title
//                }
//            }
//            """
//        let variables: [String: Any] = ["username": username]
//        let body: [String: Any] = ["query": query, "variables": variables]
//        
//        guard let url = URL(string: "https://leetcode.com/graphql") else {
//            print("URL error")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, _, _ in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
//                    print("JSON error")
//                    return
//            }
//            if let dataDict = json["data"] as? [String: Any],
//               let submissions = dataDict["recentAcSubmissionList"] as? [[String: Any]],
//               let latestSubmission = submissions.first,
//               let status = latestSubmission["statusDisplay"] as? String,
//               let timestamp = latestSubmission["timestamp"] as? String,
//               let submissionTitle = latestSubmission["title"] as? String {
//                let submissionTime = Int(timestamp)!
//                let alarmUnixTime = Int(alarmTime.timeIntervalSince1970)
//                if submissionTime >= alarmUnixTime {
//                    validTime = true
//                }
//                if status == "Accepted" {
//                    validStatus = true
//                }
//                if let alarm = self.activeAlarm {
//                    if !alarm.title.isEmpty && alarm.title == submissionTitle {
//                        validTitle = true
//                    }
//                }
//                DispatchQueue.main.async {
//                    completion(validTime && validStatus && validTitle)
//                }
//            } else {
//                print("Something went wrong decoding the JSON.")
//                return
//            }
//        }.resume()
//    }
//}
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

    func addAlarm(time: Date, label: String, problemType: ProblemType) {
        let newAlarm = Alarm(time: time, label: label, problemType: problemType, isOn: true)
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
        let now = Date()
        for alarm in alarms where !alarm.isTriggered && alarm.isOn {
            if Calendar.current.isDate(alarm.time, equalTo: now, toGranularity: .minute) {
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
        LeetCodeAPI.shared.checkLatestSubmission(username: username, alarmTime: alarmTime, activeAlarm: activeAlarm, completion: completion)
    }
}
