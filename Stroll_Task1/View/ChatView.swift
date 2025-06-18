import SwiftUI

struct ChatView: View {
    var body: some View {
        ScrollView {
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
            }
            .frame(alignment: .top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    YourTurnCards()
                    YourTurnCards()
                }
            }
        }
        .padding()
        .colorScheme(.dark)
        .background(.black)
    }
}

#Preview {
    ChatView()
}
