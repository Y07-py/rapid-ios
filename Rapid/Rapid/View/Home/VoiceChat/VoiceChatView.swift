//
//  VoiceChatView.swift
//  Rapid
//
//  Created by 木本瑛介 on 2026/02/18.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import PopupView
import Lottie

struct VoiceChatView: View {
    @EnvironmentObject private var voiceChatViewModel: VoiceChatViewModel
    
    @State private var isShowMakeRoomView: Bool = false
    @State private var isShowDetailView: Bool = false
    @State private var isShowLikePopup: Bool = false
    @State private var isShowVoiceChatRoomButton: Bool = true
    @State private var isShowRoomManagementView: Bool = false
    @State private var isShowFilterView: Bool = false
    
    var body: some View {
        ZStack {
            // Background Layer
            Color.backgroundColor.ignoresSafeArea()
            
            // Decorative background glows
            VStack {
                Circle()
                    .fill(Color.thirdColor.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -150, y: -100)
                Spacer()
                Circle()
                    .fill(Color.mainColor.opacity(0.12))
                    .frame(width: 250, height: 250)
                    .blur(radius: 70)
                    .offset(x: 150, y: 100)
            }
            .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: .zero) {
                headerView
                
                if voiceChatViewModel.voiceChatRooms.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(.vertical) {
                        VStack(alignment: .center, spacing: 20) {
                            ForEach(voiceChatViewModel.voiceChatRooms) { room in
                                chatRoomCardView(room: room)
                            }
                            
                            Spacer().frame(height: 120)
                        }
                        .padding(.top, 10)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .bottom) {
                if isShowVoiceChatRoomButton {
                    Group {
                        if let voiceChatRoom = self.voiceChatViewModel.currentUserVoiceChatRoom {
                            checkVoiceChatRoomButtonView(room: voiceChatRoom)
                        } else {
                            makeVideoChatButtonView
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $isShowMakeRoomView) {
                MakeVoiceChatRoomView(isShowMakeRoomView: $isShowMakeRoomView, isShowVoiceChatRoomButton: $isShowVoiceChatRoomButton)
                    .environmentObject(voiceChatViewModel)
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $isShowRoomManagementView, content: {
                MyVoiceChatRoomDetailView(isPresented: $isShowRoomManagementView)
                    .environmentObject(voiceChatViewModel)
            })
            .fullScreenCover(isPresented: $isShowDetailView) {
                VoiceChatDetailView(isShowDetailView: $isShowDetailView)
                    .environmentObject(voiceChatViewModel)
            }
            .sheet(isPresented: $isShowFilterView) {
                VoiceChatFilterView(isShowWindow: $isShowFilterView)
                    .environmentObject(voiceChatViewModel)
                    .presentationDetents([.fraction(0.8), .large])
                    .presentationDragIndicator(.visible)
            }
            .popup(isPresented: $isShowLikePopup) {
                likePopupView
            } customize: { view in
                view
                    .type(.floater())
                    .appearFrom(.centerScale)
                    .position(.center)
                    .animation(.bouncy)
                    .backgroundColor(.black.opacity(0.3))
                    .autohideIn(2.0)
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ボイスチャット")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                Text("リアルタイムで繋がる")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.isShowFilterView.toggle()
                    }
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(width: 44, height: 44)
                        .background(Color.secondaryBackgroundColor)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 15)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.thirdColor.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "mic.slash.fill")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color.thirdColor.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text("ボイスチャットがありません")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                Text("現在、募集中のルームはありません。\n自分でルームを作成して募集してみましょう！")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.bottom, 100)
    }
    
    @ViewBuilder
    private var makeVideoChatButtonView: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isShowMakeRoomView.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "mic.fill.badge.plus")
                    .font(.system(size: 20, weight: .bold))
                
