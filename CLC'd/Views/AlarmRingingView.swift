//
//  AlarmRingingView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/16/25.
//
import SwiftUI

struct AlarmRingingView: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
//            if let title = viewModel.activeAlarm?.title {
//                Text("Solve: \(title)")
//                    .font(.headline)
//                    .padding()
//            }
            if let title = viewModel.activeAlarm?.title {
                let formattedTitle = title.replacingOccurrences(of: " ", with: "-").lowercased()
                let urlString = "https://leetcode.com/problems/\(formattedTitle)/"
                if let url = URL(string: urlString) {
                    Link("Solve: \(title)", destination: url)
                        .font(.headline)
                        .padding()
                }
            }
            Text("🔔 Alarm! Solve to dismiss").font(.title)
            Button("Submit") {
                checkSubmission()
            }
            .buttonStyle(.borderedProminent)
            
            if let message = viewModel.failureMessage {
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .interactiveDismissDisabled()
        .padding()
    }
    
    private func checkSubmission() {
        guard let alarm = viewModel.activeAlarm else { return }
        
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = alarm.hour
        components.minute = alarm.minute
        
        if let alarmTime = calendar.date(from: components) {
            viewModel.checkLatestSubmission(username: userViewModel.username, alarmTime: alarmTime) { [weak viewModel] success in
                if success {
                    AudioManager.shared.stopSound()
                    if let currAlarm = viewModel?.activeAlarm, currAlarm.repeatDays.isEmpty {
                        currAlarm.isOn = false
                    }
                    viewModel?.activeAlarm = nil
                    dismiss()
                } else {
                    print("Not valid")
                }
            }
        } else {
            print("Failed to construct alarm time.")
        }
    }

}


#Preview {
    AlarmRingingView()
}
