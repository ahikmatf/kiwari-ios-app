//
//  ChatViewController.swift
//  kiwari-ios-test
//
//  Created by aegislabs on 18/09/19.
//  Copyright © 2019 fatahillah. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MessagesDisplayDelegate, MessagesLayoutDelegate {
    var messageList: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return User(senderId: "01", displayName: "Hikmat")
    }
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
}
