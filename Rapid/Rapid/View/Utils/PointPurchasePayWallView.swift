//
//  PointPurchasePayWallView.swift
//  Rapid
//
//  Created by Antigravity on 2026/03/02.
//

import SwiftUI
import RevenueCat

struct MockPointPlan: Identifiable {
    let id: String
    let points: Int
    let price: String
    let discount: String?
}

struct PointPurchasePayWallView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool
    
    @State private var currentOffering: Offering?
    @State private var isProcessing: Bool = false
    @State private var showSuccess: Bool = false
    @State private var selectedPlanId: String? = "plan_3" // Select one by default
    
    private let mockPlans: [MockPointPlan] = [
        .init(id: "plan_1", points: 60, price: "¥200", discount: nil),
        .init(id: "plan_2", points: 120, price: "¥380", discount: "5% OFF"),
        .init(id: "plan_3", points: 180, price: "¥540", discount: "10% OFF"),
        .init(id: "plan_4", points: 240, price: "¥680", discount: "15% OFF"),
        .init(id: "plan_5", points: 300, price: "¥800", discount: "20% OFF")
    ]
    
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            
            if showSuccess {
                successView
            } else {
                mainContentView
            }
            
            if isProcessing {
                processingOverlay
            }
        }
        .onAppear {
            fetchOfferings()
        }
    }
    
    private var mainContentView: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(spacing: 32) {
                    titleSection
                    
                    planListSection
                    
                    purchaseButtonSection
                }
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black.opacity(0.6))
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var titleSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .baseShadow()
                
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.orange)
            }
            
            Text("ポイントをチャージ")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(.black.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("スポットの検索やボイスチャット機能に\nポイントを利用できます。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
    }
    
    private var planListSection: some View {
        VStack(spacing: 12) {
            ForEach(mockPlans) { plan in
                planRow(plan: plan)
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func planRow(plan: MockPointPlan) -> some View {
        let isSelected = selectedPlanId == plan.id
        
        Button(action: {
            withAnimation(.snappy) {
                selectedPlanId = plan.id
            }
        }) {
            HStack {
                // Points
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(plan.points)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(isSelected ? Color.subscriptionColor : .black.opacity(0.8))
                    Text("pt")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isSelected ? Color.subscriptionColor.opacity(0.8) : .gray)
                        .padding(.bottom, 3)
                }
                
                Spacer()
                
                // Discount badge
                if let discount = plan.discount {
                    Text(discount)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
                
                // Price
                Text(plan.price)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? Color.subscriptionColor : .black.opacity(0.8))
                    .frame(width: 70, alignment: .trailing)
            }
            .padding(16)
            .background(isSelected ? Color.subscriptionColor.opacity(0.05) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.subscriptionColor : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Color.subscriptionColor.opacity(0.2) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var purchaseButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                // TODO: Replace with purchase(package: package) after app review
                guard let _ = selectedPlanId else { return }
                
                isProcessing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isProcessing = false
                    withAnimation { showSuccess = true }
                }
            }) {
                Text("購入する")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(selectedPlanId == nil ? Color.gray : Color.subscriptionColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .baseShadow()
            }
            .disabled(selectedPlanId == nil)
            
            Text("ポイントの有効期限は購入日から180日です。")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 20)
    }
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("決済を処理しています...")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
    
    private var successView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.orange)
            }
            
            VStack(spacing: 12) {
                Text("チャージ完了！")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.black.opacity(0.8))
                
                if let planId = selectedPlanId,
                   let plan = mockPlans.first(where: { $0.id == planId }) {
                    Text("\(plan.points)ポイントを獲得しました。\nさっそく機能を使ってみましょう！")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Text("閉じる")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .padding(20)
    }
    
    // MARK: - RevenueCat Integration (Placeholder)
    
    private func fetchOfferings() {
        // TODO: Fetch Offerings for points via RevenueCat
        Purchases.shared.getOfferings { offerings, error in
            if let offering = offerings?.offering(identifier: "points_packages") {
                self.currentOffering = offering
            }
        }
    }
    
    private func purchase(package: Package) {
        isProcessing = true
        Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
            isProcessing = false
            if let customerInfo = customerInfo, !userCancelled {
                // TODO: Integrate point addition API to Supabase
                withAnimation {
                    showSuccess = true
                }
            }
        }
    }
}

#Preview {
    PointPurchasePayWallView(isPresented: .constant(true))
        .environmentObject(ProfileViewModel())
}
