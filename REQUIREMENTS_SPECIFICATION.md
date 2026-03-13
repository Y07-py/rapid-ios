# Rapid iOS Application - Requirements Specification Document

## 1. Overview

**Application Name:** Rapid
**Platform:** iOS (SwiftUI + UIKit)
**Architecture:** MVVM (Model-View-ViewModel)
**Backend:** Supabase (BaaS)

Rapid is a matchmaking/event recruitment mobile application that enables users to create and discover activities, communicate via real-time chat, and engage in real-time voice calls through a recruitment-based "Voice Chat" system.

---

## 2. System Architecture

### 2.1 High-Level Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          RapidApp (Entry Point)                      │
│                               │                                      │
│                          ContentView                                 │
│                               │                                      │
│              ┌────────────────┴────────────────┐                    │
│              │                                 │                    │
│         LoginRootView                    HomeRootView               │
│              │                                 │                    │
│    Profile Setup Flow              ┌──────────┼──────────┐         │
│                                    │          │          │         │
│                              Recruitment   Chat     Profile        │
│                                    │          │          │         │
│                              Location     ChatRoom   Settings      │
│                              Selection    VoiceChat  Editing       │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
               ViewModel        Services        Models
                    │               │               │
               ┌─────┴─────┐   ┌─────┴─────┐   ┌─────┴─────┐
               │ Login     │   │ Supabase  │   │ User      │
               │ Profile   │   │ HTTP      │   │ Chat      │
               │ Chat      │   │ WebRTC    │   │ Recruit   │
               │ VoiceChat │   │ Cache     │   │ VoiceChat │
               └───────────┘   └───────────┘   └───────────┘
