//
//  MyTextFieldViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/18.
//

import UIKit

class MyTextFieldViewController: UIViewController {
    var textField: UITextField!
    init(string: String, placeHolder: String) {
        super.init(nibName: nil, bundle: nil)
        self.textField = UITextField(frame: .zero)
        textField.placeholder = placeHolder
        textField.text = string
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view = textField
        textField.autocorrectionType = .no
        textField.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
    }
    
}
