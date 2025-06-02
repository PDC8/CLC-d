//
//  LeetCodeAPI.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/21/25.
//

import Foundation

class LeetCodeAPI {
    static let shared = LeetCodeAPI()
    
    private init() {}
    
    private func performRequest(body: [String: Any], completion: @escaping ([String: Any]) -> Void) {
        guard let url = URL(string: "https://leetcode.com/graphql") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Failed to decode response")
                return
            }
            completion(json)
        }.resume()
    }
    
    func getDailyQuestion(completion: @escaping (String?) -> Void) {
        let query = """
            query getDailyProblem {
                activeDailyCodingChallengeQuestion {
                    question {
                        title
                    }
                }
            }
            """
        let body: [String: Any] = ["query": query]
        
        self.performRequest(body: body) { json in
            if let dataDict = json["data"] as? [String: Any],
               let dailyChallenge = dataDict["activeDailyCodingChallengeQuestion"] as? [String: Any],
               let question = dailyChallenge["question"] as? [String: Any],
               let title = question["title"] as? String {
                completion(title)
            } else {
                print("Something went wrong decoding the JSON.")
                return
            }
        }
    }
    
    private func getTotalQuestion(difficulty: String, completion: @escaping (Int?) -> Void) {
        let query = """
            query getProblems($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionListFilterInput) {
                problemsetQuestionList: questionList(
                    categorySlug: $categorySlug
                    limit: $limit
                    skip: $skip
                    filters: $filters
                ) {
                    total: totalNum
                }
            }
            """
        let variables: [String: Any] = [
            "categorySlug": "",
            "limit": 1,
            "skip": 0,
            "filters": ["difficulty": difficulty]
        ]
        let body: [String: Any] = ["query": query, "variables": variables]
        
        self.performRequest(body: body) { json in
            if let dataDict = json["data"] as? [String: Any],
               let problemList = dataDict["problemsetQuestionList"] as? [String: Any],
               let total = problemList["total"] as? Int {
                completion(total)
            }
            else {
                print("Something went wrong decoding the JSON.")
                return
            }
        }
    }
    
    func getRandomQuestion(difficulty: String, completion: @escaping (String?) -> Void) {
        getTotalQuestion(difficulty: difficulty) { total in
            guard let total = total
            else {
                print("getTotalQuestion error")
                return
            }
            
            func fetchQuestion() {
                let query = """
                    query getProblems($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionListFilterInput) {
                        problemsetQuestionList: questionList(
                            categorySlug: $categorySlug
                            limit: $limit
                            skip: $skip
                            filters: $filters
                        ) {
                            questions: data {
                                difficulty
                                isPaidOnly
                                title
                            }
                        }
                    }
                    """
                let variables: [String: Any] = [
                    "categorySlug": "",
                    "limit": 1,
                    "skip": Int.random(in: 0..<total),
                    "filters": ["difficulty": difficulty]
                ]
                let body: [String: Any] = ["query": query, "variables": variables]
                
                self.performRequest(body: body) { json in
                    if let dataDict = json["data"] as? [String: Any],
                       let problemList = dataDict["problemsetQuestionList"] as? [String: Any],
                       let questions = problemList["questions"] as? [[String: Any]],
                       let question = questions.first,
                       let title = question["title"] as? String,
                       let isPaidOnly = question["isPaidOnly"] as? Int {
                        if isPaidOnly == 0 {
                            completion(title)
                        } else {
                            print("Paid question, retrying...")
                            fetchQuestion()
                        }
                    }
                    else {
                        print("Something went wrong decoding the JSON.")
                        return
                    }
                }
            }
            fetchQuestion()
        }
    }
    
    func isValidUser(username: String, completion: @escaping (Bool) -> Void) {
        let query = """
            query getUserProfile($username: String!) { 
                matchedUser(username: $username) { 
                    username 
                } 
            }
            """
        let variables: [String: Any] = [
            "username": username
        ]
        let body: [String: Any] = ["query": query, "variables": variables]
        
        self.performRequest(body: body) { json in
            if let dataDict = json["data"] as? [String: Any],
               let matchedUser = dataDict["matchedUser"] as? [String: Any] {
                // If matchedUser is not nil, username is valid
                completion(true)
            } else {
                // matchedUser is nil -> username is invalid
                completion(false)
            }
        }
    }
    
    func checkLatestSubmission(username: String, alarmTime: Date, activeAlarm: Alarm?, completion: @escaping (Bool, String?) -> Void) {
        var validTime = false
        var validStatus = false
        var validTitle = false
        let query = """
            query recentAcSubmissions($username: String!) {
                recentAcSubmissionList(username: $username, limit: 1) {
                    timestamp
                    statusDisplay
                    title
                }
            }
            """
        let variables: [String: Any] = ["username": username]
        let body: [String: Any] = ["query": query, "variables": variables]
        
        self.performRequest(body: body) { json in
            if let dataDict = json["data"] as? [String: Any],
               let submissions = dataDict["recentAcSubmissionList"] as? [[String: Any]],
               let latestSubmission = submissions.first,
               let status = latestSubmission["statusDisplay"] as? String,
               let timestamp = latestSubmission["timestamp"] as? String,
               let submissionTitle = latestSubmission["title"] as? String {
                
                let submissionTime = Int(timestamp)!
                let alarmUnixTime = Int(alarmTime.timeIntervalSince1970)
                
                if submissionTime >= alarmUnixTime {
                    validTime = true
                }
                if status == "Accepted" {
                    validStatus = true
                }
                if let alarm = activeAlarm {
                    if !alarm.title.isEmpty && alarm.title == submissionTitle {
                        validTitle = true
                    }
                }
                
                let success = validTime && validStatus && validTitle
                var reason: String? = nil

                if !success {
                    var reasons: [String] = []
                    if !validTime { reasons.append("submission was too early") }
                    if !validStatus { reasons.append("submission was not accepted") }
                    if !validTitle { reasons.append("submitted the wrong problem") }
                    reason = reasons.joined(separator: ", ")
                }
                DispatchQueue.main.async {
                    completion(success, reason)
                }
                
            } else {
                print("Something went wrong decoding the JSON.")
                return
            }
        }
    }
}
