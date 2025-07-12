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
    @State private var editAlarm: Alarm? = nil
    private var setProfile: Bool {
        userViewModel.username.isEmpty
    }
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.alarms) { alarm in
                    AlarmRow(alarm: alarm)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editAlarm = alarm
                        }
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
                AlarmFormView()
                    .ignoresSafeArea()
            }
            
            .fullScreenCover(isPresented: .constant(setProfile)) {
                ProfileView()
            }
//            .onAppear {
//                if userViewModel.username.isEmpty {
//                    setProfile = true
//                }
//            }
            .sheet(item: $editAlarm) { alarm in
                if let index = viewModel.alarms.firstIndex(where: { $0.id == alarm.id }) {
                    AlarmFormView(existingAlarm: $viewModel.alarms[index])
                }
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
                    .presentationBackground(Color.black)
                    .environment(\.colorScheme, .dark)
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(.orange)
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
                Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                Text(alarm.repeatDays.isEmpty ? "Never" : alarm.repeatDays.description)
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
