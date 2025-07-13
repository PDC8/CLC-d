//
//  ProfileView.swift
//  CLC'd
//
//  Created by Peidong Chen on 6/1/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var newUsername: String = ""
    @State private var borderColor: Color = .gray
    @State private var shake: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter your username", text: $newUsername)
                .autocapitalization(.none)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                )
                .offset(x: shake)
                .animation(.default, value: borderColor)
                .animation(.default, value: shake)
            
            Button("Enter") {
                LeetCodeAPI.shared.isValidUser(username: newUsername) { valid in
                    DispatchQueue.main.async {
                        if valid {
                            userViewModel.username = newUsername
                            newUsername = ""
                            borderColor = .gray
                        } else {
                            borderColor = .red
                            shakeAnimation()
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            
            Text("Current username: \(userViewModel.username)")
        }
        .environment(\.colorScheme, .dark)
        .padding()
    }
    

    private func shakeAnimation() {
        let shakeDistance: CGFloat = 10
        let shakeTimes = 3
        let shakeDuration = 0.05
        
        for i in 0..<(shakeTimes * 2) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * shakeDuration) {
                withAnimation {
                    shake = (i % 2 == 0 ? -shakeDistance : shakeDistance)
                }
            }
        }
        
        // Reset after shaking
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(shakeTimes * 2) * shakeDuration) {
            withAnimation {
                shake = 0
                borderColor = .gray
            }
        }
    }
}

