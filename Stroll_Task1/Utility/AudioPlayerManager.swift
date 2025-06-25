import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private let audioQueue = DispatchQueue(label: "audio.processing", qos: .userInitiated)

    @Published var playbackProgress: Double = 0
    @Published var waveformData: [Float] = []
    @Published var isPlaying: Bool = false
    @Published var isLoading: Bool = false // Add loading state
    
    var onFinished: (() -> Void)?

    func play(url: URL) {
        // Set loading state immediately
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Do heavy lifting on background queue
        audioQueue.async {
            do {
                // Configure audio session on background thread
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
                
                // Create player on background thread
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay() // Preload the audio
                
                // Switch back to main thread for UI updates and playback
                DispatchQueue.main.async {
                    self.player = audioPlayer
                    self.isLoading = false
                    
                    audioPlayer.play()
                    self.isPlaying = true
                    self.startTimer()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Playback failed: \(error)")
                }
            }
        }
    }
    
    // Add method to set waveform data from recorder
    func setWaveformData(_ data: [Float]) {
        DispatchQueue.main.async {
            self.waveformData = data
        }
    }

    func stop() {
        player?.stop()
        timer?.invalidate()
        playbackProgress = 0
        isPlaying = false
    }
    
    private func pause() {
        player?.pause()
        isPlaying = false
        timer?.invalidate()
    }
    
    private func resume() {
        player?.play()
        isPlaying = true
        startTimer()
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = self.player else { return }
            
            DispatchQueue.main.async {
                self.playbackProgress = player.currentTime / player.duration
            }
        }
    }
    
    private func generateWaveformDataAsync(from url: URL, completion: @escaping ([Float]) -> Void) {
        audioQueue.async {
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let format = audioFile.processingFormat
                let frameCount = UInt32(audioFile.length)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    completion([])
                    return
                }
                
                try audioFile.read(into: buffer)
                
                // Process audio data
                let samples = self.extractSamples(from: buffer)
                let processedSamples = self.normalizeAndEnhanceAudioSamples(samples)
                let downsampledData = self.downsampleAudio(samples: processedSamples, targetSampleCount: 300)
                
                completion(downsampledData)
                
            } catch {
                print("Failed to generate waveform data: \(error)")
                completion([])
            }
        }
    }
    
    private func extractSamples(from buffer: AVAudioPCMBuffer) -> [Float] {
        guard let floatChannelData = buffer.floatChannelData else { return [] }
        let channelData = floatChannelData[0]
        let frameLength = Int(buffer.frameLength)
        
        var samples: [Float] = []
        samples.reserveCapacity(frameLength) // Pre-allocate memory
        
        for i in 0..<frameLength {
            samples.append(abs(channelData[i]))
        }
        
        return samples
    }
    
    private func normalizeAndEnhanceAudioSamples(_ samples: [Float]) -> [Float] {
        guard !samples.isEmpty else { return samples }
        
        let maxValue = samples.max() ?? 1.0
        guard maxValue > 0 else { return samples }
        
        // Use more efficient array operations
        return samples.map { sample in
            let normalized = sample / maxValue
            let processedLevel = max(0.05, normalized)
            let scaledLevel = pow(processedLevel, 0.6)
            return min(1.0, scaledLevel)
        }
    }
    
    private func downsampleAudio(samples: [Float], targetSampleCount: Int) -> [Float] {
        guard samples.count > targetSampleCount else { return samples }
        
        let blockSize = samples.count / targetSampleCount
        var downsampledData: [Float] = []
        downsampledData.reserveCapacity(targetSampleCount) // Pre-allocate memory
        
        for i in 0..<targetSampleCount {
            let startIndex = i * blockSize
            let endIndex = min(startIndex + blockSize, samples.count)
            
            let blockSamples = Array(samples[startIndex..<endIndex])
            let peak = blockSamples.max() ?? 0.0
            let rms = sqrt(blockSamples.map { $0 * $0 }.reduce(0, +) / Float(blockSamples.count))
            let combinedValue = (peak * 0.7) + (rms * 0.3)
            
            downsampledData.append(combinedValue)
        }
        
        return downsampledData
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.isPlaying = false
            self.playbackProgress = 0
            self.onFinished?()
        }
    }
}
