import SwiftUI

enum AudioControlState {
    case idle          // ready to start recording
    case recording     // currently recording
    case readyToPlay   // ready to play audio
    case playing       // currently playing audio
    case paused        // audio is paused
}

struct AudioControl: View {
    @StateObject var recorder = AudioRecorderManager()
    @StateObject var player = AudioPlayerManager()
    
    @State private var isRecording = false
    @State private var audioUrl: URL?
    @State private var controlState: AudioControlState = .idle
    
    @State var recordCircleProgress: CGFloat = 0
    @State var elapsedTime = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            Text(formattedTime)
                .bold()
                .foregroundStyle(.recordingTimer)
                .font(.subheadline)
                .onReceive(timer) { _ in
                    if isRecording {
                        elapsedTime += 1
                    }
                }
            
            // AUDIO VISUALIZER
            Rectangle()
                .foregroundStyle(.recordingVisualizer)
                .frame(height: 2)
            
            HStack {
                Spacer()
                Button {
                    elapsedTime = 0
                    isRecording = false
                    recorder.deleteRecording()
                    controlState = .idle
                }label: {
                    Text("Delete")
                }
                .disabled(recorder.getRecordingURL() == nil ? true : false)
                
                Spacer()
                
                Button {
                    switch controlState {
                    case .idle:
                        recorder.startRecording()
                        controlState = .recording
                        isRecording = true
                        
                    case .recording:
                        if elapsedTime >= 15 {
                            recorder.stopRecording()
                            controlState = .readyToPlay
                            isRecording = false
                        }
                        
                    case .readyToPlay:
                        if let url = recorder.getRecordingURL() {
                            player.play(url: url)
                            controlState = .playing
                        }
                        
                    case .playing:
                        player.stop()
                        controlState = .paused
                        
                    case .paused:
                        if let url = recorder.getRecordingURL() {
                            player.play(url: url)
                            controlState = .playing
                        }
                    }
                }label: {
                    ZStack(alignment: .center) {
                        Group {
                            Circle()
                                .stroke(style: StrokeStyle(lineWidth: 2))
                                .foregroundStyle(.white)
                            Circle()
                                .trim(from: 0, to: recordCircleProgress)
                                .stroke(style: StrokeStyle(lineWidth: 2))
                                .rotationEffect(.degrees(-90))
                                .foregroundStyle(.black)
                                .onChange(of: isRecording, { oldValue, newValue in
                                    if newValue == true {
                                        // Fills the circle in 15 seconds
                                        withAnimation(.linear(duration: 15)) {
                                            recordCircleProgress = 1
                                        }
                                    }else {
                                        recordCircleProgress = 0
                                    }
                                })
                        }
                        
                        Group {
                            switch controlState {
                            case .idle:
                                Circle()
                                    .padding(3)
                            case .recording:
                                Image(systemName: "stop.fill")
                                    .foregroundStyle(elapsedTime >= 15 ? Color.red: Color.gray)
                            case .readyToPlay:
                                Image(systemName: "play.fill")
                            case .playing:
                                Image(systemName: "pause.fill")
                            case .paused:
                                Image(systemName: "play.fill")
                            }
                        }
                    }
                }
                .frame(width: 40)
                
                Spacer()
                
                Text("Submit")
                    .font(.system(.headline, weight: .regular))
//                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .onAppear() {
            player.onFinished = {
                controlState = .readyToPlay
            }
        }
    }
}

#Preview {
    AudioControl()
}
