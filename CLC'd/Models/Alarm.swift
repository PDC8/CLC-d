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
    @Published var isOn: Bool
    
    init(time: Date, label: String, isOn: Bool = true) {
        self.time = time
        self.label = label
        self.isOn = isOn
    }
}

