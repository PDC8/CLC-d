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
    @Published var title: String
    @Published var isOn: Bool
    @Published var isTriggered: Bool
    
    init(hour: Int, minute: Int, label: String, problemType: ProblemType, isOn: Bool = true,
         isTriggered: Bool = false, title: String = "") {
        self.hour = hour
        self.minute = minute
        self.label = label
        self.isOn = isOn
        self.isTriggered = isTriggered
        self.problemType = problemType
        self.title = title
    }
}

