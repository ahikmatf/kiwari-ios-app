//
//  Message.swift
//  kiwari-ios-test
//
//  Created by aegislabs on 18/09/19.
//  Copyright © 2019 fatahillah. All rights reserved.
//

/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import UIKit
import MessageKit
import FirebaseFirestore

internal struct Message: MessageType {

    var messageId: String = UUID().uuidString
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    var content: String
    
    
    init(content: String, user: UserChat) {
        self.content = content
        self.sender = user
        self.sentDate = Date()
        self.kind = MessageKind.text(content)
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        guard let content = data["content"] as? String else {
            return nil
        }
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }

        
        messageId = document.documentID
        
        self.sentDate = sentDate.dateValue()
        self.content = content
        self.kind = MessageKind.text(content)
        sender = UserChat(senderId: senderID, displayName: senderName)
        
    }
    
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "content": content
        ]
        return rep
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
