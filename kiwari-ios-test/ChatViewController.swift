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
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: MessagesViewController {
    
    let db = Firestore.firestore()
    var reference: CollectionReference?
    
    var messageList: [Message] = []
    var messageListener: ListenerRegistration?
    
    deinit {
        messageListener?.remove()
    }

    let currentUser: UserChat? = nil
    
    let email = UserDefaults.standard.string(forKey: "email") ?? ""
    let name = UserDefaults.standard.string(forKey: "name") ?? ""
    let avatar = UserDefaults.standard.string(forKey: "avatar") ?? ""
    let friendAvatar = UserDefaults.standard.string(forKey: "friendAvatar") ?? ""
    let friendEmail = UserDefaults.standard.string(forKey: "friendEmail") ?? ""
    let friendName = UserDefaults.standard.string(forKey: "friendName") ?? ""
    
    var myAvatar: UIImage? = nil
    var myFriendAvatar: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDelegate()
        loadAvatar()
        initiateChats()
        setupView()
        
    }
    
    func setupDelegate() {
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func setupView() {
        messageInputBar.inputTextView.autocorrectionType = .no
        messageInputBar.inputTextView.spellCheckingType = .no
    }
    
    func initiateChats() {
        let chatroomId = createChatroomId()
        reference = db.collection(["chatroom", chatroomId, "thread"].joined(separator: "/"))
        
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    func loadAvatar() {
        var url = URL(string: avatar)
        var data = try? Data(contentsOf: url!)
        myAvatar = UIImage(data: data!)
        
        url = URL(string: friendAvatar )
        data = try? Data(contentsOf: url!)
        myFriendAvatar = UIImage(data: data!)
    }
    
    func createChatroomId () -> String {
        var id = ""
        
        if email > friendEmail {
            id = friendEmail + email
        } else {
            id = email + friendEmail
        }
        
        id = id.replacingOccurrences(of: ".", with: "")
        id = id.replacingOccurrences(of: "@", with: "")
        
        print(id)
        
        return id
    }
    
    // MARK: - Helpers
    
    private func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    func insertMessage(_ message: Message) {
        guard !messageList.contains(message) else {
            return
        }
        
        messageList.append(message)
        messageList.sort()
        
        let isLatestMessage = messageList.index(of: message) == (messageList.count - 1)
        let shouldScrollToBottom = self.isLastSectionVisible() && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    func isLastSectionVisible() -> Bool {

        guard !messageList.isEmpty else { return false }

        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
        
    }

    func handleDocumentChange(_ change: DocumentChange) {
        print(change.document.data())
        guard let message = Message(document: change.document) else {
            print("error")
            return
        }
        
        insertMessage(message)
    }
}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        var emailAsId = email.replacingOccurrences(of: "@", with: "")
        emailAsId = emailAsId.replacingOccurrences(of: ".", with: "")
        
        return UserChat(senderId: emailAsId, displayName: name)
    }
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        var emailAsId = email.replacingOccurrences(of: "@", with: "")
        emailAsId = emailAsId.replacingOccurrences(of: ".", with: "")
        let currentUser = UserChat(senderId: emailAsId, displayName: name)
        
        let message = Message(content: text, user: currentUser)
        
        save(message)
        inputBar.inputTextView.text = ""
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.displayName == name {
            avatarView.set(avatar: Avatar(image: myAvatar, initials: "\(name.first ?? "A")"))
        } else {
            avatarView.set(avatar: Avatar(image: myFriendAvatar, initials: "\(friendName.first ?? "B")"))
        }
    }
}