```

---

## 3. Functional Requirements

### 3.1 Authentication Module (FR-AUTH)

| ID | Requirement | Components |
|----|-------------|------------|
| FR-AUTH-01 | The system shall support email OTP authentication | `LoginView`, `LoginVerifyView`, `LoginViewModel`, `SupabaseManager` |
| FR-AUTH-02 | The system shall support phone number OTP authentication | `LoginView`, `LoginVerifyView`, `LoginViewModel`, `PhoneNumberKit` |
| FR-AUTH-03 | The system shall support Google Sign-In | `LoginViewModel`, `GoogleSignIn`, `SupabaseManager` |
| FR-AUTH-04 | The system shall support Apple Sign-In | `LoginViewModel`, `AuthenticationServices`, `SupabaseManager` |
| FR-AUTH-05 | The system shall support LINE Sign-In | `LoginViewModel`, `LineSDK`, `SupabaseManager` |
| FR-AUTH-06 | The system shall persist user session across app restarts | `ContentViewModel`, `SupabaseManager`, `CoreData` |

### 3.2 User Profile Module (FR-PROFILE)

| ID | Requirement | Components |
|----|-------------|------------|
| FR-PROFILE-01 | Users shall be able to set profile images (up to 6) | `ProfileImageSettingView`, `ProfileViewModel`, `PickerCrop` |
| FR-PROFILE-02 | Users shall be able to set username | `UserNameLoginSettingView`, `ProfileViewModel` |
| FR-PROFILE-03 | Users shall be able to set birthday | `BirthdayLoginSettingView`, `ProfileViewModel` |
| FR-PROFILE-04 | Users shall be able to set height | `HeightLoginSettingView`, `ProfileViewModel` |
| FR-PROFILE-05 | Users shall be able to set living location (prefecture/city) | `LivingLoginSettingView`, `ProfileViewModel` |
| FR-PROFILE-06 | Users shall be able to set profession | `ProfessionSettingView`, `ProfileViewModel`, `Profession.swift` |
| FR-PROFILE-07 | Users shall be able to set annual income | `AnnualIncomeSettingView`, `ProfileViewModel`, `Income.swift` |
| FR-PROFILE-08 | Users shall be able to set blood type | `BloodTypeSettingView`, `ProfileViewModel`, `BloodType.swift` |
| FR-PROFILE-09 | Users shall be able to set smoking habits | `SmokingSettingView`, `ProfileViewModel`, `Smoking.swift` |
| FR-PROFILE-10 | Users shall be able to set drinking habits | `DrinkingSettingView`, `ProfileViewModel`, `Drinking.swift` |
| FR-PROFILE-11 | Users shall be able to set child status | `ChildStatusSettingView`, `ProfileViewModel`, `ChildStatus.swift` |
| FR-PROFILE-12 | Users shall be able to set academic background | `AcademicBackgroundSettingView`, `ProfileViewModel`, `AcademicBackground.swift` |
| FR-PROFILE-13 | Users shall be able to set self-introduction | `IntroductionSettingView`, `ProfileViewModel` |
| FR-PROFILE-14 | Users shall be able to set keyword tags | `KeyWordTagSettingView`, `ProfileViewModel`, `KeywordTag.swift` |
| FR-PROFILE-15 | Users shall be able to set matching purpose | `MatchingPurposeSettingView`, `ProfileViewModel`, `MatchingPurpose.swift` |
| FR-PROFILE-16 | Users shall be able to edit profile after initial setup | `ProfileEditingView`, `ProfileSettingView`, `ProfileViewModel` |
| FR-PROFILE-17 | Users shall be able to view point purchase history | `ProfileSettingPointPurchaseHistoryView` |
| FR-PROFILE-18 | Users shall be able to manage paid subscription plans | `ProfileSettingSubscriptionPurchaseView` |
| FR-PROFILE-19 | Users shall be able to set and display MBTI personality types | `ProfileViewModel`, `VoiceChatDetailView` |
| FR-PROFILE-20 | Users shall be able to view community guidelines and terms | `CommunityGuidelineView`, `LegalTermsView` |

### 3.3 Recruitment Module (FR-RECRUIT)

| ID | Requirement | Components |
|----|-------------|------------|
| FR-RECRUIT-01 | Users shall be able to browse recruitment posts | `RecruitmentView`, `RecruitmentRootView` |
| FR-RECRUIT-02 | Users shall be able to create recruitment posts | `RecruitmentEditorView`, `RecruitmentEditorRootView`, `MakeRecruitmentViewModel` |
| FR-RECRUIT-03 | Users shall be able to select location via map | `LocationSelectView`, `GMSMapViewRepresentable`, `MakeRecruitmentViewModel` |
| FR-RECRUIT-04 | Users shall be able to search locations (Google Places/Yahoo) | `LocationCandidateView`, `Place.swift`, `YahooLocationSearch.swift` |
| FR-RECRUIT-05 | Users shall be able to filter recruitments by area | `SearchFilterAreaView`, `SearchFilterRootView` |
| FR-RECRUIT-06 | Users shall be able to filter recruitments by date | `SearchFilterCalendarView`, `SearchFilterRootView` |
| FR-RECRUIT-07 | Users shall be able to filter recruitments by category | `SearchFilterCategoryView`, `SearchFilterRootView` |
| FR-RECRUIT-08 | Users shall be able to send messages for recruitment | `RecruitMessageView` |

### 3.4 Chat Module (FR-CHAT)

| ID | Requirement | Components |
|----|-------------|------------|
| FR-CHAT-01 | Users shall be able to view chat list | `ChatListView`, `ChatView`, `ChatViewModel` |
| FR-CHAT-02 | Users shall be able to send text and image messages | `ChatRoomView`, `ChatViewModel`, `SupabaseManager` |
| FR-CHAT-03 | Users shall be able to send image messages | `ChatRoomView`, `ChatViewModel`, `SupabaseManager` |
| FR-CHAT-04 | Users shall receive real-time message updates | `ChatViewModel`, `SupabaseManager` (Realtime), `ChatRoom.swift` |
| FR-CHAT-05 | Users shall be able to view likes received | `LikeListView`, `ChatViewModel`, `LikerModel.swift` |
| FR-CHAT-06 | System shall notify users of new messages | `NotificationCenter`, `receiveMessageNotification` |
| FR-CHAT-07 | Users shall be able to view detailed location info within chat | `ChatRoomLocationDetailView`, `ChatRoomLocationListView` |
| FR-CHAT-08 | Users shall be able to report inappropriate users or messages | `ChatRoomReportReasonView` |

### 3.5 Voice Chat Module (FR-VOICE)

| ID | Requirement | Components |
|----|-------------|------------|
| FR-VOICE-01 | Users shall be able to browse voice chat recruitment posts | `VoiceChatView`, `VoiceChatViewModel` |
| FR-VOICE-02 | Users shall be able to create voice chat recruitment (Requires subscription) | `MakeVoiceChatRoomView`, `VoiceChatViewModel` |
| FR-VOICE-03 | Users shall be able to send "Likes" to voice chat recruiters | `VoiceChatView`, `VoiceChatViewModel` |
| FR-VOICE-04 | Users shall be able to filter voice chat posts by area and age | `VoiceChatFilterView`, `VoiceChatViewModel` |
| FR-VOICE-05 | Users shall be able to initiate/receive voice calls using WebRTC | `VoiceChatCallView`, `WebRTCClient`, `VideoCallViewModel` |
| FR-VOICE-06 | Users shall be able to view remaining call time during a call | `VoiceChatCallView`, `VideoCallViewModel` |

---

## 4. Component Relationships

### 4.1 View-ViewModel Relationships

```
┌──────────────────────────────────────────────────────────────────┐
│                         View Layer                                │
├──────────────────────────────────────────────────────────────────┤
│ ContentView ──────────────────────► ContentViewModel             │
│ LoginView/LoginVerifyView ────────► LoginViewModel               │
│ Profile*SettingView ──────────────► ProfileViewModel             │
│ VoiceChatView/VoiceChatDetailView ─► VoiceChatViewModel           │
│ VoiceChatCallView ────────────────► VideoCallViewModel           │
│ ChatListView/ChatRoomView ────────► ChatViewModel/ChatRoomViewModel │
│ RecruitmentEditorView ────────────► MakeRecruitmentViewModel     │
└──────────────────────────────────────────────────────────────────┘
```

### 4.2 ViewModel-Service Relationships

```
┌──────────────────────────────────────────────────────────────────┐
│                       ViewModel Layer                             │
├──────────────────────────────────────────────────────────────────┤
│ ContentViewModel                                                  │
│   └─► SupabaseManager (session check)                            │
│                                                                   │
│ LoginViewModel                                                    │
│   ├─► SupabaseManager (OTP, social auth)                         │
│   ├─► GoogleSignIn                                                │
│   └─► LineSDK                                                     │
│                                                                   │
│ ProfileViewModel                                                  │
│   ├─► SupabaseManager (profile CRUD, image upload)               │
│   └─► HttpClient2 (external API calls)                           │
│                                                                   │
│ ChatViewModel                                                     │
│   ├─► SupabaseManager (messages, realtime subscriptions)         │
│   ├─► SignalingClient (WebRTC signaling)                         │
│   └─► WebRTCClient (peer connection)                             │
│                                                                   │
│ MakeRecruitmentViewModel                                          │
│   ├─► SupabaseManager (recruitment CRUD)                         │
│   ├─► HttpClient2 (FourSquare API, Google Places API)            │
│   └─► YahooLocationSearch                                         │
│                                                                   │
│ VoiceChatViewModel                                                │
│   ├─► SupabaseManager (Voice chat CRUD, Likes)                   │
│   └─► HttpClient2 (Location details for voice chat)              │
│                                                                   │
│ VideoCallViewModel (Voice Focus)                                  │
│   ├─► SignalingClient (WebRTC signaling via Supabase)            │
│   └─► WebRTCClient (Audio-only peer connection)                   │
│                                                                   │
│ ChatRoomViewModel                                                 │
│   ├─► SupabaseManager (Messages, Realtime)                       │
│   └─► HttpClient2 (Google Places API for shared spots)           │
└──────────────────────────────────────────────────────────────────┘
```

### 4.3 Service-Model Relationships

```
┌──────────────────────────────────────────────────────────────────┐
│                       Service Layer                               │
├──────────────────────────────────────────────────────────────────┤
│ SupabaseManager                                                   │
│   ├─► UserModel, RapidUser, UserProfile                          │
│   ├─► ChatMessage, ChatRoom                                       │
│   ├─► RecruitmentModel                                            │
│   ├─► LikerModel, LikerUserId                                    │
│   ├─► DeviceToken                                                 │
│   └─► SupabaseSubscription                                        │
│                                                                   │
│ HttpClient2                                                       │
│   ├─► FourSquareRequestParams, FourSquare response models        │
│   ├─► GooglePlaces* models                                        │
│   └─► YahooLocationSearch models                                  │
│                                                                   │
│ WebRTCClient                                                      │
│   ├─► SessionDescription                                          │
│   ├─► IceCandidate                                                │
│   └─► GreetMessage, BroadcastMessage                             │
│                                                                   │
│ CoreData                                                          │
│   ├─► HttpCacheEntity                                             │
│   ├─► LikerIdEntity                                               │
│   ├─► MatchEntity                                                 │
│   └─► SupabaseSubscriptionEntity                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 4.4 Navigation Flow Relationships

