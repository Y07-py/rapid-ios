//
//  VoiceChatViewModel.swift
//  Rapid
//
//  Created by 木本瑛介 on 2026/02/18.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

public class VoiceChatViewModel: ObservableObject {
    private let logger = Logger.shared
    private let supabase = SupabaseManager.shared
    private let http: HttpClient = {
        let client = HttpClient(auth: HttpSupabaseAuthenticator(), retryPolicy: .exponentialBackoff(3, 4.5))
        return client
    }()
    
    @Published var voiceChatRooms: [VoiceChatRoomWithUserProfile] = []
    @Published var selectedVoiceChatRoom: VoiceChatRoomWithUserProfile? = nil
    @Published var likedVoiceChatRoomUsers: [RapidUserWithProfile] = []
    @Published var receivedLikedUsers: [RapidUserWithProfile] = []
    @Published var currentUserVoiceChatRoom: VoiceChatRoomWithUserProfile? = nil
    @Published var nearestTransports: [GooglePlacesTransport] = []
    @Published var isLoadingNearestTransports: Bool = false
    @Published var cityCoordinates: [CityCoordinate] = []
    @Published var voiceChatFilter: FetchVoiceChatRoomFilter? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var isDataLoaded = false
    
    public var uniquePrefectures: [String] {
        let prefs = Array(Set(cityCoordinates.map { $0.prefecture })).sorted()
        return ["未設定"] + prefs
    }

    
    init() {
        self.loadCityCoordinates()
        
        // Monitor network connection and fetch data when established
        NetworkMonitor.shared.$isRealInternetReachable
            .filter { $0 && !self.isDataLoaded }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.startNetworkInitialization()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.addObserver(forName: .receiveLikedVoiceChatRoomNotification, object: nil, queue: .main) { notification in
            if let userId = notification.userInfo?["user_id"] as? String {
                Task { @MainActor in
                    self.insertLikedUser(userId: userId)
                }
            }
        }
    }
    
    @MainActor
    private func startNetworkInitialization() async {
        self.voiceChatRooms = await self.fetchVoiceChatRoom(offset: 0)
        self.fetchLikedUserToVoiceChatRoom()
        self.fetchCurrentUserVoiceChatRoom()
        self.isDataLoaded = true
    }
}

