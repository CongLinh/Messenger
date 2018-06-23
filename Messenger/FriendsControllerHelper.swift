//
//  FriendsControllerHelper.swift
//  Messenger
//
//  Created by nguyen van cong linh on 21/06/2018.
//  Copyright © 2018 nguyen van cong linh. All rights reserved.
//

import UIKit
import CoreData

//class Friend: NSObject {
//    var name: String?
//    var profileImageName: String?
//}
//
//
//class Message: NSObject {
//    var text: String?
//    var date: NSDate?
//    var friend: Friend?
//}


extension FriendsController {
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = delegate?.persistentContainer.viewContext
        if let context = managedObjectContext {

            do {
                
                let entityNames = ["Friend", "Message"]
                for entityName in entityNames {
                    let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let objects = try(context.fetch(fetchReq)) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try(context.save())
            } catch let err {
                print(err)
            }
        }
    }
    
    func setupData() {
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = delegate?.persistentContainer.viewContext
        if let context = managedObjectContext {
            
            let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            mark.name = "Mark Zuckerberg"
            mark.profileImageName = "avatar1"
            FriendsController.createMessageWithText(text: "Hi, Im Mark", friend: mark, minutesAgo: 5, context: context)
            
            createCongLinhMessagesWithContext(context: context)

            let duc = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            duc.name = "Công Đức Lê"
            duc.profileImageName = "avatar2"
            FriendsController.createMessageWithText(text: "Hello, I'm Đức Lê, I'm learning iOS with Swift Language", friend: duc, minutesAgo: 8, context: context)
            
            let thanhLetrinh = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            thanhLetrinh.name = "Thanh Letrinh"
            thanhLetrinh.profileImageName = "avatar"
            FriendsController.createMessageWithText(text: "Hello, đcm", friend: thanhLetrinh, minutesAgo: 60 * 25, context: context)
           
            let toi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            toi.name = "Nguyễn Văn Tới"
            toi.profileImageName = "avatar2"
            FriendsController.createMessageWithText(text: "Hi, Tới Chuyên đây", friend: toi, minutesAgo: 60 * 24 * 8, context: context)
            
            
            do {
                try (context.save())
            } catch let err {
                print(err)
            }
        }
        loadData()
    }
    
    private func createCongLinhMessagesWithContext(context: NSManagedObjectContext) {
        let linh = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        linh.name = "Công Linh"
        linh.profileImageName = "avatar"
        FriendsController.createMessageWithText(text: "Hi there", friend: linh, minutesAgo: 10, context: context)
        FriendsController.createMessageWithText(text: "Fucking Shit, What are you doing, I miss you so much", friend: linh, minutesAgo: 9, context: context)
        FriendsController.createMessageWithText(text: "What are you doing now, why dont you answer my question. I love you and miss you so very much. You are bad person, but i always love you...", friend: linh, minutesAgo: 8, context: context)
        
        //response:
        FriendsController.createMessageWithText(text: "I love you too", friend: linh, minutesAgo: 7, context: context, isSender: true)
        FriendsController.createMessageWithText(text: "But we CAN'T go together :( I'm sorry bae", friend: linh, minutesAgo: 6, context: context, isSender: true)
        FriendsController.createMessageWithText(text: "Fuck u bitch", friend: linh, minutesAgo: 5, context: context)
        FriendsController.createMessageWithText(text: "Baby life was good to me, but you just made it better. I love the way you stand by me throught any kind of weather. I don't wanna run away, just wanna make your day. When you fell the world is on your shoulders. Dont wanna make it worse, just wanna make us work. Baby tell me i will do whatever", friend: linh, minutesAgo: 4, context: context)

        FriendsController.createMessageWithText(text: "Oh bae, I'm so sorry, in another life I will be your love", friend: linh, minutesAgo: 3, context: context, isSender: true)


    }
    
    //Mặc định tin nhắn là nhận, tin nhắn nào là gửi thì isSender = true
    static func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) -> Message {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate()
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
        message.isSender = NSNumber(value: isSender)
        return message
    }
    
    
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = delegate?.persistentContainer.viewContext
        if let context = managedObjectContext {
            
            if let friends = fetchFriend() {
                
                messages = [Message]()
                for friend in friends {
                    //print(friend.name as Any)
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let fetchedMessages = try(context.fetch(fetchRequest)) as? [Message]
                        messages?.append(contentsOf: fetchedMessages!)
                    } catch let err {
                        print(err)
                    }
                }
                //sắp xếp tin nhắn của các friend, tin mới hơn lên trên
                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
            }
        }
    }
    
    private func fetchFriend() -> [Friend]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = delegate?.persistentContainer.viewContext
        if let context = managedObjectContext {
            
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do {
                return try context.fetch(req) as? [Friend]
            } catch let err {
                print(err)
            }
        }
        return nil
    }
}







