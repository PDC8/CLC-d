//
//  Alarm.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import Foundation

class Alarm: ObservableObject, Identifiable {
    let id = UUID()
    var hour: Int
    var minute: Int
    var label: String
    var problemType: ProblemType
    var repeatString: String
    @Published var title: String
    @Published var isOn: Bool
    @Published var isTriggered: Bool
    @Published var repeatDays: Set<Days> = []
    
    init(hour: Int, minute: Int, label: String, problemType: ProblemType,
         isOn: Bool = true, isTriggered: Bool = false, title: String = "", repeatDays: Set<Days>) {
        self.hour = hour
        self.minute = minute
        self.label = label
        self.isOn = isOn
        self.isTriggered = isTriggered
        self.problemType = problemType
        self.title = title
        self.repeatDays = repeatDays
        self.repeatString = ""
    }
}
