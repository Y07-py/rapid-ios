//
//  ContentViewModel.swift
//  Rapid
//
//  Created by 木本瑛介 on 2025/08/10.
//

import Foundation
import SwiftUI
import FirebaseMessaging
import Combine

enum LoginStatus {
    case unknown
    case loggedIn
    case loggedOut
}

@MainActor
class ContentViewModel: ObservableObject {
    @Published var loginStatus: LoginStatus = .unknown
    
    private let supabase = SupabaseManager.shared
    private let http: HttpClient = {
        let client = HttpClient(retryPolicy: .exponentialBackoff(3, 4.5))
        return client
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private var isDataLoaded = false
    
    init() {
        // Monitor network connection and check session when established
        NetworkMonitor.shared.$isRealInternetReachable
            .filter { $0 && !self.isDataLoaded }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.startNetworkInitialization()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func startNetworkInitialization() async {
        if await supabase.checkSession() {
            loginStatus = .loggedIn
        } else {
            loginStatus = .loggedOut
        }
        self.isDataLoaded = true
    }
}
