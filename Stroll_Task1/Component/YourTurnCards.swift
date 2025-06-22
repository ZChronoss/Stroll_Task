import SwiftUI
import Charts

struct Data: Identifiable {
    var id = UUID()
    
    let hours: Int
}

struct YourTurnCards: View {
    let user: User
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
                Image(user.name)
                    .resizable()
                    .scaledToFill()
                Rectangle()
                    .foregroundStyle(.black)
                    .frame(width: 180, height: 110)
                    .blur(radius: 10)
                
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
                        .font(.system(size: 10))
                        .background(.black)
                        .clipShape(Capsule())
                }else {
                    Text("")
                        .padding(.vertical, 4)
                        .font(.system(size: 10))
                }
                Spacer()
                
                if blurred {
                    Text("Tap to answer")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(user.name), \(user.age)")
                    .font(.system(size: 15))
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(quote)
                    .font(.system(size: 10))
                    .foregroundStyle(.cardDesc)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 45)
            .padding(.top, -15)
            .foregroundColor(.white)
        }
        .frame(width: 158, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
}
