import SwiftUI

enum AudioControlState {
    case idle          // ready to start recording
    case recording     // currently recording
    case processing    // generating waveform after recording
    case readyToPlay   // ready to play audio
    case playing       // currently playing audio
    case paused        // audio is paused
}

struct AudioControl: View {
    let minRecordTime = 15
    
    @StateObject var recorder = AudioRecorderManager()
    @StateObject var player = AudioPlayerManager()
    
    @State private var isRecording = false
    @State private var audioUrl: URL?
    @State private var controlState: AudioControlState = .idle
    
    @State var recordCircleProgress: CGFloat = 0
    @State var elapsedRecordTime = 0
    @State var elapsedPlaybackTime = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var hasRecording: Bool {
        recorder.getRecordingURL() != nil
    }
    
    var formattedRecordTime: String {
        formatTime(elapsedRecordTime)
    }
    
    var formattedPlaybackTime: String {
        formatTime(elapsedPlaybackTime)
    }
    
    var onSubmit: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 4) {
                if controlState == .readyToPlay || controlState == .playing || controlState == .paused {
                    Text(formattedPlaybackTime)
                        .foregroundStyle(controlState == .playing ? .pastelPurple : .recordingTimer)
                        .font(.subheadline)
                        .onReceive(timer) { _ in
                            if controlState == .playing && elapsedPlaybackTime < elapsedRecordTime {
                                elapsedPlaybackTime += 1
                            }
                        }
                    Text("/")
                        .foregroundStyle(.recordingTimer)
                        .font(.subheadline)
                }
                Text(formattedRecordTime)
                    .foregroundStyle(.recordingTimer)
                    .font(.subheadline)
                    .onReceive(timer) { _ in
                        if isRecording {
                            elapsedRecordTime += 1
                        }
                    }
            }
            
            ZStack {
                AnimatedWaveformView(
                    audioLevels: getWaveformData(),
                    isRecording: isRecording,
                    isPlaying: controlState == .playing,
                    isPaused: controlState == .paused,
                    playbackProgress: player.playbackProgress
                )
                .opacity(player.isLoading || controlState == .processing ? 0.3 : 1.0)
                
                // Loading indicator - show during playback loading AND processing
                if player.isLoading || controlState == .processing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 25)
            .padding(.top, 15)
            
            HStack {
                Spacer()
                Button {
                    if isRecording {
                        recorder.stopRecording()
                    } else if player.isPlaying {
                        player.stop()
                    }
                    elapsedRecordTime = 0
                    elapsedPlaybackTime = 0
                    isRecording = false
                    
                    // Show immediate feedback
                    controlState = .idle
                    
                    // Delete on background
                    DispatchQueue.global(qos: .utility).async {
                        recorder.deleteRecording()
                    }
                } label: {
                    Text("Delete")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(hasRecording ? .white : .disabledDeleteSubmitBtn)
                }
                .frame(width: 60)
                .disabled(!hasRecording)
                
                Button {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation {
                        handleControlButtonPress()
                    }
                }label: {
                    ZStack(alignment: .center) {
                        Group {
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: isRecording ? 2 : 1))
                                .foregroundStyle(isRecording ? .recordBtnStrokeActive : .recordBtnStrokeInactive)
                            
                            
                            Circle()
                                .trim(from: 0, to: recordCircleProgress)
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: doesOverMinRecordTime() ? [.recordBtnStrokeInactive] : [.recordAng3, .recordAng2, .recordAng1]),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .shadow(color: Color.white, radius: 20, x: 0, y: 0)
                                .onChange(of: isRecording) { oldValue, newValue in
                                    if newValue == true {
                                        withAnimation(.linear(duration: 14)) {
                                            recordCircleProgress = 1
                                        }
                                    } else {
                                        withAnimation {
                                            recordCircleProgress = 0
                                        }
                                    }
                                }
                        }
                        
                        Group {
                            switch controlState {
                            case .idle:
                                Circle()
                                    .padding(4)
                                    .foregroundStyle(.recordActionBtn)
                            case .recording:
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(doesOverMinRecordTime() ? Color.recordActionBtn: Color.gray)
                                    .frame(width: 18)
                            case .processing:
                                // Show a different icon or keep the stop icon disabled
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 18)
                            case .readyToPlay:
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.recordActionBtn)
                                    .frame(width: 18)
                                    .padding(.leading, 4)
                            case .playing:
                                Image(systemName: "pause.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.recordActionBtn)
                                    .frame(width: 16)
                            case .paused:
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.recordActionBtn)
                                    .frame(width: 18)
                                    .padding(.leading, 4)
                            }
                        }
                    }
                }
                .frame(width: 49)
                .padding(.horizontal, 30)
                .disabled(controlState == .processing) // Disable button during processing
                
                
                Button{
                    onSubmit()
                }label: {
                    Text("Submit")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(hasRecording && doesOverMinRecordTime() && !isRecording && controlState != .processing ? .white : .disabledDeleteSubmitBtn)
                }
                .disabled(hasRecording && doesOverMinRecordTime() && !isRecording && controlState != .processing ? false : true)
                .frame(width: 60)
                
                Spacer()
            }
            
            Text("Unmatch")
                .foregroundStyle(.unmatchBtn)
                .font(.subheadline)
                .padding(.top, 15)
                .padding(.bottom, 7)
        }
        .onAppear() {
            player.onFinished = {
                controlState = .readyToPlay
                elapsedPlaybackTime = 0
            }
        }
        .onChange(of: recorder.playbackWaveformData) { oldValue, newValue in
            if controlState == .processing && !newValue.isEmpty {
                controlState = .readyToPlay
                player.setWaveformData(newValue)
            }
        }

    }
    
    private func getWaveformData() -> [Float] {
        switch controlState {
        case .idle:
            return []
        case .recording:
            return recorder.audioLevels
        case .processing:
            return !recorder.playbackWaveformData.isEmpty ? recorder.playbackWaveformData : recorder.audioLevels
        case .readyToPlay, .playing, .paused:
            // Use recorder's playback data if available, otherwise use player's data
            return !recorder.playbackWaveformData.isEmpty ? recorder.playbackWaveformData : player.waveformData
        }
    }
    
    func doesOverMinRecordTime() -> Bool {
        withAnimation {
            return elapsedRecordTime >= minRecordTime
        }
    }
    
    func formatTime(_ time: Int) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func handleControlButtonPress() {
        switch controlState {
        case .idle:
            recorder.startRecording()
            controlState = .recording
            isRecording = true
            
        case .recording:
            if doesOverMinRecordTime() {
                recorder.stopRecording()
                controlState = .processing
                isRecording = false
            }

            
        case .processing:
            // Do nothing - button is disabled during processing
            break
            
        case .readyToPlay:
            elapsedPlaybackTime = 0
            if let url = recorder.getRecordingURL() {
                player.play(url: url)
                controlState = .playing
            }
            
        case .playing:
            controlState = .paused
            player.togglePlayback()
            
        case .paused:
            player.togglePlayback()
            controlState = .playing
        }
    }
}
