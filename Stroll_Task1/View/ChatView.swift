import SwiftUI
import PagerTabStripView

struct ChatView: View {
    @State var selection = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Turn")
                        .font(.title)
                        .bold()
                    Text("Make your move, they are waiting 🎵")
                        .font(.footnote)
                        .italic()
                        .foregroundStyle(.lightGray)
                }
                
                Spacer()
                
                Image("Rep v2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 90)
            }
            .frame(alignment: .top)
            .padding(.bottom, -40)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    YourTurnCards(image: "Amanda", name: "Amanda", age: 22, quote: "What is your most favorite childhood memory?")
                    YourTurnCards(image: "Malte", name: "Malte", age: 31, quote: "What is the most important quality in friendships to you?", doesMakeMove: true)
                    YourTurnCards(image: "Binghan", name: "Binghan", age: 28, quote: "If you could choose to have one superpower, what would it be?", doesMakeMove: true, showHour: true, blurred: false)
                }
            }
            
            PagerTabStrip(tabs: ["Chats", "Pending"], selection: $selection) {
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("The ice is broken. Time to hit it off")
                            .font(.caption)
                            .padding(.vertical, 10)
                            .italic()
                            .foregroundStyle(.lightGray)
                        
                        ChatBars(isRead: true, chatType: .newChat, pinned: true, isSoundMessage: true, name: "Jessica")
                        ChatBars(isRead: false, chatType: .yourMove, unreadMessageCount: 4, message: "Lol I love house music too", name: "Amanda")
                        ChatBars(isRead: true, message: "You: I love the people there tbh, have you been?", name: "Sila", isDaysAgo: true)
                        ChatBars(isRead: false, chatType: .yourMove, message: "Hahaha that’s interesting, it does seem like people here are starting to like house music more", name: "Marie", isDaysAgo: false)
                        ChatBars(isRead: true, chatType: .newChat, pinned: true, isSoundMessage: true, name: "Jessica")
                    }
                    .tag(0)
                }
                
                VStack {
                    
                }
                .tag(1)
            }
            .padding(.top, -30)
            
        }
        .padding()
        .colorScheme(.dark)
        .background(
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 1050)
                .ignoresSafeArea()
                .overlay(content: {
                    Rectangle()
                        .foregroundStyle(
                            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                        )
                })
                .offset(x: -40, y: 0)
        )
    }
    
    
}

#Preview {
    ChatView()
}
