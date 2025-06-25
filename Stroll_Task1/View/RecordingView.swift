import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct RecordingView: View {
    @Environment(\.flowDismiss) var flowDismiss
    @State var opacity: CGFloat = 0
    
    var user: User
    let quote: String
    let desc: String
    
    private let image: Image
    
    init(user: User, quote: String, desc: String) {
        self.user = user
        self.quote = quote
        self.desc = desc
        
        let uiImage = UIImage(named: user.name) ?? UIImage()
        let filteredUIImage = RecordingView.applyVignetteEffect(to: uiImage)
        image = Image(uiImage: filteredUIImage)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .overlay {
                        LinearGradient(colors: [.clear, .clear, .clear, .black], startPoint: .top, endPoint: .bottom)
                    }
                
                Rectangle()
                    .fill(Color.black)
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
                    
                    HStack(alignment: .center) {
                        Label("", systemImage: "chevron.left")
                            .font(.callout)
                            .bold()
                            .onTapGesture {
                                flowDismiss()
                            }
                            .frame(width: 45)
                        
                        Spacer()
                        
                        Text("\(user.name), \(user.age)")
                            .font(.system(size: 20, weight: .bold))
                            .opacity(opacity)
                        
                        Spacer()
                        
                        Label("", systemImage: "ellipsis")
                            .font(.body)
                            .bold()
                            .frame(width: 45)
                    }
                    .foregroundStyle(.white)
                    .padding(.top, 5)
                }
                
                Spacer()
                
                let circleSize = CGFloat(55)
                
                Text("Stroll question")
                    .scaledToFill()
                    .font(.system(.caption, weight: .semibold))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 11)
                    .foregroundStyle(.white)
                    .background(.strollQuestionBG)
                    .clipShape(Capsule())
                    .overlay {
                        Image(user.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: circleSize, height: circleSize)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(.black, lineWidth: 5)
                            )
                            .offset(y: -36)
                            .opacity(opacity)
                    }
                    .opacity(opacity)
                    .padding(.bottom, -6)
                
                // I can't make the line spacing in this part closer even with negative number
                Text(quote)
                    .foregroundStyle(.white)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
                Text("\"\(desc)\"")
                    .foregroundStyle(.recordingDesc)
                    .font(.subheadline)
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
        .padding(.top, 35)
        .toolbarVisibility(.hidden, for: .tabBar)
        .ignoresSafeArea(edges: .vertical)
    }
    
    static func applyVignetteEffect(to inputImage: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: inputImage) else {
            fatalError("Image can't be loaded")
        }
        
        let filter = CIFilter.vignette()
        filter.inputImage = ciImage
        filter.intensity = 5.0
        
        let context = CIContext()
        
        // Create a CGImage from the CIImage
        guard let outputCIImage = filter.outputImage, let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return inputImage
        }
        
        // Create a UIImage from the CGImage
        let outputUIImage = UIImage(cgImage: cgImage)
        
        return outputUIImage
    }
        
}


#Preview {
    let user = User(id: 1, name: "Amanda", age: 22, question: "What is your most favorite childhood memory?")
    RecordingView(user: user, quote: "What is your most favorite childhood memory?", desc: "Mine is definitely sneaking the late night snacks")
}
