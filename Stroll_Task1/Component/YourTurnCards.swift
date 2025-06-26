import SwiftUI
import Charts

struct CardData: Identifiable {
    var id = UUID()
    
    let hours: Int
}

struct YourTurnCards: View {
    let user: User
    let quote: String
    
    var doesMakeMove: Bool = false
    var showHour: Bool = false
    
    var blurred: Bool = true
    
    @State private var hours: [CardData] = [
        .init(hours: 24),
        .init(hours: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .bottom) {
                Image(user.name)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        LinearGradient(colors: [.clear, .cardBottom], startPoint: .top, endPoint: .bottom)
                    }
                Rectangle()
                    .foregroundStyle(.cardBottom)
                    .frame(width: 180, height: 65)
                    .blur(radius: 10)
                
            }
            .blur(radius: blurred ? 30 : 0)
            
            VStack(spacing: 8) {
                if doesMakeMove && showHour {
                    HStack {
                        Text("📣")
                            .font(.caption)
                            .padding(5)
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
                        .frame(width: 30)
                        .shadow(color: .black, radius: 8)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 10)
                }
                
                Group {
                    if doesMakeMove && !showHour {
                        Text("📣 They made a move!")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .font(.system(size: 10, weight: .regular))
                            .background(.black)
                            .clipShape(Capsule())
                    }else {
                        Text("")
                            .padding(.vertical, 4)
                            .font(.system(size: 10, weight: .regular))
                    }
                    
                }
                .padding(.top, 10)
                
                if doesMakeMove && showHour {
                    
                } else {
                    Spacer()
                    
                }
                
                if blurred {
                    Text("Tap to answer")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(user.name), \(user.age)")
                    .font(.headline)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(quote)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.cardDesc)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
                    .padding(.top, -4)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 2)
            .foregroundColor(.white)
        }
        .frame(width: 150, height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
}
