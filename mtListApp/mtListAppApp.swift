//
//  mtListAppApp.swift
//  mtListApp
//
//  Created by Bruno Campos on 5/17/24.
//

import SwiftUI
import SwiftUIScrollOffset

@main
struct mtListAppApp: App {
    var body: some Scene {
        WindowGroup {
            CollapsibleHeaderList(viewModel: CollapsibleHeaderViewModel())
        }
    }
}
