//
//  AudioManager.swift
//  KitchenKing-V2
//
//  Created by 刘琛 on 2025/8/3.
//

import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    private var backgroundMusicURL: URL?
    
    @Published var isPlaying = false
    @Published var isMuted = false
    
    private init() {
        setupAudioSession()
        loadBackgroundMusic()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音频会话设置失败: \(error)")
        }
    }
    
    private func loadBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "背景声_[cut_6sec]", withExtension: "mp3") else {
            print("背景音乐文件不存在于bundle中")
            return
        }
        
        backgroundMusicURL = url
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 循环播放
            audioPlayer?.volume = 0.3 // 音量设置为30%
            print("背景音乐加载成功")
        } catch {
            print("背景音乐加载失败: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        guard !isMuted else { return }
        
        if let player = audioPlayer {
            if !player.isPlaying {
                player.play()
                isPlaying = true
                print("背景音乐开始播放")
            }
        }
    }
    
    func stopBackgroundMusic() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
                isPlaying = false
                print("背景音乐停止播放")
            }
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            stopBackgroundMusic()
        } else {
            playBackgroundMusic()
        }
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = max(0, min(1, volume))
    }
}