import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let audioQueue = DispatchQueue(label: "audio.recording", qos: .userInitiated)
    
    @Published var audioLevels: [Float] = []
    @Published var isRecording: Bool = false
    
    private var levelTimer: Timer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        audioQueue.async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to setup audio session: \(error)")
            }
        }
    }
    
    func startRecording() {
        audioQueue.async {
            do {
                // Create recording URL
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
                
                // Recording settings optimized for performance
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 22050, // Lower sample rate for better performance
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                ]
                
                let recorder = try AVAudioRecorder(url: audioURL, settings: settings)
                recorder.delegate = self
                recorder.isMeteringEnabled = true
                recorder.prepareToRecord()
                
                DispatchQueue.main.async {
                    self.audioRecorder = recorder
                    self.recordingURL = audioURL
                    self.audioLevels = [] // Clear previous levels
                    
                    recorder.record()
                    self.isRecording = true
                    self.startLevelMonitoring()
                }
                
            } catch {
                DispatchQueue.main.async {
                    print("Recording failed: \(error)")
                }
            }
        }
    }
    
    func stopRecording() {
        levelTimer?.invalidate()
        audioRecorder?.stop()
        isRecording = false
    }
    
    func deleteRecording() {
        stopRecording()
        
        // Delete file on background queue
        audioQueue.async {
            if let url = self.recordingURL {
                try? FileManager.default.removeItem(at: url)
            }
            
            DispatchQueue.main.async {
                self.recordingURL = nil
                self.audioLevels = []
            }
        }
    }
    
    func getRecordingURL() -> URL? {
        return recordingURL
    }
    
    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let recorder = self.audioRecorder, recorder.isRecording else { return }
            
            recorder.updateMeters()
            let level = recorder.averagePower(forChannel: 0)
            
            // Convert decibel to linear scale (0.0 to 1.0)
            let normalizedLevel = self.normalizeAudioLevel(level)
            
            // Update on main thread but limit array size for performance
            DispatchQueue.main.async {
                self.audioLevels.append(normalizedLevel)
                
                // Keep only recent levels to prevent memory issues
                if self.audioLevels.count > 1000 {
                    self.audioLevels.removeFirst(self.audioLevels.count - 1000)
                }
            }
        }
    }
    
    private func normalizeAudioLevel(_ decibels: Float) -> Float {
        // Convert decibels (-160 to 0) to normalized scale (0.0 to 1.0)
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        
        let clampedDb = max(minDb, min(maxDb, decibels))
        let normalizedLevel = (clampedDb - minDb) / (maxDb - minDb)
        
        return normalizedLevel
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.levelTimer?.invalidate()
            
            // Generate waveform data immediately after recording finishes
            if flag, let url = self.recordingURL {
                self.generateWaveformForPlayback(from: url)
            }
        }
    }
    
    // Add this new method to generate waveform data for playback
    private func generateWaveformForPlayback(from url: URL) {
        audioQueue.async {
            do {
                let audioFile = try AVAudioFile(forReading: url)
                let format = audioFile.processingFormat
                let frameCount = UInt32(audioFile.length)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    return
                }
                
                try audioFile.read(into: buffer)
                
                // Process audio data same as player
                let samples = self.extractSamplesForPlayback(from: buffer)
                let processedSamples = self.normalizeAndEnhanceAudioSamples(samples)
                let downsampledData = self.downsampleAudio(samples: processedSamples, targetSampleCount: 300)
                
                DispatchQueue.main.async {
                    // Store the waveform data that can be accessed by the player
                    self.playbackWaveformData = downsampledData
                }
                
            } catch {
                print("Failed to generate playback waveform data: \(error)")
            }
        }
    }
    
    @Published var playbackWaveformData: [Float] = []
    
    private func extractSamplesForPlayback(from buffer: AVAudioPCMBuffer) -> [Float] {
        guard let floatChannelData = buffer.floatChannelData else { return [] }
        let channelData = floatChannelData[0]
        let frameLength = Int(buffer.frameLength)
        
        var samples: [Float] = []
        samples.reserveCapacity(frameLength)
        
        for i in 0..<frameLength {
            samples.append(abs(channelData[i]))
        }
        
        return samples
    }
    
    private func normalizeAndEnhanceAudioSamples(_ samples: [Float]) -> [Float] {
        guard !samples.isEmpty else { return samples }
        
        let maxValue = samples.max() ?? 1.0
        guard maxValue > 0 else { return samples }
        
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
        downsampledData.reserveCapacity(targetSampleCount)
        
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
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.levelTimer?.invalidate()
            print("Recording error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
