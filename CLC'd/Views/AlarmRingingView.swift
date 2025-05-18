//
//  AlarmRingingView.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/16/25.
//
import SwiftUI

struct AlarmRingingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Alarm header
            Text("🔔 Alarm! Solve to dismiss").font(.title)
            
            // Submit button
            Button("Submit") {
                // Check if answer matches "esrever" (reverse backwards)
//                if solution.lowercased() == "esrever" {
//                    AudioManager.shared.stopSound() // Stop alarm
//                    dismiss() // Close view
//                }
                AudioManager.shared.stopSound() // Stop alarm
                
                dismiss() // Close view
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

#Preview {
    AlarmRingingView()
}
