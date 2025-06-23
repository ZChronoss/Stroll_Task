import AVFoundation
import Combine

class AudioRecorderManager: ObservableObject {
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    
    @Published private(set) var recordedURL: URL?
    @Published var audioLevels: [Float] = []
    @Published var isRecording = false
    
    let session = AVAudioSession.sharedInstance()
    
    func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        self.recordedURL = url
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            
            // Clear previous recording data and start fresh
            audioLevels = []
            isRecording = true
            
            // Timer to capture audio levels every 50ms for good responsiveness
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                self.recorder?.updateMeters()
                let power = self.recorder?.averagePower(forChannel: 0) ?? -160
                
                // Better normalization: -60dB to 0dB range (more responsive to voice)
                let normalizedPower = max(-60.0, power) // Clamp minimum to -60dB
                let normalized = (normalizedPower + 60.0) / 60.0 // Convert to 0-1 range
                let smoothed = max(0.0, min(1.0, normalized))
                
                DispatchQueue.main.async {
                    // Accumulate all audio levels (don't remove old ones)
                    self.audioLevels.append(smoothed)
                }
            }
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        
        do {
            try session.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    func deleteRecording() {
        guard let url = recordedURL else { return }

        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                recordedURL = nil
                audioLevels = []
                isRecording = false
            }
        } catch {
            print("Failed to delete recording: \(error)")
        }
    }

    func getRecordingURL() -> URL? {
        return recordedURL
    }
    
    // Get the current recording duration in seconds
    var recordingDuration: TimeInterval {
        return TimeInterval(audioLevels.count) * 0.05 // 50ms per sample
    }
}