```
┌──────────────────────────────────────────────────────────────────┐
│                     Navigation Layer                              │
├──────────────────────────────────────────────────────────────────┤
│ RootViewModel<MainRoot>                                           │
│   ├─► .login ──► LoginRootView                                   │
│   └─► .home ───► HomeRootView                                    │
│                                                                   │
│ RootViewModel<LoginRoot>                                          │
│   ├─► .login ──────────► LoginView                               │
│   ├─► .verify ─────────► LoginVerifyView                         │
│   └─► .profileSetting ─► ProfileLoginSettingRootView             │
│                           └─► Sequential profile setup screens   │
│                                                                   │
│ RootViewModel<HomeRoot>                                           │
│   ├─► .home ─────► HomeView (TabView)                            │
│   │                 ├─► RecruitmentRootView                      │
│   │                 ├─► MakeRecruitmentRootView                  │
│   │                 ├─► ChatView                                  │
│   │                 └─► ProfileRootView                          │
│   ├─► .chatRoom ─► ChatRoomView                                  │
│   ├─► .setting ──► ProfileSettingView                            │
│   └─► .editing ──► ProfileEditingView                            │
└──────────────────────────────────────────────────────────────────┘
```

---

## 5. Data Flow Specifications

### 5.1 Voice Call Signaling Flow

