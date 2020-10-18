//
//  MyTextEditorView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/5.
//

import SwiftUI

final class MyTextEditorView: UIViewControllerRepresentable {
    
    init(didChange: @escaping (String) -> Void, didFinish: @escaping () -> Void, string: String) {
        self.didChange = didChange
        self.didFinish = didFinish
        self.string = string
    }
    
    var vc: MyTextEditorViewController!
    var didChange: (String) -> Void
    var didFinish: () -> Void
    var string: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = MyTextEditorViewController(string: string)
        vc = controller
        vc.textView.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
        
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MyTextEditorView

        init(_ vc: MyTextEditorView) {
            self.parent = vc
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.didFinish()
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.didChange(textView.text)
        }
    }

    
}
