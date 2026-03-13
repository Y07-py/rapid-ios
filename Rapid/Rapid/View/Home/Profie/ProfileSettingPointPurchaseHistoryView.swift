//
//  ProfileSettingPointPurchaseHistoryView.swift
//  Rapid
//
//  Created by 木本瑛介 on 2026/02/23.
//

import Foundation
import SwiftUI

struct ProfileSettingPointPurchaseHistoryView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @Binding var isShowWindow: Bool
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(alignment: .center, spacing: .zero) {
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
