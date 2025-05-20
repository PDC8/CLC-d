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
            
            .sheet(item: $viewModel.activeAlarm) { alarm in
                AlarmRingingView()
//                .onDisappear {
//                    alarm.isTriggered = false
//                    viewModel.activeAlarm = nil
//                    alarm.isOn = false
//                }
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
                Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $alarm.isOn)
                .labelsHidden()
        }
    }
}
