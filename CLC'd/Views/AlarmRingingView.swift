//
//  AlarmRingingView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/16/25.
//
import SwiftUI

struct AlarmRingingView: View {
    @EnvironmentObject var viewModel: AlarmViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if let title = viewModel.activeAlarm?.title {
                Text("Solve: \(title)")
                    .font(.headline)
                    .padding()
            }
            Text("🔔 Alarm! Solve to dismiss").font(.title)
            Button("Submit") {
                checkSubmission()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .interactiveDismissDisabled()
    }
    
    private func checkSubmission() {
        guard let alarm = viewModel.activeAlarm else { return }
        
        viewModel.checkLatestSubmission(username: "peidongchen2004", alarmTime: alarm.time){ [weak viewModel] success in
            if success {
                AudioManager.shared.stopSound()
                viewModel?.activeAlarm = nil
                dismiss()
            } else {
                print("Not valid")
            }
        }
    }

}


#Preview {
    AlarmRingingView()
}
