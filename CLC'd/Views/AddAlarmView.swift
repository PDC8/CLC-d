//
//  AddAlarmView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import SwiftUI

struct AddAlarmView: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @Environment(\.dismiss) var dismiss
    
//    enum ProblemType: String, CaseIterable, Identifiable {
//        case daily = "Daily"
//        case easy = "Easy"
//        case medium = "Medium"
//        case hard = "Hard"
//        case random = "Random"
//        
//        var id: String { self.rawValue }
//    }
    @State private var selectedTime = Date()
    @State private var selectedProblemType = ProblemType.daily
    @State private var label = ""

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Alarm Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                Picker("Problem Type", selection: $selectedProblemType) {
                    ForEach(ProblemType.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }.pickerStyle(.menu)
                TextField("Label", text: $label)
            }
            .navigationTitle("Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addAlarm(time: selectedTime, label: label, problemType: selectedProblemType)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
