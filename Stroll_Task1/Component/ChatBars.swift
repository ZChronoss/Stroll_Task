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
    
    private let imageSize: CGFloat = 70
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
                HStack {
                    Text("\(name)") // Name
                        .font(.headline)
                    
                    if let chatType = chatType {
                        ChatBarTag(chatType: chatType)
                    }
                }
                
                if !isSoundMessage {
                    Text("\(message)")
                        .bold(isRead ? false : true)
                        .foregroundStyle(isRead ? .readText : .white)
                }else {
                    HStack {
                        Group {
                            Image(systemName: "microphone.fill")
                                .bold()
                            Image(systemName: "waveform")
                                .bold()
                            
                        }
                        .foregroundStyle(
                            LinearGradient(gradient: Gradient(colors: [.voiceMessage, .cardHourBackground]), startPoint: .top, endPoint: .bottom)
                        )
                        Text("00:58")
                            .bold()
                            .foregroundStyle(.voiceMessage)
                    }
                }
                
                Spacer()
                Divider()
                    .padding(.top)
                    .frame(height:1)
                    .overlay {
                        Color.divider
                    }
            }
            .padding(.leading, 8)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if !isDaysAgo {
                    Text("6.21 pm")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.chatHour)
                } else {
                    Text("Wed")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.gray)
                }
                
                if pinned && unreadMessageCount == 0 {
                    Image(systemName: "star.fill")
                        .font(.system(size: 7))
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
        .frame(height: 80)
    }
}

#Preview {
    ChatBars(chatType: .yourMove, name: "Amanda")
}
