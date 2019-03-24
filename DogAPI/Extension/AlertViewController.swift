//
//  AlertViewController.swift
//
//  Created by Tushar  Jadhav on 2019-01-17.
//  Copyright © 2019 Shital  Jadhav. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(withTitle title: String, message: String, actionTitle: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func showNetworkErrorMessage() {
        showAlert(withTitle: "ERROR!", message: "Please check your internet connection", actionTitle: "OK")
    }
    
    func showAlertWithMessage(message : String) {
        showAlert(withTitle: "ERROR!", message: message, actionTitle: "OK")
    }
}
