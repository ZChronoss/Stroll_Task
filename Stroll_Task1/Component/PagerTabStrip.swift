import SwiftUI


/// I was trying to use an external library for the pager tab strip but with scroll view as the parent view, it will not render the item inside each tab.
/// So i created this with the help of chatGPT, but it still shows the same error, so i'm just gonna use this.

struct TabItemPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


struct PagerTabStrip<Content: View>: View {
    let tabs: [String]
    @Binding var selection: Int
    let content: () -> Content
    
    @State private var tabFrames: [Int: CGRect] = [:]
    
    init(tabs: [String], selection: Binding<Int>, @ViewBuilder content: @escaping () -> Content) {
        self.tabs = tabs
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tab Titles
            HStack(spacing: 20) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selection = index
                        }
                    }) {
                        Text(tabs[index])
                            .bold()
                            .font(.title)
                            .foregroundColor(selection == index ? .white : .gray)
                            .padding(.vertical, 4)
                            .background(GeometryReader { geo in
                                Color.clear
                                    .preference(key: TabItemPreferenceKey.self,
                                                value: [index: geo.frame(in: .global)])
                            })
                    }
                }
            }
            .onPreferenceChange(TabItemPreferenceKey.self) { value in
                tabFrames = value
            }
            .overlay(
                GeometryReader { geometry in
                    if let frame = tabFrames[selection] {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: frame.width, height: 2)
                            .offset(x: frame.minX - geometry.frame(in: .global).minX, y: geometry.size.height - 2)
                            .animation(.easeInOut, value: frame)
                    }
                }
            )
            
            // Tab Content
            TabView(selection: $selection) {
                content()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}
