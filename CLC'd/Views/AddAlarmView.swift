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
    
    @State private var selectedTime = Date()
    @State private var selectedProblemType = ProblemType.daily
    @State private var label = ""
    @State private var repeatDays: Set<Days> = []
    let weekdays: Set<Days> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    let weekends: Set<Days> = [.saturday, .sunday]
    let everyday: Set<Days> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

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
                
                NavigationLink(destination: RepeatDaysView(repeatDays: $repeatDays)) {
                    HStack {
                        Text("Repeat")
                        Spacer()
                        Text(repeatDays.description)
                            .foregroundColor(.gray)

                    }
                }
            }
            
            .navigationTitle("Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
                        let hour = components.hour ?? 0
                        let minute = components.minute ?? 0
                        print(hour, minute)
                        viewModel.addAlarm(hour: hour, minute: minute, label: label, problemType: selectedProblemType, repeatDays: repeatDays)
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
