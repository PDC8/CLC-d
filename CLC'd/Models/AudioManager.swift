//
//  AudioManager.swift
//  CLC'd
//
//  Created by Peidong Chen on 5/16/25.
//

import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    var player: AVAudioPlayer?
    
    func playSound() {
        let url = Bundle.main.url(forResource: "alarm_sound", withExtension: "mp3")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            guard let url = url else {
                print("Can't find sound file")
                return
            }
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Audio session setup failed: \(error)")
        }
        
    }
    
    func stopSound() {
        player?.stop()
    }
}
