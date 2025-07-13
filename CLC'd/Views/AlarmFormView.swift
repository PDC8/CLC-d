//
//  AlarmFormView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import SwiftUI

struct AlarmFormView: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTime = Date()
    @State private var selectedProblemType = ProblemType.daily
    @State private var label = ""
    @State private var repeatDays: Set<Days> = []
    let weekdays: Set<Days> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    let weekends: Set<Days> = [.saturday, .sunday]
    let everyday: Set<Days> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    var existingAlarm: Binding<Alarm>? //To edit alarm
    
    init(existingAlarm: Binding<Alarm>? = nil) {
        self.existingAlarm = existingAlarm
        if let alarm = existingAlarm?.wrappedValue {
            var components = DateComponents()
            components.hour = alarm.hour
            components.minute = alarm.minute
            let calendar = Calendar.current
            _selectedTime = State(initialValue: calendar.date(from: components) ?? Date())
            _selectedProblemType = State(initialValue: alarm.problemType)
            _label = State(initialValue: alarm.label)
            _repeatDays = State(initialValue: alarm.repeatDays)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                Form {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Picker("Problem Type", selection: $selectedProblemType) {
                        ForEach(ProblemType.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.orange)
                    TextField("Label", text: $label)
                    
                    NavigationLink(destination: RepeatDaysView(repeatDays: $repeatDays)) {
                        HStack {
                            Text("Repeat")

                            Spacer()
                            Text(repeatDays.description)

                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .environment(\.colorScheme, .dark)
            
            .navigationTitle(existingAlarm != nil ? "Edit Alarm" : "Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
                        let hour = components.hour ?? 0
                        let minute = components.minute ?? 0
                        if let alarm = existingAlarm {
                            alarm.wrappedValue.hour = hour
                            alarm.wrappedValue.minute = minute
                            alarm.wrappedValue.label = label
                            alarm.wrappedValue.problemType = selectedProblemType
                            alarm.wrappedValue.repeatDays = repeatDays
                        } else {
                            viewModel.addAlarm(hour: hour, minute: minute, label: label, problemType: selectedProblemType, repeatDays: repeatDays)
                        }
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}
