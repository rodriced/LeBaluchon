//
//  Helpers.swift
//  P09_Desruelles_Rodolphe_L1_projet_xcode_062022
//
//  Created by Rodolphe Desruelles on 10/07/2022.
//

import UIKit

class ControllerHelper {
    static func simpleAlert(message: String) -> UIAlertController {
        let alertVC = UIAlertController(title: "Erreur", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alertVC
    }
    
//    @objc static func hideKeyboard(_ target: UIViewController) {
//        target.view.endEditing(true)
//    }
//    
//    static func initHideKeyboardEvent(_ target: UIViewController) {
//        let tap = UITapGestureRecognizer(
//            target: target,
//            action: #selector(Self.hideKeyboard(_:))
//        )
//        target.view.addGestureRecognizer(tap)
//    }
}
