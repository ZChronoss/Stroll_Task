import SwiftUI
import FlowStack

var users: [User] = [
    User(name: "Amanda", age: 22),
    User(name: "Malte", age: 31),
    User(name: "Binghan", age: 28)
]

struct ChatView: View {
    @Namespace var animation
    
    @State var selection = 0
    
    var body: some View {
        FlowStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(spacing: 14) {
                            Text("Your Turn")
                                .font(.title2)
                                .bold()
                            
                            Text("7")
                                .font(.caption2)
                                .bold()
                                .foregroundStyle(.black)
                                .padding(5)
                                .background(.pastelPurple)
                                .clipShape(Circle())
                        }
                        Text("Make your move, they are waiting 🎵")
                            .font(.footnote)
                            .italic()
                            .foregroundStyle(.lightGrayCust)
                    }
                    
                    Spacer()
                    
                    Image("Rep v2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 68)
                }
                .frame(alignment: .top)
                .padding(.top, -30)
                .padding(.bottom, -100)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        ForEach(users) { user in
                            FlowLink(value: user, configuration: .init(cornerRadius: 20)) {
                                YourTurnCards(user: user, quote: "What is your most favorite childhood memory?", blurred: false)
                            }
                        }
                    }
                }
                .flowDestination(for: User.self) { user in
                    RecordingView(user: user, quote: "What is your most favorite childhood memory?", desc: "Mine is definitely sneaking the late night snacks")
                }
                .padding(.top, -60)
                
                PagerTabStrip(tabs: ["Chats", "Pending"], selection: $selection) {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            Text("The ice is broken. Time to hit it off")
                                .font(.caption)
                                .padding(.vertical, 10)
                                .italic()
                                .foregroundStyle(.lightGrayCust)
                            
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
                .padding(.top, -75)
                
            }
            .padding()
            .colorScheme(.dark)
            .background(
                Image("background")
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
}

#Preview {
    ChatView()
}
