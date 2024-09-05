import SwiftUI
import SwiftUIScrollOffset

public struct CollapsibleHeaderList: View {
    // MARK: - Private Vars
    private let items = Array(0..<100)
    @State private var currentHeight: Double = 40.0
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
            GeometryReader { outsideProxy in
                ScrollView {
                    ZStack(alignment: .top) {
                        GeometryReader { insideProxy in
                            let offset = self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)
                            Color.clear.preference(
                                key: ScrollOffsetInfoPreferenceKey.self,
                                value: ScrollOffsetInfo(offset: offset, offsetToBottom: self.calculateOffsetToBottom(fromOutsideProxy: outsideProxy, insideProxy: insideProxy), scrollableContent: max(0, insideProxy.size.height - outsideProxy.size.height))
                            )
                        }
                        LazyVStack {
                            ForEach(items, id: \.self) { item in
                                Button {
                                } label: {
                                    Text("Item \(item)")
                                }
                            }
                        }
                    }
                }
            }
        }.onPreferenceChange(ScrollOffsetInfoPreferenceKey.self) { offsetInfo in
            updateHeaderHeightOnOffsetChange(offsetInfo)
        }
    }

    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
    }

    private func calculateOffsetToBottom(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        let amountScrolled = (insideProxy.frame(in: .global).minY * -1) + outsideProxy.frame(in: .global).minY + (outsideProxy.size.height)

        let offsetToBottom = insideProxy.size.height - amountScrolled
        return offsetToBottom
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

enum ScrollDirection: Equatable {
    case up(_ value: CGFloat)
    case down(_ value: CGFloat)
    case insignificant
}

public struct ScrollOffsetInfo: Equatable {
    public let offset: CGFloat
    public let offsetToBottom: CGFloat
    public let scrollableContent: CGFloat
}

public struct ScrollOffsetInfoPreferenceKey: PreferenceKey {
    public static var defaultValue: ScrollOffsetInfo = ScrollOffsetInfo(offset: 0, offsetToBottom: 0, scrollableContent: 0)

    public static func reduce(value: inout ScrollOffsetInfo, nextValue: () -> ScrollOffsetInfo) {
    }
}
