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
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.levelTimer?.invalidate()
            print("Recording error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
