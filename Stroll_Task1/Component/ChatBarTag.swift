import SwiftUI

public enum ChatType {
    case yourMove
    case newChat
}

struct ChatBarTag: View {
    var chatType: ChatType
    private var text: String = ""
    private var backgroundColor: Color
    
    init(chatType: ChatType) {
        self.chatType = chatType
        
        switch chatType {
        case .yourMove:
            text = "Your Move"
            backgroundColor = .divider
        case .newChat:
            text = "New Chat"
            backgroundColor = .newChatTag
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if chatType == .newChat {
                Circle()
                    .frame(width: 5)
            }
            Text(text)
                .font(.system(size: 10, weight: .regular))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, chatType == .newChat ? 3 : 2)
        .background(backgroundColor)
        .clipShape(Capsule())
        
    }
}

#Preview {
    ChatBarTag(chatType: .yourMove)
}
