//
//  MyTextFieldView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/18.
//

import SwiftUI

final class MyTextFieldView: UIViewControllerRepresentable {
    
    init(didFinish: @escaping () -> Void, string: String, placeHolder: String) {
        self.didFinish = didFinish
        self.string = string
        self.placeHolder = placeHolder
    }
    
    var vc: MyTextFieldViewController!
    var didFinish: () -> Void
    var string: String
    var placeHolder: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = MyTextFieldViewController(string: string, placeHolder: placeHolder)
        vc = controller
        vc.textField.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
        
    class Coordinator: NSObject, UITextFieldDelegate, UITextViewDelegate {
        var parent: MyTextFieldView

        init(_ vc: MyTextFieldView) {
            self.parent = vc
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.didFinish()
        }
    }
}
