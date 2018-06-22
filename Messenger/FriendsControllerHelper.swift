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
            mark.profileImageName = "avatar"
            createMessageWithText(text: "Hi, Im Mark", friend: mark, minutesAgo: 5, context: context)
            
            let linh = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            linh.name = "Công Linh"
            linh.profileImageName = "avatar1"
            createMessageWithText(text: "Hi there", friend: linh, minutesAgo: 2, context: context)
            createMessageWithText(text: "Fucking Shit", friend: linh, minutesAgo: 12, context: context)
            createMessageWithText(text: "What are you doing", friend: linh, minutesAgo: 10, context: context)

            let linh1 = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            linh1.name = "Linh Nguyễn"
            linh1.profileImageName = "avatar2"
            createMessageWithText(text: "Hello, I'm Linh, I'm learning iOS with Swift Language", friend: linh1, minutesAgo: 8, context: context)
            
            
            do {
                try (context.save())
            } catch let err {
                print(err)
            }
        }
        loadData()
    }
    
    
    private func createMessageWithText(text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext) {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate()
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60)
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







