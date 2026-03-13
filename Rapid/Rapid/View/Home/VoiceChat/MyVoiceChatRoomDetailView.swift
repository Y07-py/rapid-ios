//
//  MyVoiceChatRoomDetailView.swift
//  Rapid
//
//  Created by Antigravity on 2026/03/13.
//

import SwiftUI
import SDWebImageSwiftUI

struct MyVoiceChatRoomDetailView: View {
    @EnvironmentObject private var voiceChatViewModel: VoiceChatViewModel
    @Binding var isPresented: Bool
    
    @State private var isShowCancelAlert: Bool = false
    
    var body: some View {
        ZStack {
            // Background Layer
            Color.backgroundColor.ignoresSafeArea()
            
            // Decorative background glows
            VStack {
                Circle()
                    .fill(Color.mainColor.opacity(0.12))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(x: -160, y: -80)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Room Message Detail
                        if let room = voiceChatViewModel.currentUserVoiceChatRoom {
                            roomInfoSection(room: room)
                        } else {
                            emptyRoomView
                        }
                        
                        // Liked Users Section
                        likedUsersSection
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                }
                .scrollIndicators(.hidden)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            // Cancel Button at Bottom
            VStack {
                Spacer()
                cancelButtonView
            }
            .ignoresSafeArea(.keyboard)
        }
        .alert("チャットルームの削除", isPresented: $isShowCancelAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除する", role: .destructive) {
                // Internal logic is not implemented yet
                withAnimation {
                    self.isPresented = false
                }
            }
        } message: {
            Text("チャットルームを削除してもよろしいですか？この操作は取り消せません。")
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .center) {
            Button(action: {
                withAnimation {
                    self.isPresented = false
                }
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("ルーム管理")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black.opacity(0.8))
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private func roomInfoSection(room: VoiceChatRoomWithUserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("現在の募集内容")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.gray)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(room.voiceChatRoomWithRecruitment.voiceChatRoom.message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black.opacity(0.8))
                    .lineSpacing(4)
                
                HStack {
                    Label("\(formattedDate(room.voiceChatRoomWithRecruitment.voiceChatRoom.expiresAt))まで", systemImage: "clock")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.8))
                    
                    Spacer()
                    
                    Text("募集中")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.thirdColor)
                        .clipShape(Capsule())
                }
            }
            .padding(20)
            .background(Color.secondaryBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
        }
    }
    
    @ViewBuilder
    private var likedUsersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("届いたいいね")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("\(voiceChatViewModel.likedVoiceChatRoomUsers.count)人")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.mainColor)
            }
            
            if voiceChatViewModel.likedVoiceChatRoomUsers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray.opacity(0.2))
                    Text("まだいいねはありません")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.secondaryBackgroundColor.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: 12) {
                    ForEach(voiceChatViewModel.likedVoiceChatRoomUsers) { profile in
                        likedUserRow(profile: profile)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func likedUserRow(profile: RapidUserWithProfile) -> some View {
        HStack(spacing: 12) {
            if let photo = profile.profileImages.first {
                WebImage(url: photo.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().foregroundStyle(.gray.opacity(0.1))
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.user.userName ?? "No Name")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                Text("\(profile.user.birthDate?.computeAge() ?? 0)歳 • \(profile.user.residence ?? "未設定")")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.gray.opacity(0.3))
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.01), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var emptyRoomView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash")
                .font(.system(size: 40))
                .foregroundStyle(.gray.opacity(0.2))
            Text("有効なルームがありません")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    @ViewBuilder
    private var cancelButtonView: some View {
        Button(action: {
            self.isShowCancelAlert = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("チャットルームを削除")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.red.opacity(0.8))
            .clipShape(Capsule())
            .shadow(color: Color.red.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 40)
            .padding(.bottom, 25)
        }
        .buttonStyle(.plain)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: date)
    }
}
