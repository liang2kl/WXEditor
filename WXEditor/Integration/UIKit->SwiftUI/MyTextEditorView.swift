//
//  MyTextEditorView.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/5.
//

import SwiftUI

final class MyTextEditorView: UIViewControllerRepresentable {
    
    init(vc: ComponentEditorViewController) {
        self.viewController = vc
    }
    
    var viewController: ComponentEditorViewController
    var vc: MyTextEditorViewController!
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = MyTextEditorViewController(string: viewController.componentState.string)
        vc = controller
        vc.textView.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateComponent(string: String) {
        viewController.componentState.string = string
        viewController.updateComponent(component: viewController.component, type: viewController.componentState.type, className: viewController.componentState.className, string: viewController.componentState.string, refreshSideBar: false)
    }
    
    func updateAppearance() {
        viewController.updateSideBar(id: viewController.component.id)
        viewController.updatePreview()
    }

    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MyTextEditorView

        init(_ vc: MyTextEditorView) {
            self.parent = vc
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.updateAppearance()
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.updateComponent(string: textView.text)
        }
    }

    
}
