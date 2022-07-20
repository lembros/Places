//
//  NavigationController.swift
//  
//
//  Created by Егор Губанов on 20.07.2022.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presentationController?.delegate = self
    }

}

extension NavigationController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        let dataScreen = children.first! as! DataInputScreen
        
        dataScreen.performSegue(withIdentifier: "dismissDataScreen", sender: dataScreen)
    }
}
