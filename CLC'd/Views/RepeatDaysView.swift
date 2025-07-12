//
//  RepeatDaysView.swift
//  CLC'd
//
//  Created by Peidong Chen on 6/6/25.
//

import SwiftUI

struct RepeatDaysView: View {
    @Binding var repeatDays: Set<Days>
    
    var body: some View {
        List {
            ForEach(Days.allCases, id: \.self) { day in
                MultipleSelectionRow(day: day, isSelected: repeatDays.contains(day)) {
                    if repeatDays.contains(day) {
                        repeatDays.remove(day)
                    } else {
                        repeatDays.insert(day)
                    }
                }
            }
        }
        .navigationTitle("Repeat")
        .environment(\.colorScheme, .dark)
        .tint(.orange)
    }
}

struct MultipleSelectionRow: View {
    let day: Days
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(day.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
        }
    }
}
