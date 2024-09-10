//
//  CollapsibleHeaderViewModel.swift
//  mtListApp
//
//  Created by Bruno Campos on 9/10/24.
//

import Foundation
import Combine

public enum HeaderState {
    case initial
    case collapse
    case expand
}
public class CollapsibleHeaderViewModel: ObservableObject {
    @Published private(set) public var state: HeaderState
    private var indexSubject = PassthroughSubject<Int, Never>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.state = .initial
        setupCollapsibleHeaderListener()
    }

    public func onCellAppear(index: Int) {
        indexSubject.send(index)
    }

    private func setupCollapsibleHeaderListener() {
        indexSubject
            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.main, latest: true)
            .withPrevious()
            .map { (previous, current) in
                if let previous, previous < current {
                    return .collapse
                } else {
                    return .expand
                }
            }
            .removeDuplicates()
            .sink { [weak self] headerState in
                self?.state = headerState
            }.store(in: &cancellables)
    }
}



extension Publisher {
    /// Includes the current element as well as the previous element from the upstream publisher in a tuple where the previous element is optional.
    /// The first time the upstream publisher emits an element, the previous element will be `nil`.
    /// This code was copied from https://stackoverflow.com/questions/63926305/combine-previous-value-using-combine
    ///
    ///     let range = (1...5)
    ///     cancellable = range.publisher
    ///         .withPrevious()
    ///         .sink { print ("(\($0.previous), \($0.current))", terminator: " ") }
    ///      // Prints: "(nil, 1) (Optional(1), 2) (Optional(2), 3) (Optional(3), 4) (Optional(4), 5) ".
    ///
    /// - Returns: A publisher of a tuple of the previous and current elements from the upstream publisher.
    public func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        scan(Optional<(Output?, Output)>.none) { ($0?.1, $1) }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
