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
        HStack {
            if chatType == .newChat {
                Circle()
                    .frame(width: 8)
            }
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .clipShape(Capsule())
        
    }
}

#Preview {
    ChatBarTag(chatType: .yourMove)
}
