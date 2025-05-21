//
//  Alarm.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import Foundation

class Alarm: ObservableObject, Identifiable {
    let id = UUID()
    var time: Date
    var label: String
    var problemType: ProblemType
    @Published var title: String
    @Published var isOn: Bool
    @Published var isTriggered: Bool
    
    init(time: Date, label: String, problemType: ProblemType, isOn: Bool = true,
         isTriggered: Bool = false, title: String = "") {
        self.time = time
        self.label = label
        self.isOn = isOn
        self.isTriggered = isTriggered
        self.problemType = problemType
        self.title = title
    }
}

