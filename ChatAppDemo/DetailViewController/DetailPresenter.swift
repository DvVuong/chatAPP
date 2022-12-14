//
//  DetailPresenterView.swift
//  ChatAppDemo
//
//  Created by BeeTech on 08/12/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
protocol DetailPresenterViewDelegate: NSObject {
    func showMessage()
}

class DetailPresenter {
    private weak var view: DetailPresenterViewDelegate?
    private var imgUrl:String = ""
    private var currentUser: User?
    private var receiverUser: User?
    var message:[Message] = []
    private var db = Firestore.firestore()
    
    private var messageKey = [Message]()
    init(with view: DetailPresenterViewDelegate, data: User, currentUser: User, messageKey: [Message]) {
        self.view = view
        self.receiverUser = data
        self.currentUser = currentUser
        self.messageKey = messageKey
    }
    func sendMessage(with message: String) {
        let autoKey = self.db.collection("message").document().documentID
        guard let receiverUser = receiverUser else { return }
        guard let senderUser = currentUser else  {  return }
        db.collection("message").document(autoKey).setData([
            "nameSender": senderUser.name,
            "receivername": receiverUser.name,
            "text": message,
            "image": imgUrl,
            "sendId": senderUser.id,
            "receiverID": receiverUser.id,
            "time": Date().timeIntervalSince1970,
            "read": false,
            "messageKey": autoKey
        ])
    }
    func sendImageMessage(with image: UIImage) {
        let autoKey = self.db.collection("message").document().documentID
        guard let receiverUser = receiverUser else { return }
        guard let senderUser = currentUser else  {  return }
        let storeRef = Storage.storage().reference()
        let imageKey = NSUUID().uuidString
        let image = image.jpegData(compressionQuality: 0.5)!
        let imgFolder = storeRef.child("ImageMessage").child(imageKey)
        storeRef.child("ImageMessage").child(imageKey).putData(image) { (metadat, error) in
            if error != nil { return}
            imgFolder.downloadURL { url, error in
                if error != nil {return}
                guard let url = url else {return}
                self.imgUrl = "\(url)"
                self.db.collection("message").document(autoKey).setData([
                    "nameSender": senderUser.name,
                    "sendId": senderUser.id,
                    "text": "",
                    "image": self.imgUrl,
                    "receivername": receiverUser.name,
                    "receiverID": receiverUser.id,
                    "time": Date().timeIntervalSince1970,
                    "read": false,
                    "messageKey": autoKey
                ])
            }
        }
    }
    
    func changeStateReadMessage() {
        messageKey.forEach { messKey in
            
            
        }
    }
    func currentUserID() -> String? {
        guard let id = currentUser?.id else { return nil }
        return id
    }
    
    func fetchMessage() {
        self.message.removeAll()
        guard let reciverUser = receiverUser else {return}
        guard let senderUser = self.currentUser else { return }
        self.db.collection("message").getDocuments { querySnapshot, error in
            if error != nil { return}
            guard let document = querySnapshot?.documents else { return }
            for item in document {
                let value = Message(dict: item.data())
                if ( value.receiverID == reciverUser.id && value.sendId == senderUser.id)
                    || (value.receiverID == senderUser.id && value.sendId == reciverUser.id) {
                    self.message.append(value)
                    self.sortMessage()
                    self.view?.showMessage()
                }
            }
        }
    }
    func sortMessage() {
        var timer: [Double] = []
        var messageBytime = [Message]()
        self.message.forEach { message in
            timer.append(message.time)
        }
        timer.sort{
            $0 < $1
        }
        timer.forEach { time in
            message.forEach { message in
                if message.time == time {
                    messageBytime.append(message)
                }
            }
        }
        self.message = messageBytime
    }
    func numberOfMessage() -> Int {
        return message.count
    }
    func cellForMessage(at index: Int) -> Message {
        return message[index]
    }
}
