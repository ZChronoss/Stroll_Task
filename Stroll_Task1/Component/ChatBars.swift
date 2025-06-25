import SwiftUI

struct ChatBars: View {
    @State var isRead: Bool = false
    var chatType: ChatType?
    var pinned: Bool = false
    
    var isSoundMessage: Bool = false
    var unreadMessageCount: Int = 0
    
    var message: String = ""
    var name: String
    
    var isDaysAgo: Bool = false
    
    private let imageSize: CGFloat = 53
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .center) {
                Image("\(name)")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(Circle())
                
            }
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(name)")
                                .font(.headline)
                                .bold()
                            
                            if let chatType = chatType {
                                ChatBarTag(chatType: chatType)
                            }
                        }
                        if !isSoundMessage {
                            Text("\(message)")
                                .font(.subheadline)
                                .bold(isRead ? false : true)
                                .foregroundStyle(isRead ? .readText : .white)
                        }else {
                            HStack(spacing: 10) {
                                Group {
                                    Image(systemName: "microphone.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 13)
                                    Image(systemName: "waveform")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .bold()
                                }
                                .foregroundStyle(
                                    LinearGradient(gradient: Gradient(colors: [.voiceMessage, .cardHourBackground]), startPoint: .top, endPoint: .bottom)
                                )
                                Text("00:58")
                                    .font(.callout)
                                    .bold()
                                    .foregroundStyle(.voiceMessage)
                            }
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        if !isDaysAgo {
                            Text("6.21 pm")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(.chatHour)
                        } else {
                            Text("Wed")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(.gray)
                        }
                        
                        if pinned && unreadMessageCount == 0 {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 7)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(.pastelPurple)
                                .clipShape(Capsule())
                            
                        }
                        
                        if unreadMessageCount > 0 {
                            Text("\(unreadMessageCount)")
                                .font(.caption2)
                                .bold()
                                .foregroundStyle(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(.pastelPurple)
                                .clipShape(Capsule())
                        }
                    }
                    
                }
                
                Spacer()
                Rectangle()
                    .fill(.divider)
                    .frame(height: 1)
            }
            .padding(.leading, 8)
            
            
        }
        .frame(height: 64)
        .padding(.top, 3)
    }
}

#Preview {
    ChatBars(chatType: .yourMove, name: "Amanda")
}
