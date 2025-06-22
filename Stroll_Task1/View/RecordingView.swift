import SwiftUI

struct RecordingView: View {
    @Environment(\.flowDismiss) var flowDismiss
    @StateObject var recorder = AudioRecorderManager()
    @StateObject var player = AudioPlayerManager()
    
    @State private var isRecording = false
    @State private var audioUrl: URL?
    
    var user: User
    let quote: String
    let desc: String
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image(user.name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .overlay {
                        Circle()
                            .stroke(.black, lineWidth: 45)
                            .blur(radius: 20)
                            .frame(width: 690, height: 610)
                    }
                    .overlay {
                        LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                    }
                
                Rectangle()
                    .fill(Color.black)
                    .blur(radius: 20, opaque: true)
            }
            
            .ignoresSafeArea()
            
            
            VStack {
                VStack(spacing: 8) {
                    HStack {
                        RoundedRectangle(cornerRadius: 4, style: .circular)
                            .foregroundStyle(.barColor1)
                        RoundedRectangle(cornerRadius: 4, style: .circular)
                            .foregroundStyle(.barColor2)
                    }
                    .frame(height: 4)
                    
                    HStack {
                        Label("", systemImage: "chevron.left")
                            .font(.callout)
                            .bold()
                            .onTapGesture {
                                flowDismiss()
                            }
                        
                        Spacer()
                        
                        Text("\(user.name), \(user.age)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Label("", systemImage: "ellipsis")
                            .font(.callout)
                            .bold()
                    }
                    .foregroundStyle(.white)
                }
                
                Spacer()
                
                let circleSize = CGFloat(60)
                
                Text("Stroll question")
                    .scaledToFill()
                    .font(.system(size: 10))
                    .bold()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 11)
                    .foregroundStyle(.white)
                    .background(.strollQuestionBG)
                    .clipShape(Capsule())
                    .overlay {
                        Image(user.name)
                            .resizable()
                            .scaledToFill()
                            .frame(width: circleSize, height: circleSize)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(.black, lineWidth: 5)
                            )
                            .offset(y: -38)
                    }
                
                Text(quote)
                    .foregroundStyle(.white)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
                Text("\"\(desc)\"")
                    .foregroundStyle(.recordingDesc)
                    .font(.caption)
                    .italic()
                
                Spacer()
                
                // TIMER FOR SOUND RECORD
                Text("00:00")
                    .bold()
                    .foregroundStyle(.recordingTimer)
                    .font(.subheadline)
                
                // AUDIO VISUALIZER
                Rectangle()
                    .foregroundStyle(.recordingVisualizer)
                    .frame(height: 2)
                
                HStack {
                    Text("Delete")
                        .font(.system(.headline, weight: .regular))
                        .foregroundStyle(.white)
                    
                    Button {
                        if isRecording {
                            recorder.stopRecording()
                            audioUrl = recorder.getRecordingURL()
                        } else {
                            recorder.startRecording()
                        }
                        isRecording.toggle()
                    }label: {
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    
                    Text("Submit")
                        .font(.system(.headline, weight: .regular))
                        .foregroundStyle(.white)
                }
                
                Button(action: {
                    if let audioUrl = audioUrl {
                        player.play(url: audioUrl)
                    }
                }) {
                    Text("▶️ Play")
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .disabled(audioUrl == nil ? true : false)
            }
            .padding()
        }
    }
}


#Preview {
    let user = User(name: "Amanda", age: 22)
    RecordingView(user: user, quote: "What is your most favorite childhood memory?", desc: "Mine is definitely sneaking the late night snacks")
}