```
Caller                                        Callee
   │                                             │
   ▼                                             │
WebRTCClient.offer()                             │
   │                                             │
   ▼                                             │
SignalingClient.send(offer)                      │
   │                                             │
   ▼                                             │
Supabase Realtime ────────────────────────────► Receive offer
   │                                             │
   │                                             ▼
   │                                     Call UI Notification
   │                                             │
   │                                             ▼
   │                                     WebRTCClient.answer()
   │                                             │
   │                                             ▼
   ◄───────────────────────────────────── SignalingClient.send(answer)
   │
Establish P2P Audio Connection (ICE Exchange)
   │
   ▼
VoiceChatCallView (Both parties)
```

---

## 6. Non-Functional Requirements

### 6.1 Performance (NFR-PERF)

| ID | Requirement | Implementation |
|----|-------------|----------------|
| NFR-PERF-01 | Image thumbnails shall be cached | `ThumbnailCache`, `ImagePrewarmer` |
| NFR-PERF-02 | HTTP responses shall be cached with expiration | `HttpCacheManager`, `HttpCacheEntity` |
| NFR-PERF-03 | Large result sets shall use pagination | `SupabaseManager` (structured pagination) |
| NFR-PERF-04 | Parallel operations shall use Task groups | `async/await`, `TaskGroup` |

