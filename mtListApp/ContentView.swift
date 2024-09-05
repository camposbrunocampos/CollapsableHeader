import SwiftUI
import SwiftUIScrollOffset

public struct CollapsibleHeaderList: View {
    // MARK: - Private Vars
    private let items = Array(0..<100)
    @State private var currentHeight: Double = 0
    @State private var lastOffset: Double = 0
    @State private var animationDuration: TimeInterval = 0.2
    @State private var lastAnimationDate: Date?
    private var expandedHeight: CGFloat = 40.0
    
    // MARK: - View
    public var body: some View {
        VStack {
            Rectangle()
                .foregroundColor(.pink)
                .frame(height: currentHeight)
            List {
                ForEach(items, id: \.self) { item in
                    Button {
                    } label: {
                        Text("Item \(item)")
                    }
                }
            }
        }.environment(\.defaultMinListRowHeight, 0)
            .modifier(ListOffsetModifier(id: "foo"))
            .listStyle(.plain)
            .onPreferenceChange(ListOffsetKey.self) { offsetInfo in
                if let offsetInfo {
                    updateHeaderHeightOnOffsetChange(offsetInfo)
                }
            }
    }
    
    private func updateHeaderHeightOnOffsetChange(_ offsetInfo: ScrollOffsetInfo) {
        DispatchQueue.main.async {
            let isInitialPosition = offsetInfo.offset == 0 && lastOffset == 0
            guard didFinishLastAnimation() else { return }
            
            if isInitialPosition {
                expandHeader()
                return
            }
            
            switch scrollDirection(offsetInfo.offset) {
            case .up:
                collapseHeader()
                
            case .down:
                expandHeader()
                
            case .insignificant:
                return
            }
        }
    }
    
    func expandHeader() {
        withAnimation(.easeOut(duration: animationDuration)) {
            currentHeight = expandedHeight
            lastAnimationDate = Date()
        }
    }
    
    func collapseHeader() {
        withAnimation(.easeOut(duration: animationDuration)) {
            currentHeight = 0
            lastAnimationDate = Date()
        }
    }
    
    func didFinishLastAnimation() -> Bool {
        guard let lastAnimationDate else {
            return true
        }
        
        return abs(lastAnimationDate.timeIntervalSinceNow) > animationDuration
    }
    
    func scrollDirection(_ currentOffset: CGFloat) -> ScrollDirection {
        let scrollOffsetDifference = abs(currentOffset) - abs(lastOffset)
        let threshold = 1.0
        
        if abs(scrollOffsetDifference) > threshold {
            let status: ScrollDirection = scrollOffsetDifference > 0
            ? .up(scrollOffsetDifference)
            : .down(scrollOffsetDifference)
            
            lastOffset = currentOffset
            return status
        } else {
            lastOffset = currentOffset
            return .insignificant
        }
    }
}

struct ListOffsetModifier: ViewModifier {
    @ScrollOffset(.top, id: "1") private var scrollOffset
    @ScrollOffset(.bottom, id: "1") private var bottomScrollOffset
    @State private var id: String
    @State private var lastOffset: CGFloat = 0.0

    init(id: String) {
        self.id = id
        _scrollOffset = .init(.top, id: id)
        _bottomScrollOffset = .init(.bottom, id: id)
    }

    func body(content: Content) -> some View {
        content
            .scrollOffsetID(id)
            .preference(key: ListOffsetKey.self, value: update(scrollOffset))
    }

    private func update(_ offset: CGFloat) -> ScrollOffsetInfo {
        .init(offset: offset, offsetToBottom: bottomScrollOffset, scrollableContent: 0)
    }
}

enum ScrollDirection: Equatable {
    case up(_ value: CGFloat)
    case down(_ value: CGFloat)
    case insignificant
}

// MARK: Entities
struct ListOffsetKey: PreferenceKey {
    typealias Value = ScrollOffsetInfo?
    static var defaultValue: ScrollOffsetInfo?

    static func reduce(value: inout ScrollOffsetInfo?, nextValue: () -> ScrollOffsetInfo?) {
        value = nextValue()
    }
}

public struct ScrollOffsetInfo: Equatable {
    public let offset: CGFloat
    public let offsetToBottom: CGFloat
    public let scrollableContent: CGFloat
}
