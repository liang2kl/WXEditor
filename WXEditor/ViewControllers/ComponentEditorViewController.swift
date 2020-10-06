//
//  ComponentEditorViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/4.
//

import SwiftUI

class ComponentEditorViewController: UIHostingController<ComponentEditorView> {
    var component: Component
    var componentState: ComponentState
    var isTutorial: Bool
    
    init(component: Component, isTutorial: Bool = false) {
        self.isTutorial = isTutorial
        self.component = component
        self.componentState = ComponentState(component: component)
        super.init(rootView: ComponentEditorView(componentState: componentState, isTutorial: isTutorial))
        componentState.viewController = self
        rootView.viewController = self
        navigationItem.title = NSLocalizedString("Element Editor", comment: "")
        if !isTutorial {
            navigationItem.rightBarButtonItem = getAddButton()
        }
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateComponent(component: Component, type: HTMLComponent, className: String, string: String?, refreshSideBar: Bool) {
        guard !isTutorial else { return }
        let childs = component.childs
        let id = component.id
        let parent = component.parent!
        self.component = Component(type: type, id: id, className: className, childs: childs, string: string, parent: parent)
        let originalComponentIndex = parent.childs.firstIndex(where: {$0.id == id})!
        parent.remove(at: originalComponentIndex)
        parent.insert(self.component, at: originalComponentIndex)
        for index in 0..<childs.count {
            self.component.childs[index].parent = self.component
        }
        
        guard let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        editorVc.saveDocument()
        
        if refreshSideBar {
            updateSideBar()
        }
    }
    
    func updateSideBar() {
        guard !isTutorial else { return }
        guard let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        editorVc.applySnapshots()
    }
    
    
    func updatePreview() {
        guard !isTutorial else { return }
        guard let navVc = splitViewController?.viewController(for: .secondary) as? UINavigationController,
              let previewVc = navVc.topViewController as? HTMLPreviewViewController else { return }
        previewVc.reload()
    }
    
    private func getAddButton() -> UIBarButtonItem {
        var children: [UIAction] = []
        for component in HTMLComponent.allCases where component != .root {
            children.append(UIAction(title: component.head, image: UIImage(systemName: component.imageName)) { _ in
                self.addComponent(type: component)
            })
        }
        let button = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: UIMenu(children: children))
        return button
    }
    
    func addComponent(type: HTMLComponent) {
        guard !isTutorial else { return }
        var newComponent: Component
        let rootComponent = component
        newComponent = Component(type: type, parent: rootComponent)
        rootComponent.append(newComponent)
        update(id: newComponent.id)
        if let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController {
            let item = EditorViewController.Item(component: newComponent)
            let indexPath = editorVc.dataSource.indexPath(for: item)!
            editorVc.collectionView(editorVc.collectionView, didSelectItemAt: indexPath)
            editorVc.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    func update(id: UUID) {
        guard !isTutorial else { return }
        guard let navVc = splitViewController?.viewController(for: .secondary) as? UINavigationController,
              let previewVc = navVc.topViewController as? HTMLPreviewViewController,
              let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        previewVc.reload()
        editorVc.applySnapshots()
        editorVc.saveDocument()
    }


}

class ComponentState: ObservableObject {
    @Published var className: String {
        didSet { update(refreshSideBar: false) }
    }
    @Published var string: String
    @Published var type: HTMLComponent {
        didSet {
            update(refreshSideBar: true)
            viewController?.updatePreview()
        }
    }
    var viewController: ComponentEditorViewController?
    
    private func update(refreshSideBar: Bool) {
        if let vc = viewController {
            vc.updateComponent(component: vc.component, type: type, className: className, string: string, refreshSideBar: refreshSideBar)
        }
    }
    init(component: Component) {
        self.string = component.string ?? ""
        self.type = component.htmlComponent
        self.className = component.className
    }
}
