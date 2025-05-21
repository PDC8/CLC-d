//
//  AlarmListView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @State private var showingAddAlarm = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.alarms) { alarm in
                    AlarmRow(alarm: alarm)
                }
                .onDelete(perform: viewModel.removeAlarm)
            }
            .navigationTitle("Alarms")
            .toolbar {
                Button(action: {
                    showingAddAlarm = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView()
            }
            
            .sheet(
                item: Binding<Alarm?>(
                    get: {
                        guard let alarm = viewModel.activeAlarm,
                              !alarm.title.isEmpty else { return nil }
                        return alarm
                    },
                    set: { newValue in
                        if newValue == nil {
                            viewModel.activeAlarm?.isTriggered = false
                            viewModel.activeAlarm?.isOn = false
                            viewModel.activeAlarm = nil
                        }
                    }
                )
            ) { alarm in
                AlarmRingingView()
            }
        }
    }
}

struct AlarmRow: View {
    @ObservedObject var alarm: Alarm
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(alarm.time.formatted(date: .omitted, time: .shortened))
                Text(alarm.problemType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $alarm.isOn)
                .labelsHidden()
        }
    }
}
