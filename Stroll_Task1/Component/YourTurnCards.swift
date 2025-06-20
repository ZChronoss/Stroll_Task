import SwiftUI
import Charts

struct Data: Identifiable {
    var id = UUID()
    
    let hours: Int
}

struct YourTurnCards: View {
    let image: String
    let name: String
    let age: Int
    let quote: String
    
    var doesMakeMove: Bool = false
    var showHour: Bool = false
    
    var blurred: Bool = true
    
    @State private var hours: [Data] = [
        .init(hours: 24),
        .init(hours: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Group {
                Image(image)
                    .resizable()
                    .scaledToFill()
                Rectangle()
                    .foregroundStyle(.black)
                    .frame(width: 210, height: 80)
                    .blur(radius: 10)
                    .padding(.bottom, 20)
                
            }
            .blur(radius: blurred ? 30 : 0)
            
            VStack(spacing: 8) {
                if doesMakeMove && showHour {
                    HStack {
                        Text("📣")
                            .padding(8)
                            .background(.black)
                            .clipShape(Circle())
                        
                        Spacer()
                        
                        Chart {
                            SectorMark(angle: .value("", 0..<16), innerRadius: .ratio(0.9))
                                .foregroundStyle(.white)
                          SectorMark(angle: .value("", 16..<24))
                                .foregroundStyle(.clear)
                        }
                        .scaledToFit()
                        .chartLegend(.hidden)
                        .chartBackground { proxy in
                            Text("16h")
                                .bold()
                                .font(.caption)
                        }
                        .background(
                            Circle()
                                .fill(.cardHourBackground)
                        )
                        .frame(width: 35)
                        .shadow(color: .black, radius: 8)
                    }
                    .padding(.horizontal)
                }
                
                if doesMakeMove && !showHour {
                    Text("📣 They made a move!")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .font(.caption2)
                        .background(.black)
                        .clipShape(Capsule())
                }else {
                    Text("")
                        .padding(.vertical, 4)
                }
                Spacer()
                
                if blurred {
                    Text("Tap to answer")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(name), \(age)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(quote)
                    .font(.caption)
                    .foregroundStyle(.cardDesc)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 45)
            .foregroundColor(.white)
        }
        .frame(width: 195, height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
}

#Preview {
    YourTurnCards(image: "Amanda", name: "Amanda", age: 22, quote: "What is your most favorite childhood memory?")
}