                Text("ボイスチャットを作成")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.thirdColor)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 40)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 25)
    }
    
    @ViewBuilder
    private func checkVoiceChatRoomButtonView(room: VoiceChatRoomWithUserProfile) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isShowRoomManagementView.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 20, weight: .bold))
                
                Text("チャットルームの確認")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.mainColor)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 40)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 25)
    }
    
    @ViewBuilder
    private func chatRoomCardView(room: VoiceChatRoomWithUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                // Profile Photo with Brand Glow
                ZStack {
                    Circle()
                        .fill(Color.mainColor.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Group {
                        if let photo = room.profile.profileImages.first {
                            WebImage(url: photo.imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                    .frame(width: 58, height: 58)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.profile.user.userName ?? "No Name")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.black.opacity(0.85))
                    
                    HStack(spacing: 4) {
                        Text("\(room.profile.user.birthDate?.computeAge() ?? 0)歳")
                        Text("•")
                        Text(room.profile.user.residence ?? "居住地未設定")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
                }
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.thirdColor)
                        .frame(width: 8, height: 8)
                    Text("募集中")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.thirdColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.thirdColor.opacity(0.1))
                .clipShape(Capsule())
            }
            
            // Message Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.mainColor.opacity(0.6))
                    
                    Text(room.voiceChatRoomWithRecruitment.voiceChatRoom.message)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.black.opacity(0.8))
                        .lineSpacing(4)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.03), lineWidth: 1)
            )
            
            // Shared Spot Card
            if let place = room.places.first {
                HStack(spacing: 12) {
                    Group {
                        if let placePhoto = place.place?.photos?.first {
                            WebImage(url: placePhoto.buildUrl()) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().foregroundStyle(.gray.opacity(0.1)).skelton(isActive: true)
                            }
                        } else {
                            Image("NoPlaceImage").resizable().scaledToFill()
                        }
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.selectedColor)
                            Text("集合スポット")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                        
                        Text(place.place?.displayName?.text ?? "不明なスポット")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.gray.opacity(0.5))
                }
                .padding(12)
                .background(Color.secondaryBackgroundColor.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    self.voiceChatViewModel.selectedVoiceChatRoom = room
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.isShowDetailView.toggle()
                    }
                }
            }
            
            // Action Button
            Button(action: {
                guard !room.checked else { return }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.isShowLikePopup.toggle()
                }
                self.voiceChatViewModel.sendLikeToVoiceChatRoom(room: room)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: room.checked ? "checkmark.circle.fill" : "hand.thumbsup.fill")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(room.checked ? "いいねしました" : "いいね")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(room.checked ? Color.likedColor : Color.mainColor)
                .clipShape(Capsule())
                .shadow(color: (room.checked ? Color.likedColor : Color.mainColor).opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(room.checked)
        }
        .padding(20)
        .background(Color.secondaryBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private var likePopupView: some View {
        VStack(alignment: .center, spacing: 12) {
            LottieView(animation: .named("like"))
                .playbackMode(.playing(.toProgress(1.0, loopMode: .playOnce)))
                .frame(width: 80, height: 80)
            
            Text("いいねしました！")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black.opacity(0.7))
        }
        .padding(25)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

fileprivate struct MakeVoiceChatRoomView: View {
    @EnvironmentObject private var voiceChatViewModel: VoiceChatViewModel
    
    @Binding var isShowMakeRoomView: Bool
    @Binding var isShowVoiceChatRoomButton: Bool
    
    @State private var message: String = ""
    @State private var expiresDateIsOn: Bool = false
    @State private var expiresDate: Date = .now
    @State private var notificationIsOn: Bool = true
    @State private var isShowSubscribeAlert: Bool = false
    @State private var isShowRecruitmentAlert: Bool = false
    @State private var isShowMessageEmptyAlert: Bool = false
    
    @FocusState private var focus: Bool
    
    var body: some View {
        ZStack {
            Color.secondaryBackgroundColor.ignoresSafeArea()
            VStack(alignment: .center, spacing: 10) {
                headerView
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.thirdColor)
                            Text("メッセージ")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                        
                        TextField("今何してる？（最大5行）", text: $message, axis: .vertical)
                            .focused($focus)
                            .font(.system(size: 16, weight: .medium))
                            .lineLimit(5)
                            .padding(16)
                            .background(Color.white.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.thirdColor)
                                    Text("プッシュ通知")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.gray)
                                }
                                Text("いいねがついた時に通知します")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.gray.opacity(0.6))
                            }
                            Spacer()
                            Toggle("", isOn: $notificationIsOn)
                                .labelsHidden()
                                .tint(Color.thirdColor)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(20)
                
                Spacer()
                
                Button(action: {
                    guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            self.isShowMessageEmptyAlert = true
                        }
                        return
                    }
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.isShowVoiceChatRoomButton = false
                    }
                    
                    Task {
                        if let recruitment = await self.voiceChatViewModel.checkMadeRecruitment() {
                            if await self.voiceChatViewModel.checkSubscribed() {
                                let expiresDate = self.addExpiresDate()
                                self.voiceChatViewModel.makeVoiceChatRoom(message: message, expiresAt: expiresDate, recruitment: recruitment) {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        self.isShowVoiceChatRoomButton = true
                                    }
                                }
                                
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    self.isShowMakeRoomView.toggle()
                                }
                            } else {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    self.isShowSubscribeAlert.toggle()
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                self.isShowRecruitmentAlert.toggle()
                            }
                        }
                        
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            self.isShowVoiceChatRoomButton = true
                        }
                    }
                }) {
                    Text("この内容で作成する")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.thirdColor)
                        .clipShape(Capsule())
                        .shadow(color: Color.thirdColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 40)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 30)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onTapGesture {
            if focus {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.focus.toggle()
                }
            }
        }
        .alert("有料会員登録が必要です。", isPresented: $isShowSubscribeAlert) {
            Button("キャンセル", role: .cancel) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.isShowSubscribeAlert.toggle()
                }
            }
            Button("有料会員プランの確認", role: .none) {}
        } message: {
            Text("ボイスチャットを作成するには、有料会員の登録が必要です。")
        }
        .alert("ロケーションの募集を行う必要があります。", isPresented: $isShowRecruitmentAlert) {
            Button("OK", role: .cancel) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.isShowRecruitmentAlert.toggle()
                }
            }
        } message: {
            Text("ボイスチャットを作成するにはロケーションの募集を行う必要があります。")
        }
        .alert("メッセージを入力してください", isPresented: $isShowMessageEmptyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("ボイスチャットの内容を伝えるメッセージを入力してください。")
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .center) {
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.isShowMakeRoomView = false
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("ボイスチャット作成")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            Spacer()
            
            // Empty placeholder for balance
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private func addExpiresDate() -> Date {
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: expiresDate) {
            return tomorrow
        }
        
        return expiresDate
    }
}
