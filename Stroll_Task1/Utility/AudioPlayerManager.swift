import AVFoundation

class AudioPlayerManager: ObservableObject {
    private var player: AVAudioPlayer?
    private var timer: Timer?

    @Published var playbackProgress: Double = 0 // 0.0 to 1.0

    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
//            startTimer()
        } catch {
            print("Playback failed: \(error)")
        }
    }

    func stop() {
        player?.stop()
        timer?.invalidate()
        playbackProgress = 0
    }
}
