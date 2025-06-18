import SwiftUI

struct YourTurnCards: View {
    var body: some View {
        ZStack {
            Image("Amanda")
                .resizable()
                .scaledToFill()
                .blur(radius: 30)

            VStack(spacing: 8) {
                Spacer()
                
                Text("Tap to answer")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Amanda, 22")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("What is your most favorite childhood memory?")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
            }
            .padding()
            .foregroundColor(.white)
        }
        .frame(width: 200, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
}

#Preview {
    YourTurnCards()
}