### 6.2 Security (NFR-SEC)

| ID | Requirement | Implementation |
|----|-------------|----------------|
| NFR-SEC-01 | API keys shall be stored in configuration files | `Info.plist`, `Auth0.plist`, `GoogleService-Info.plist` |
| NFR-SEC-02 | Image URLs shall use signed URLs with expiration | `SupabaseManager.signedUrl()` (24-hour expiration) |
| NFR-SEC-03 | Authentication tokens shall be managed securely | `SupabaseManager`, JWT tokens |
| NFR-SEC-04 | User access to Voice recruitment shall be restricted by subscription status | `VoiceChatViewModel.checkSubscribed()` |

### 6.3 Reliability (NFR-REL)

| ID | Requirement | Implementation |
|----|-------------|----------------|
| NFR-REL-01 | HTTP requests shall support automatic retry | `HttpRetryPolicy` (exponential backoff) |
| NFR-REL-02 | Real-time connections shall reconnect automatically | `SupabaseManager` (Realtime subscriptions) |
| NFR-REL-03 | Errors shall be logged with context | `Logging.swift`, `OSLog` |

---

## 7. External Dependencies

### 7.1 Third-Party Services

| Service | Purpose | Components |
|---------|---------|------------|
| Supabase | Backend (Auth, DB, Storage, Realtime) | `SupabaseManager` |
| Google Maps | Map display | `GMSMapViewRepresentable` |
| Google Places | Location search & details | `Place.swift`, `ChatRoomViewModel` |
| Yahoo Location | Japan-specific location search | `YahooLocationSearch.swift` |

### 7.2 Third-Party Libraries

| Library | Purpose | Components |
|---------|---------|------------|
| GoogleWebRTC | Video calling | `WebRTCClient` |
| GoogleSignIn | Social authentication | `LoginViewModel` |
| LineSDK | LINE social authentication | `LoginViewModel` |
| PhoneNumberKit | Phone validation | `LoginViewModel` |
| SDWebImage | Async image loading | Various Views |
| PopupView | Toast notifications | Various Views |

---

## 8. Data Models Summary

### 8.1 Core Entities

| Entity | Purpose | Key Fields |
|--------|---------|------------|
| `VoiceChatRoom` | Voice recruitment post | room_id, user_id, message, recruitment_id, expires_at |
| `LikeVoiceChatRoom`| "Like" for voice chat | id, user_id, room_id, liked_at |
| `RecruitmentModel` | Activity post | id, user_id, location, date, category |
| `ChatMessage` | Chat message | id, room_id, sender_id, content, type |

### 8.2 Supporting Entities

| Entity | Purpose |
|--------|---------|
| `SessionDescription` | WebRTC SDP for video calls |
| `IceCandidate` | WebRTC ICE candidate |
| `DeviceToken` | Push notification token |
| `Profession`, `Income`, `BloodType`, etc. | Profile attribute options |

---

## 9. File Structure Summary

```
ios/Rapid/
├── Rapid/
│   ├── Model/              # Data models
│   │   ├── Home/           # Chat, Recruitment, VoiceChat models
│   │   └── Supabase/       # Backend models
│   ├── View/               # SwiftUI views
│   │   ├── Home/           
│   │   │   ├── VoiceChat/  # Voice chat UI (New)
│   │   │   ├── Chat/       # Chat UI (Updated with Location Details)
│   │   │   ├── Profie/     # Profile & Settings UI (Updated)
│   │   │   └── Recruitment/# Recruitment UI
│   │   └── Login/          
│   ├── ViewModel/          # View models (Updated)
│   └── Library/            # Core services (Supabase, WebRTC, Http)
└── Podfile                 # Dependencies (WebRTC, SDWebImage, etc.)
```

---

## 10. Revision History

| Version | Date | Description |
|---------|------|-------------|
| 1.0 | 2026-01-25 | Initial specification |
| 1.1 | 2026-03-07 | Updated to reflect Voice Chat transition and current iOS UI structure |
