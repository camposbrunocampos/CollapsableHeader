//
//  DummyFile.swift
//  mtListApp
//
//  Created by Bruno Campos on 5/24/24.
//

import Foundation
import SwiftUI

public struct DummyFile<MyView: View>: View {
    private let someClosure: MyView
    @State private var shouldShowClosure: Bool = false

    init(someClosure: @escaping () -> MyView) {
        self.someClosure = someClosure()
    }

    public var body: some View {
        VStack {
            let _ = Self._printChanges()
            if shouldShowClosure {
                someClosure
            }

            Button {
                shouldShowClosure.toggle()
            } label: {
                Text("Increment number")
            }
        }
    }
}
