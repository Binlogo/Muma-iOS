//
//  Conversation.swift
//  Muma
//
//  Created by Binboy on 4/13/16.
//  Copyright © 2016 Binboy. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: Conversation

enum ConversationType: Int {
    case oneToOne   = 0 // 一对一对话
    case group      = 1 // 群组对话
    
    var nameForServer: String {
        switch self {
        case .oneToOne:
            return "User"
        case .group:
            return "Circle"
        }
    }
    
    var nameForBatchMarkAsRead: String {
        switch self {
        case .oneToOne:
            return "users"
        case .group:
            return "circles"
        }
    }
}

class Conversation: Object {
    
    var fakeID: String? {
        
        if isInvalidated {
            return nil
        }
        
        switch type {
        case ConversationType.oneToOne.rawValue:
            if let withFriend = withFriend {
                return "user" + withFriend.userID
            }
        case ConversationType.group.rawValue:
            if let withGroup = withGroup {
                return "group" + withGroup.groupID
            }
        default:
            return nil
        }
        
        return nil
    }
    
    var recipientID: String? {
        
        switch type {
        case ConversationType.oneToOne.rawValue:
            if let withFriend = withFriend {
                return withFriend.userID
            }
        case ConversationType.group.rawValue:
            if let withGroup = withGroup {
                return withGroup.groupID
            }
        default:
            return nil
        }
        
        return nil
    }
    
    //    var recipient: Recipient? {
    //
    //        if let recipientType = ConversationType(rawValue: type), recipientID = recipientID {
    //            return Recipient(type: recipientType, ID: recipientID)
    //        }
    //
    //        return nil
    //    }
    
    //    var mentionInitUsers: [UsernamePrefixMatchedUser] {
    //
    //        let userSet = Set<User>(messages.flatMap({ $0.fromFriend }).filter({ !$0.username.isEmpty && !$0.isMe }) ?? [])
    //
    //        let users = Array<User>(userSet).sort({ $0.lastSignInUnixTime > $1.lastSignInUnixTime }).map({ UsernamePrefixMatchedUser(userID: $0.userID, username: $0.username, nickname: $0.nickname, avatarURLString: $0.avatarURLString) })
    //
    //        return users
    //    }
    
    dynamic var type: Int = ConversationType.oneToOne.rawValue
    dynamic var updatedUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    dynamic var withFriend: User?
    dynamic var withGroup: Group?
    
    dynamic var draft: Draft?
    
    let messages = LinkingObjects(fromType: Message.self, property: "conversation")
    
    dynamic var unreadMessagesCount: Int = 0
    dynamic var hasUnreadMessages: Bool = false
    dynamic var mentionedMe: Bool = false
    dynamic var lastMentionedMeUnixTime: TimeInterval = Date().timeIntervalSince1970 - 60*60*12 // 默认为此Conversation创建时间之前半天
    
    var latestValidMessage: Message? {
        return messages.filter({ ($0.hidden == false) && ($0.deletedByCreator == false && ($0.mediaType != MessageMediaType.sectionDate.rawValue)) }).sorted(by: { $0.createdUnixTime > $1.createdUnixTime }).first
    }
    
    var needDetectMention: Bool {
        return type == ConversationType.group.rawValue
    }
}
