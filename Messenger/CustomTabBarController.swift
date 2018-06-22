//
//  CustomTabBarController.swift
//  Messenger
//
//  Created by nguyen van cong linh on 22/06/2018.
//  Copyright © 2018 nguyen van cong linh. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout)
        let recentMessageNavController = UINavigationController(rootViewController: friendsController)
        recentMessageNavController.tabBarItem.title = "Recent"
        recentMessageNavController.tabBarItem.image = UIImage(named: "recent")
        
        let calls = createNavigationController(withTitle: "Calls", imageName: "calls")
        let groups = createNavigationController(withTitle: "Groups", imageName: "groups")
        let people = createNavigationController(withTitle: "People", imageName: "people")
        let settings = createNavigationController(withTitle: "Settings", imageName: "settings")
        
        viewControllers = [recentMessageNavController, calls, groups, people, settings]
    }
    
    private func createNavigationController(withTitle: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = withTitle
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
}
