//
//  Global.swift
//  Whiz
//
//  Created by 梁业升 on 2020/8/26.
//  Copyright © 2020 梁业升. All rights reserved.
//

import UIKit
import MessageUI

// MARK: - Alerts
func showAlert(vc: UIViewController, title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
    vc.present(alert, animated: true)
}

// Errors
func showErrorAlert(vc: UIViewController) {
    showAlert(vc: vc, title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("An internal error occured.", comment: ""))
}

func showErrorAlert(vc: UIViewController, withError error: Error) {
    print(error)
    showAlert(vc: vc, title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Error: ", comment: "") + "\"\(error.localizedDescription)\" " + NSLocalizedString("Please report this error to the developer.", comment: ""))
}

// IAP