extension VoiceChatViewModel {
    @MainActor
    public func checkSubscribed() async -> Bool {
        do {
            return try await self.supabase.checkSubscribed()
        } catch let error {
            self.logger.error("❌ Failed to check whether subscriebed: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    public func checkMadeRecruitment() async -> Recruitment? {
        do {
            return try await self.supabase.checkMadeRecruitment()
        } catch let error {
            self.logger.error("❌ Failed to check whether made recruitment: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    public func makeVoiceChatRoom(message: String, expiresAt: Date, recruitment: Recruitment, completion: @escaping () -> Void) {
        Task {
            guard let session = await self.supabase.getSession() else { return }
            
            let voiceChatRoom = VoiceChatRoom(
                userId: session.user.id,
                createdAt: .now,
                expiresAt: expiresAt,
                message: message,
                recruitmentId: recruitment.id
            )
            
            do {
                let response = try await self.http.post(url: .makeVoiceChatRoom, content: voiceChatRoom)
                if response.ok {
                    completion()
                    self.logger.info("✅ Successfully to make voice chat room.")
                }
            } catch let error {
                if let error = error as? HttpError {
                    self.logger.error("❌ Failed to make voice chat room: \(error.errorDescription)")
                }
            }
        }
    }
    
    @MainActor
    public func fetchVoiceChatRoom(offset: Int) async -> [VoiceChatRoomWithUserProfile] {
        guard let session = await self.supabase.getSession() else { return [] }
        let param = FetchVoiceChatRoomParamater(
            userId: session.user.id,
            pageOffset: offset,
            pageLimit: 10,
            filter: self.voiceChatFilter
        )
        
        do {
            let response = try await self.http.post(url: .fetchVoiceChatRoom, content: param)
            if response.ok {
                let voiceChatRooms: [VoiceChatRoomWithRecruitment]? = try response.decode(dateDecodingStrategy: .tolerantISO8601)
                if let voiceChatRooms = voiceChatRooms {
                    return try await withThrowingTaskGroup(of: (VoiceChatRoomWithUserProfile?).self) { group in
                        var voiceChatRoomWithProfiles: [VoiceChatRoomWithUserProfile] = []
                        for room in voiceChatRooms {
                            group.addTask {
                                guard let userId = room.recruitment.userId else { return nil }
                                let userWithProfile = try await self.supabase.fetchUserWithProfile(userId: userId)
                                let placeIds = room.recruitment.recruitmentPlaces?.compactMap({ $0.placeId })
                                let places = await self.fetchPlaceDetail(placeIds: placeIds)
                                
                                let liked = try await self.supabase.checkLikedVoiceChatRoom(roomId: room.voiceChatRoom.id)
                                
                                return VoiceChatRoomWithUserProfile(
                                    profile: userWithProfile,
                                    voiceChatRoomWithRecruitment: room,
                                    places: places,
                                    checked: liked
                                )
                            }
                        }
                        
                        for try await roomWithProfile in group {
                            if let roomWithProfile = roomWithProfile {
                                voiceChatRoomWithProfiles.append(roomWithProfile)
                            }
                        }
                        
                        return voiceChatRoomWithProfiles
                    }
                } else {
                    self.logger.warning("⚠️ return object is nil.")
                }
            }
        } catch let error {
            if let error = error as? HttpError {
                self.logger.error("❌ Failed to fetch voice chat room. \(error.errorDescription)")
            } else {
                self.logger.error("❌ Failed to decode voice chat room: \(error.localizedDescription)")
            }
        }
        
        return []
    }
    
    private func fetchPlaceDetail(placeIds: [String]?) async -> [GooglePlacesSearchPlaceWrapper] {
        guard let placeIds = placeIds else { return [] }
        let fieldMask = GooglePlaceFieldMask.detailFieldMask.map({ $0.rawValue }).joined(separator: ",")
        let param = GooglePlacesPlaceDetailBodyParamater(fieldMask: fieldMask, placeIds: placeIds, languageCode: "ja")
        
        do {
            let response = try await self.http.post(url: .getPlaceDetails, content: param)
            if response.ok {
                let places: [GooglePlacesSearchResponsePlace] = try response.decode()
                return places.map({ GooglePlacesSearchPlaceWrapper(place: $0) })
            }
        } catch let error {
            if let error = error as? HttpError {
                self.logger.error("❌ Failed to fetch places details: \(error.errorDescription)")
            } else {
                self.logger.error("❌ Failed to decode place details: \(error.localizedDescription)")
            }
        }
        
        return []
    }
    
    @MainActor
    public func fetchMBTIThumbnailURL(mbti: String) async -> URL? {
        do {
            let folderPath = "thumbnails/\(mbti).png"
            let thumbnailURL: URL = try await supabase.getSinglePresignURLFromStorage(bucket: "mbti", path: folderPath)
            return thumbnailURL
        } catch let error {
            logger.error("❌ Failed to fetch mbti thumbnail url from supabase. \(error.localizedDescription)")
        }
        
        return nil
    }
    
    @MainActor
    public func fetchLikedUserToVoiceChatRoom() {
        Task {
            do {
                let likedUsers = try await self.supabase.selectLikedUserToVoiceChatRoom()
                let users: [RapidUserWithProfile] = try await withThrowingTaskGroup(of: RapidUserWithProfile.self) { group in
                    var users: [RapidUserWithProfile] = []
                    for liked in likedUsers {
                        group.addTask {
                            let userWithProfile = try await self.supabase.fetchUserWithProfile(userId: liked.userId)
                            return userWithProfile
                        }
                    }
                    
                    for try await userWithProfile in group {
                        users.append(userWithProfile)
                    }
                    
                    return users
                }
                
                self.likedVoiceChatRoomUsers = users
            } catch let error {
                self.logger.error("❌ Failed to fetch liked users. \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    public func fetchCurrentUserVoiceChatRoom() {
        Task {
            guard let session = await self.supabase.getSession() else { return }
            do {
                if let voiceChatRoom = try await self.supabase.selectVoiceChatRoom(userId: session.user.id) {
                    let recruitmentWithRelations = await self.supabase.selectRecruitment(recruitmentId: voiceChatRoom.recruitmentId)
                    guard let recruitment = recruitmentWithRelations?.first, let placeInfo = recruitment.recruitmentPlaces else { return }
                    let placeIds = placeInfo.compactMap({ $0.placeId })
                    let places = await self.fetchPlaceDetail(placeIds: placeIds)
                    let user = try await self.supabase.fetchUserWithProfile(userId: session.user.id)
                    let voiceChatRoomWithRecruitment = VoiceChatRoomWithRecruitment(voiceChatRoom: voiceChatRoom, recruitment: recruitment)
                    
                    self.currentUserVoiceChatRoom = .init(profile: user, voiceChatRoomWithRecruitment: voiceChatRoomWithRecruitment, places: places)
                }
            } catch let error {
                self.logger.error("❌ Failed to fetch voice chat room. \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - Send like to voice chat room
    @MainActor
    public func sendLikeToVoiceChatRoom(room: VoiceChatRoomWithUserProfile) {
        Task {
            guard let session = await self.supabase.getSession() else { return }
            let payload = LikeVoiceChatRoom(
                userId: session.user.id,
                roomId: room.voiceChatRoomWithRecruitment.voiceChatRoom.id,
                likedAt: .now
            )
            
            do {
                let response = try await self.http.post(url: .sendLikeToVoiceChatRoom, content: payload)
                if response.ok {
                    guard let idx = self.voiceChatRooms.firstIndex(where: { $0.id == room.id }) else { return }
                    
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.voiceChatRooms[idx].checked = true
                    }
                }
            } catch let error {
                if let error = error as? HttpError {
                    self.logger.error("❌ Failed to send like voice chat room. \(error.errorDescription)")
                } else {
                    self.logger.error("❌ Failed to send like voice chat room: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Received liked message.
    @MainActor
    private func insertLikedUser(userId: String) {
        Task {
            guard let userId = UUID(uuidString: userId) else { return }
            
            do {
                let userWithProfile = try await self.supabase.fetchUserWithProfile(userId: userId)
                guard !self.likedVoiceChatRoomUsers.contains(where: { $0.user.id == userWithProfile.user.id }) else { return }
                self.likedVoiceChatRoomUsers.append(userWithProfile)
                self.receivedLikedUsers.append(userWithProfile)
            } catch let error {
                self.logger.error("❌ Failed to insert liked user. \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    public func allRemoveReceicedLikedUser() {
        self.receivedLikedUsers.removeAll()
    }
    
    @MainActor
    public func sendCallMessage(
        profile: RapidUserWithProfile,
        completion: @escaping (_ client: SignalingClient?, _ callId: String, _ clientId: String) -> Void
    ) {
        Task {
            guard let session = await self.supabase.getSession() else { return }
            let callId = UUID().uuidString.lowercased()
            let callPayload = CallPayload(
                aps: .init(contentAvailable: 1),
                callId: callId,
                callerName: profile.user.userName ?? "No Name",
                handle: profile.user.id.uuidString.lowercased()
            )
            let callObject = CallObject(userId: session.user.id, payload: callPayload)
            
            do {
                let response = try await self.http.post(url: .sendCallMessage, content: callObject)
                if response.ok {
                    let client = self.makeSignalingClient(callId: callId)
                    completion(client, callId, session.user.id.uuidString.lowercased())
                }
            } catch let error {
                if let error = error as? HttpError {
                    self.logger.error("❌ Failed to send call message: \(error.errorDescription)")
                }
            }
        }
    }
    
    private func makeSignalingClient(callId: String) -> SignalingClient? {
        guard let currentUserVoiceChatRoom = self.currentUserVoiceChatRoom else { return nil }
        let provider = SupabaseRealtimeProvider(callId: callId)
        let client = SignalingClient(
            clientId: currentUserVoiceChatRoom.profile.user.id.uuidString.lowercased(),
            webSocket: provider
        )
        
        return client
    }
    
    @MainActor
    public func updateNearestTransport(wrapper: GooglePlacesSearchPlaceWrapper) async {
        self.isLoadingNearestTransports = true
        defer { self.isLoadingNearestTransports = false }
        
        self.nearestTransports.removeAll()
        guard let place = wrapper.place,

              let latitude = place.location?.latitude,
              let longitude = place.location?.longitude else { return }
        
        let placeTypes: [GooglePlaceType] = [.trainStation, .subwayStation, .busStation, .airport, .ferryTerminal]
        let fieldMask: [GooglePlaceFieldMask] = [.id, .displayName, .location, .types]
        
        let body = GooglePlacesNearbySearchBodyParamater(
            includedTypes: placeTypes,
            maxResultCount: 10,
            languageCode: "ja",
            rankPreference: "DISTANCE",
            locationRestriction: .init(circle: .init(latitude: latitude, longitude: longitude, radius: 1000))
        )
        
        let fieldMaskString = fieldMask.map({ "places.\($0.rawValue)" }).joined(separator: ",")
        
        // Use a dummy window size for client paramater
        let clientParam = PlaceSearchClientParamater(
            latitude: latitude,
            longitude: longitude,
            zoom: 13,
            windowSize: CGSize(width: 375, height: 812), // iPhone 13 dummy size
            scale: 3.0
        )
        
        let param = GooglePlacesNearbySearchParamater(requestParamater: body, fieldMask: fieldMaskString, clientParamater: clientParam)
        
        do {
            let response = try await http.post(url: .searchNearbyTransports, content: param)
            if response.ok {
                let places: [GooglePlacesSearchResponsePlace] = try response.decode()
                let transports = places.compactMap({ place in
                    if let lat = place.location?.latitude,
                       let lon = place.location?.longitude {
                        let d = self.computeDistance(lat1: latitude, lon1: longitude, lat2: lat, lon2: lon)
                        return GooglePlacesTransport(l2Distance: d, place: place)
                    }
                    return nil
                })
                self.nearestTransports = transports
            }
        } catch let error {
            self.logger.error("❌ Failed to fetch nearest transports: \(error.localizedDescription)")
        }
    }
    
    private func computeDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let rLat1 = lat1 * .pi / 180.0
        let rLon1 = lon1 * .pi / 180.0
        let rLat2 = lat2 * .pi / 180.0
        let rLon2 = lon2 * .pi / 180.0
        
        let a: Double = .GRS80_EQUATION_RADIUS
        let b: Double = .GRS80_SHORT_RADIUS
        
        let e2 = (pow(a, 2) - pow(b, 2)) / pow(a, 2)
        
        let dLat = rLat1 - rLat2
        let dLon = rLon1 - rLon2
        let latAve = (rLat1 + rLat2) / 2.0
        
        let sinLat = sin(latAve)
        let w = sqrt(1.0 - e2 * pow(sinLat, 2))
        
        let m = a * (1.0 - e2) / pow(w, 3)
        let n = a / w
        
        let d = sqrt(pow(dLat * m, 2) + pow(dLon * n * cos(latAve), 2))
        
        return d
    }
    
    private func loadCityCoordinates() {
        guard let url = Bundle.main.url(forResource: "prefecture_cities_coordinates", withExtension: "csv") else {
            self.logger.error("❌ Failed to find csv file.")
            return
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            var coordinates: [CityCoordinate] = []
            for (index, line) in lines.enumerated() {
                if index == 0 || line.isEmpty { continue }
                
                let columns = line.components(separatedBy: ",")
                if columns.count >= 4 {
                    let pref = columns[0]
                    let city = columns[1]
                    if let lon = Double(columns[2]), let lat = Double(columns[3]) {
                        coordinates.append(CityCoordinate(prefecture: pref, city: city, longitude: lon, latitude: lat))
                    }
                }
            }
            self.cityCoordinates = coordinates
            self.logger.info("✅ Successfully loaded \(coordinates.count) city coordinates.")
        } catch let error {
            self.logger.error("❌ Failed to load csv file: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func applyFilter(fromAge: Int, toAge: Int, prefecture: String, radius: Int?, useDistance: Bool) {
        var residenceModel: FetchVoiceChatRoomResidence? = nil
        
        if prefecture != "未設定" {
            if let cityCoord = cityCoordinates.first(where: { $0.prefecture == prefecture }) {
                residenceModel = FetchVoiceChatRoomResidence(
                    name: prefecture,
                    latitude: cityCoord.latitude,
                    longitude: cityCoord.longitude
                )
            }
        }
        
        let filter = FetchVoiceChatRoomFilter(
            fromAge: fromAge,
            toAge: toAge,
            residence: residenceModel,
            radius: useDistance ? radius : nil
        )
        
        self.voiceChatFilter = filter
        
        Task {
            self.voiceChatRooms = await self.fetchVoiceChatRoom(offset: 0)
        }
    }
}
