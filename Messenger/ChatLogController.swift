//
//  ChatLogController.swift
//  Messenger
//
//  Created by nguyen van cong linh on 21/06/2018.
//  Copyright © 2018 nguyen van cong linh. All rights reserved.
//

import UIKit
import CoreData

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
   
    let cellId = "cellId"
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            //messages = friend?.messages?.allObjects as? [Message]
            //messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
        }
    }
    
    //var messages: [Message]?
    
    let messageInputContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.97, alpha: 1)
        return v
    }()
    
    let inputTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nhập tin nhắn..."
        return tf
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Gửi", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return btn
    }()
    
    @objc func handleSend() {
        print("Sent")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        
        do {
            try context.save()
            inputTextField.text = nil

//            messages?.append(message)
//
//            let indexs = NSIndexPath(item: (messages?.count)! - 1, section: 0)
//            collectionView?.insertItems(at: [indexs as IndexPath])
//            collectionView?.scrollToItem(at: indexs as IndexPath, at: .bottom, animated: true)
            
        } catch let err {
            print(err)
        }
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    @objc func simulate() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        FriendsController.createMessageWithText(text: "Đã nhận lúc trước", friend: friend!, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText(text: "Tin nhắn khác đã nhận lúc trước", friend: friend!, minutesAgo: 1, context: context)

        
        do {
            try context.save()
//            messages?.append(message)
//            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
//
//            if let item = messages?.index(of: message) {
//                let receiveIndexPath = NSIndexPath(item: item, section: 0)
//                collectionView?.insertItems(at: [receiveIndexPath as IndexPath])
//            }
        } catch let err {
            print(err)
        }
    }
    
    lazy var fetchedResultController: NSFetchedResultsController = { () -> NSFetchedResultsController<Message> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "friend.name = %@", (self.friend?.name!)!)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc as! NSFetchedResultsController<Message>
    }()
    
    
    var blockOperation = [BlockOperation]()
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert {
            blockOperation.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            
            for operation in self.blockOperation {
                operation.start()
            }
        }, completion: { (completed) in
            let lastItem = self.fetchedResultController.sections![0].numberOfObjects - 1
            let indexPath = NSIndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultController.performFetch()
            print("abcde")
        } catch let err {
            print(err)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        
        tabBarController?.tabBar.isHidden = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(messageInputContainerView)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintWithFormat(format: "V:[v0(45)]", views: messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            //thay đổi thuộc tính constant để đẩy inputTextField lên trên Keyboard hoặc xuống dưới
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            //Làm cho inputTextField và Keyboard dính vào nhau khi chuyển lên hoặc xuống
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                //Đẩy tin nhắn mới nhất lên trên inputContainerView:
                if isKeyboardShowing {
                    let lastItem = self.fetchedResultController.sections![0].numberOfObjects - 1
                    let indexPath = NSIndexPath(item: lastItem, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
        //bottomConstraint?.constant = 0
    }

    private func setupInputComponents() {
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        
        messageInputContainerView.addConstraintWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintWithFormat(format: "V:|[v0]|", views: sendButton)


    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = fetchedResultController.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        let message = fetchedResultController.object(at: indexPath) //as! Message
        
        
        cell.messageTextView.text = message.text
        
        
        if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 5000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
            
            //Nếu tin nhắn là gửi đến, đặt nó ở bên trái
            if !message.isSender!.boolValue {
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = false
                //cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                cell.messageTextView.textColor = UIColor.black
                
            } else { //Nếu tin nhắn được gửi đi, chuyển nó sang bên phải
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = true
                //cell.textBubbleView.backgroundColor = UIColor.red
                cell.bubbleImageView.tintColor = UIColor.red
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                cell.messageTextView.textColor = UIColor.white
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let message = fetchedResultController.object(at: indexPath) //as! Message
        
        //Setting kích thước textView tuỳ vào độ dài tin nhắn
        if let messageText = message.text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 18)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
}


class ChatLogMessageCell: BaseCell {
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.text = "Hello, nice to meet you"
        tv.backgroundColor = UIColor.clear
        return tv
    }()
    
    //View bọc tin nhắn
    let textBubbleView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "avatar1")
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 15
        imgView.layer.masksToBounds = true
        return imgView
    }()
    
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    let bubbleImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.image = ChatLogMessageCell.grayBubbleImage
        imgV.tintColor = UIColor(white: 0.95, alpha: 1)
        return imgV
    }()
    
    override func setupView() {
        super.setupView()

        addSubview(textBubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)

        addConstraintWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintWithFormat(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintWithFormat(format: "V:|[v0]|", views: bubbleImageView)

    }
}










