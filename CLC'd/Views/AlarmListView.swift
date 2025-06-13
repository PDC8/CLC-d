//
//  AlarmListView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/15/25.
//

import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showingAddAlarm = false
    @State private var showingProfile = false
//    @State private var setProfile = false
    private var setProfile: Bool {
        userViewModel.username.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.alarms) { alarm in
                    AlarmRow(alarm: alarm)
                }
                .onDelete(perform: viewModel.removeAlarm)
            }
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAlarm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $showingProfile) {
                ProfileView()
            }
            
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView()
            }
            
            .fullScreenCover(isPresented: .constant(setProfile)) {
                ProfileView()
            }
//            .onAppear {
//                if userViewModel.username.isEmpty {
//                    setProfile = true
//                }
//            }
            
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
                Text(formattedTime(hour: alarm.hour, minute: alarm.minute))
                .font(.headline)
                Text(alarm.problemType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                    .foregroundColor(.gray)
                Text(alarm.repeatDays.isEmpty ? "Never" : alarm.repeatDays.description)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: $alarm.isOn)
                .labelsHidden()
        }
    }
    private func formattedTime(hour: Int, minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let calendar = Calendar.current
        let date = calendar.date(from: components) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }
}
