import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var timer: Timer?

    @Published var playbackProgress: Double = 0 // 0.0 to 1.0
    
    var onFinished: (() -> Void)?

    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished?()
    }
}
