//
//  ViewController.swift
//  Messenger
//
//  Created by nguyen van cong linh on 20/06/2018.
//  Copyright © 2018 nguyen van cong linh. All rights reserved.
//

import UIKit

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var messages: [Message]?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home"

        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true //luôn kéo được theo chiều dọc
        
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
        
        if let mess = messages?[indexPath.item] {
            cell.message = mess
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        //truyền dữ liệu sang view kia
        controller.friend = messages?[indexPath.item].friend
        navigationController?.pushViewController(controller, animated: true)
    }
    
}










class MessageCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(displayP3Red: 0, green: 134/255, blue: 249/255, alpha: 1) : .white
            nameLabel.textColor = isHighlighted ? .white : .black
            messageLabel.textColor = isHighlighted ? .white : .black
            timeLabel.textColor = isHighlighted ? .white : .black

        }
    }
    
    var message: Message? {
        didSet {
            nameLabel.text = message?.friend?.name
            if let profileImageName = message?.friend?.profileImageName {
                profileImageView.image = UIImage(named: profileImageName)
                hasReadImageView.image = UIImage(named: profileImageName)
            }
            messageLabel.text = message?.text
            
            if let date = message?.date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                //Nếu thời gian của tin nhắn mới nhất lớn hơn 1 ngày thì in ra thứ trong tuần
                let elapsdTimeInSeconds = NSDate().timeIntervalSince(date as Date)
                let secondInDays: TimeInterval = 60 * 60 * 24
                
                if elapsdTimeInSeconds > 7 * secondInDays {
                    dateFormatter.dateFormat = "MM/dd/yy"
                } else if elapsdTimeInSeconds > secondInDays {
                    dateFormatter.dateFormat = "EEE"
                } 
                
                timeLabel.text = dateFormatter.string(from: date as Date)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "avatar")
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 34
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    let dividerLineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Nguyễn Văn Công Linh"
        lbl.font = UIFont.systemFont(ofSize: 18)
        return lbl
    }()
    
    let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Nguyễn Văn Công Linh Nguyễn Văn Công Linh Nguyễn Văn Công Linh"
        lbl.textColor = UIColor.darkGray
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
    let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "09:41"
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .right
        return lbl
    }()
    
    let hasReadImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "avatar")
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 10
        return imgView
    }()
    
    override func setupView() {
        
        addSubview(profileImageView)
        addSubview(dividerLineView)
        
        setupContainerView()
        
        addConstraintWithFormat(format: "H:|-12-[v0(68)]", views: profileImageView)
        addConstraintWithFormat(format: "V:[v0(68)]", views: profileImageView)
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraintWithFormat(format: "H:|-82-[v0]|", views: dividerLineView)
        addConstraintWithFormat(format: "V:[v0(1)]|", views: dividerLineView)

    }
    
    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)
        addConstraintWithFormat(format: "H:|-90-[v0]|", views: containerView)
        addConstraintWithFormat(format: "V:[v0(50)]", views: containerView)
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        containerView.addSubview(nameLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(hasReadImageView)
        containerView.addConstraintWithFormat(format: "H:|[v0][v1(80)]-12-|", views: nameLabel, timeLabel)
        containerView.addConstraintWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView)
        containerView.addConstraintWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel)
        containerView.addConstraintWithFormat(format: "V:|[v0(24)]|", views: timeLabel)
        containerView.addConstraintWithFormat(format: "V:[v0(20)]|", views: hasReadImageView)

    }
}





extension UIView {
    func addConstraintWithFormat(format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))

    }
}





class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
    }
}








