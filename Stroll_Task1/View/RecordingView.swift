import SwiftUI

struct RecordingView: View {
    @Environment(\.flowDismiss) var flowDismiss
    @State var opacity: CGFloat = 0
    
    var user: User
    let quote: String
    let desc: String
    
    /*
     TODO: - UI implement and
     TODO: - audio visualizer
     TODO: - control component's opacity when this view open with flow animation (idk how)
     */
    
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
                VStack(spacing: 10) {
                    HStack(spacing: 19) {
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
                            .opacity(opacity)
                        
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
                            .opacity(opacity)
                    }
                    .opacity(opacity)
                
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
                
                AudioControl() {
                    flowDismiss()
                }
                .padding(.top, 35)
            }
            .padding()
            .withFlowAnimation {
                opacity = 1
            }onDismiss: {
                opacity = 0
            }
        }
    }
}


#Preview {
    let user = User(name: "Amanda", age: 22)
    RecordingView(user: user, quote: "What is your most favorite childhood memory?", desc: "Mine is definitely sneaking the late night snacks")
}
