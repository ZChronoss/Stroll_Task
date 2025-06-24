import SwiftUI

enum AudioControlState {
    case idle          // ready to start recording
    case recording     // currently recording
    case readyToPlay   // ready to play audio
    case playing       // currently playing audio
    case paused        // audio is paused
}

struct AudioControl: View {
    let minRecordTime = 15
    
    @StateObject var recorder = AudioRecorderManager()
    @StateObject var player = AudioPlayerManager()
    
    @State private var isRecording = false
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
            HStack(alignment: .center) {
                if controlState == .readyToPlay || controlState == .playing || controlState == .paused {
                    Group {
                        Text(formattedPlaybackTime)
                            .foregroundStyle(controlState == .playing ? .pastelPurple : .recordingTimer)
                            .font(.footnote)
                            .onReceive(timer) { _ in
                                if controlState == .playing && elapsedPlaybackTime < elapsedRecordTime {
                                    elapsedPlaybackTime += 1
                                }
                            }
                        Text("/")
                            .foregroundStyle(.recordingTimer)
                            .font(.footnote)
                    }
                }
                Text(formattedRecordTime)
                    .foregroundStyle(.recordingTimer)
                    .font(.footnote)
                    .onReceive(timer) { _ in
                        if isRecording {
                            elapsedRecordTime += 1
                        }
                    }
            }
            
            ZStack {
                AnimatedWaveformView(
                    audioLevels: controlState == .readyToPlay || controlState == .playing || controlState == .paused ?
                    player.waveformData : recorder.audioLevels,
                    isRecording: isRecording,
                    isPlaying: controlState == .playing,
                    isPaused: controlState == .paused,
                    playbackProgress: player.playbackProgress
                )
                .opacity(player.isLoading ? 0.3 : 1.0)
                
                // Loading indicator
                if player.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            
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
                                        gradient: Gradient(colors: [.recordAng3, .recordAng2, .recordAng1]),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .shadow(color: Color.white, radius: 20, x: 0, y: 0)
                                .onChange(of: isRecording) { oldValue, newValue in
                                    if newValue == true {
                                        withAnimation(.linear(duration: 15)) {
                                            recordCircleProgress = 1
                                        }
                                    } else {
                                        withAnimation {
                                            recordCircleProgress = 0
                                        }
                                    }
                                }
                                .overlay {
                                    Group {
                                        if elapsedRecordTime > minRecordTime {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                Circle()
                                                    .stroke(style: StrokeStyle(lineWidth: isRecording ? 2 : 1))
                                                    .foregroundStyle(.recordBtnStrokeInactive)
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                        }
                                    }
                                }
                        }
                        
                        Group {
                            switch controlState {
                            case .idle:
                                Circle()
                                    .padding(3)
                                    .foregroundStyle(.recordActionBtn)
                            case .recording:
                                Image(systemName: "stop.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(elapsedRecordTime > minRecordTime ? Color.recordActionBtn: Color.gray)
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
                .frame(width: 45)
                .padding(.horizontal, 30)
                
                
                Button{
                    onSubmit()
                }label: {
                    Text("Submit")
                        .font(.system(.headline, weight: .regular))
                        .foregroundStyle(hasRecording && elapsedRecordTime > minRecordTime && !isRecording ? .white : .disabledDeleteSubmitBtn)
                }
                .frame(width: 60)
                
                Spacer()
            }
            
            Text("Unmatch")
                .foregroundStyle(.unmatchBtn)
                .font(.caption)
                .padding(.top)
        }
        .onAppear() {
            player.onFinished = {
                controlState = .readyToPlay
                elapsedPlaybackTime = 0
            }
        }
        .ignoresSafeArea(edges: .bottom)
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
            if elapsedRecordTime >= 15 {
                recorder.stopRecording()
                controlState = .readyToPlay
                isRecording = false
            }
            
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
