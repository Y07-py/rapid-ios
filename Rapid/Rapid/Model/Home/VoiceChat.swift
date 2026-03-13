//
//  VoiceChat.swift
//  Rapid
//
//  Created by 木本瑛介 on 2026/02/18.
//

import Foundation
import SwiftUI

public struct VoiceChatRoom: Identifiable, Codable {
    public var id: UUID = .init()
    public var userId: UUID
    public var createdAt: Date
    public var expiresAt: Date
    public var message: String
    public var recruitmentId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id = "room_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case message
        case recruitmentId = "recruitment_id"
    }
}

public struct FetchVoiceChatRoomParamater: Codable {
    public var userId: UUID
    public var pageOffset: Int
    public var pageLimit: Int
    public var filter: FetchVoiceChatRoomFilter?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case pageOffset = "page_offset"
        case pageLimit = "page_limit"
        case filter
    }
}

public struct FetchVoiceChatRoomFilter: Codable {
    public var fromAge: Int
    public var toAge: Int
    public var residence: FetchVoiceChatRoomResidence?
    public var radius: Int?
    
    enum CodingKeys: String, CodingKey {
        case fromAge = "from_age"
        case toAge = "to_age"
        case residence
        case radius
    }
}

public struct FetchVoiceChatRoomResidence: Codable {
    public var name: String
    public var latitude: Double
    public var longitude: Double
}

public struct VoiceChatRoomWithRecruitment: Codable {
    public var voiceChatRoom: VoiceChatRoom
    public var recruitment: RecruitmentWithRelations
    
    enum CodingKeys: String, CodingKey {
        case voiceChatRoom = "voice_chat_room"
        case recruitment
    }
}

public struct VoiceChatRoomWithUserProfile: Identifiable {
    public var id: UUID = .init()
    public var profile: RapidUserWithProfile
    public var voiceChatRoomWithRecruitment: VoiceChatRoomWithRecruitment
    public var places: [GooglePlacesSearchPlaceWrapper]
    public var checked: Bool = false
}

public struct LikeVoiceChatRoom: Codable {
    public var id: UUID = .init()
    public var userId: UUID
    public var roomId: UUID
    public var likedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case roomId = "room_id"
        case likedAt = "liked_at"
    }
}

public struct CallObject: Codable {
    let userId: UUID
    let payload: CallPayload
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case payload
    }
}

public struct CallPayload: Codable {
    let aps: Aps
    let callId: String
    let callerName: String
    let handle: String
    
    enum CodingKeys: String, CodingKey {
        case aps
        case callId = "call_id"
        case callerName = "caller_name"
        case handle
    }
    
    init(aps: Aps, callId: String, callerName: String, handle: String) {
        self.aps = aps
        self.callId = callId
        self.callerName = callerName
        self.handle = handle
    }
}

public struct Aps: Codable {
    let contentAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case contentAvailable = "content-available"
    }
}

public struct CityCoordinate: Identifiable, Codable {
    public var id = UUID()
    public var prefecture: String
    public var city: String
    public var longitude: Double
    public var latitude: Double
}
