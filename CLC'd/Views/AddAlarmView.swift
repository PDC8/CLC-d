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
    @State private var label = ""

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Alarm Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                TextField("Label", text: $label)
            }
            .navigationTitle("Add Alarm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addAlarm(time: selectedTime, label: label)
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
