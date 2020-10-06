//
//  TextEditorViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/5.
//

import UIKit

class TextEditorViewController: UIViewController {
    var textView: UITextView!
    init(string: String) {
        super.init(nibName: nil, bundle: nil)
        self.textView = UITextView(frame: .zero)
        textView.text = string
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view = textView
        textView.autocorrectionType = .no
        textView.font = .systemFont(ofSize: 16)
    }
    
}
