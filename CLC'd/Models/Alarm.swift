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
    var problemType: String
    @Published var isOn: Bool
    @Published var isTriggered: Bool
    
    init(time: Date, label: String, problemType: String, isOn: Bool = true, isTriggered: Bool = false) {
        self.time = time
        self.label = label
        self.isOn = isOn
        self.isTriggered = isTriggered
        self.problemType = problemType
    }
}

