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
    @StateObject var viewModel = CollapsibleHeaderViewModel()

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
                    }.onAppear {
                        viewModel.onCellAppear(index: item)
                        print("@@ item \(item) appeared")
                    }
                }
            }
        }.environment(\.defaultMinListRowHeight, 0)
        .listStyle(.plain)
        .onReceive(viewModel.$state) { state in
            DispatchQueue.main.async {

                switch(state) {
                case .collapse:
                    print("@@willcollapse")
                    collapseHeader()
                case .expand:
                    print("@@willexpand")
                    expandHeader()
                case .initial: 
                    break
                }
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
}
