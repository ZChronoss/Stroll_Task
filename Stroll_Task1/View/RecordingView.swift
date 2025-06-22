import SwiftUI

struct RecordingView: View {
    @Environment(\.flowDismiss) var flowDismiss
    
    var user: User
    
    var body: some View {
        VStack {
            Text("Back")
                .onTapGesture {
                    flowDismiss()
                }
            Image(user.name)
                .resizable()
                .scaledToFit()
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    let user = User(name: "Amanda", age: 22)
    RecordingView(user: user)
}
