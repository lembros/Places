//
//  NavigationController.swift
//  
//
//  Created by Егор Губанов on 20.07.2022.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        self.presentationController?.delegate = self
    }
}

extension NavigationController: UIAdaptivePresentationControllerDelegate {
    // Just to deselect the cell when DataInputScreen is dismissed
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        let dataScreen = children.first! as! DataViewController
        
        dataScreen.performSegue(withIdentifier: "dismissDataScreen", sender: dataScreen)
    }
}
