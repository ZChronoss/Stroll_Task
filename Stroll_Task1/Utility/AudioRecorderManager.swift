import AVFoundation
import Combine

class AudioRecorderManager: ObservableObject {
    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private(set) var recordedURL: URL?
    
    @Published var audioLevels: [Float] = []
    
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
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        timer?.invalidate()
    }
    
    func deleteRecording() {
        guard let url = recordedURL else { return }

        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                recordedURL = nil
                audioLevels = []
            }
        } catch {
            print("Failed to delete recording: \(error)")
        }
    }


    func getRecordingURL() -> URL? {
        return recordedURL
    }
}
