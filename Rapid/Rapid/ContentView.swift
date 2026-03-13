//
//  ContentView.swift
//  Rapid
//
//  Created by 木本瑛介 on 2025/08/06.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var contentViewModel = ContentViewModel()
    @StateObject private var userLocationViewModel = UserLocationViewModel()
    
    var body: some View {
        switch contentViewModel.loginStatus {
        case .unknown:
            UnKnownView()
        case .loggedIn:
            MainRootView(mainRoot: .home)
        case .loggedOut:
            MainRootView(mainRoot: .login)
        }
    }
}

#Preview {
    ContentView()
}
