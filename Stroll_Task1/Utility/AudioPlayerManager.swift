import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var timer: Timer?

    @Published var playbackProgress: Double = 0 // 0.0 to 1.0
    @Published var waveformData: [Float] = []
    @Published var isPlaying: Bool = false
    
    var onFinished: (() -> Void)?

    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            
            // Generate waveform data from the audio file
            generateWaveformData(from: url)
            
            player?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("Playback failed: \(error)")
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
    
    private func generateWaveformData(from url: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat
            let frameCount = UInt32(audioFile.length)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                return
            }
            
            try audioFile.read(into: buffer)
            
            // Convert audio buffer to waveform data
            let samples = extractSamples(from: buffer)
            let processedSamples = normalizeAndEnhanceAudioSamples(samples)
            let downsampledData = downsampleAudio(samples: processedSamples, targetSampleCount: 300)
            
            DispatchQueue.main.async {
                self.waveformData = downsampledData
            }
            
        } catch {
            print("Failed to generate waveform data: \(error)")
        }
    }
    
    private func extractSamples(from buffer: AVAudioPCMBuffer) -> [Float] {
        guard let floatChannelData = buffer.floatChannelData else { return [] }
        let channelData = floatChannelData[0]
        let frameLength = Int(buffer.frameLength)
        
        var samples: [Float] = []
        for i in 0..<frameLength {
            // Use absolute value to get amplitude
            samples.append(abs(channelData[i]))
        }
        
        return samples
    }
    
    private func normalizeAndEnhanceAudioSamples(_ samples: [Float]) -> [Float] {
        guard !samples.isEmpty else { return samples }
        
        // Find the maximum value for normalization
        let maxValue = samples.max() ?? 1.0
        
        // Avoid division by zero
        guard maxValue > 0 else { return samples }
        
        // Normalize and apply processing similar to recording
        return samples.map { sample in
            let normalized = sample / maxValue
            
            // Apply the same processing as in AnimatedWaveformView
            let processedLevel = max(0.05, normalized) // Minimum height for visibility
            let scaledLevel = pow(processedLevel, 0.6) // Power curve to make quiet sounds more visible
            
            return min(1.0, scaledLevel)
        }
    }
    
    private func downsampleAudio(samples: [Float], targetSampleCount: Int) -> [Float] {
        guard samples.count > targetSampleCount else { return samples }
        
        let blockSize = samples.count / targetSampleCount
        var downsampledData: [Float] = []
        
        for i in 0..<targetSampleCount {
            let startIndex = i * blockSize
            let endIndex = min(startIndex + blockSize, samples.count)
            
            // Get the block of samples
            let blockSamples = Array(samples[startIndex..<endIndex])
            
            // Use peak detection instead of just RMS for better visual representation
            let peak = blockSamples.max() ?? 0.0
            let rms = sqrt(blockSamples.map { $0 * $0 }.reduce(0, +) / Float(blockSamples.count))
            
            // Combine peak and RMS for better waveform visualization
            // This gives more dynamic range while maintaining the overall energy representation
            let combinedValue = (peak * 0.7) + (rms * 0.3)
            
            downsampledData.append(combinedValue)
        }
        
        return downsampledData
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        isPlaying = false
        playbackProgress = 0
        onFinished?()
    }
}
