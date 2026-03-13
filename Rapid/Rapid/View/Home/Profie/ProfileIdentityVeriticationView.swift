//
//  ProfileIdentityVeriticationView.swift
//  Rapid
//
//  Created by Antigravity on 2026/03/09.
//

import SwiftUI

struct ProfileIdentityVeriticationView: View {
    @Binding var isShowWindow: Bool
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @State private var idToVerify: IdentificationType? = nil
    
    var body: some View {
        ZStack {
            // Background Layer
            Color.backgroundColor.ignoresSafeArea()
            
            // Decorative background glow
            VStack {
                Circle()
                    .fill(Color.mainColor.opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -150, y: -100)
                Spacer()
                Circle()
                    .fill(Color.selectedColor.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: 150, y: 100)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Illustration or Icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color.selectedColor.opacity(0.1), Color.selectedColor.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(LinearGradient(colors: [Color.mainColor, Color.selectedColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .shadow(color: Color.selectedColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 20)
                        
                        // Description Section
                        VStack(spacing: 12) {
                            Text("本人確認について")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.black.opacity(0.8))
                            
                            Text("有料プランの各種機能をご利用いただく場合は、公的証明書による本人確認をお願いしております。\n本人確認を完了すると、信頼の証としてプロフィールに認証バッジが表示されます。")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.black.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal, 10)
                        }
                        
                        // Selection Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("利用する証明書を選択")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.black.opacity(0.5))
                                .padding(.leading, 5)
                            
                            VStack(spacing: 15) {
                                verificationButton(title: "運転免許証", icon: "car.circle.fill") {
                                    idToVerify = .driversLicense
                                }
                                
                                verificationButton(title: "マイナンバーカード", icon: "person.text.rectangle.fill") {
                                    idToVerify = .myNumber
                                }
                                
                                verificationButton(title: "パスポート", icon: "book.fill") {
                                    idToVerify = .passport
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                        // Privacy Note
                        HStack(spacing: 14) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.selectedColor)
                            
                            Text("お預かりした個人情報は本人確認完了後、速やかに削除されます。また、本人確認以外の目的で使用されることはありません。")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.gray)
                        }
                        .padding(20)
                        .background(Color.secondaryBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 50)
                }
            }
        }
        .fullScreenCover(item: $idToVerify) { type in
            IdentificationRootView(isPresented: Binding(
                get: { idToVerify != nil },
                set: { if !$0 { idToVerify = nil } }
            ), idType: type)
            .environmentObject(profileViewModel)
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation(.spring()) {
                    isShowWindow = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(Color.secondaryBackgroundColor)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("本人確認")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            Spacer()
            
            // Empty space for balance
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 15)
    }
    
    @ViewBuilder
    private func verificationButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
                    .background(Color.selectedColor.opacity(0.1))
                    .foregroundStyle(Color.selectedColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black.opacity(0.7))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(Color.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileIdentityVeriticationView(isShowWindow: .constant(true))
}
