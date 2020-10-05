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
    
    init(component: Component) {
        self.component = component
        self.componentState = ComponentState(component: component)
        super.init(rootView: ComponentEditorView(componentState: componentState))
        componentState.viewController = self
        rootView.viewController = self
        navigationItem.title = NSLocalizedString("Element Editor", comment: "")
        navigationItem.rightBarButtonItem = getAddButton()
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateComponent(component: Component, type: HTMLComponent, className: String, string: String?) {
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
        updateSideBar()
    }
    
    func updateSideBar() {
        guard let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        editorVc.applySnapshots()
        editorVc.saveDocument()
    }
    
    
    func updatePreview() {
        guard let previewVc = splitViewController?.viewController(for: .secondary) as? HTMLPreviewViewController else { return }
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
        var newComponent: Component
        let rootComponent = component
        newComponent = Component(type: type, parent: rootComponent)
        rootComponent.append(newComponent)
        update(id: newComponent.id)
        if let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController {
            let item = EditorViewController.Item(component: newComponent)
            let indexPath = editorVc.dataSource.indexPath(for: item)!
            editorVc.collectionView(editorVc.collectionView, didSelectItemAt: indexPath)
            editorVc.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    func update(id: UUID) {
        guard let previewVc = splitViewController?.viewController(for: .secondary) as? HTMLPreviewViewController,
              let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        previewVc.reload()
        editorVc.applySnapshots()
        editorVc.saveDocument()
    }


}

class ComponentState: ObservableObject {
    @Published var className: String {
        didSet { update() }
    }
    @Published var string: String {
        didSet { update() }
    }
    @Published var type: HTMLComponent {
        didSet { update() }
    }
    var viewController: ComponentEditorViewController?
    
    private func update() {
        if let vc = viewController {
            vc.updateComponent(component: vc.component, type: type, className: className, string: string)
        }
    }
    init(component: Component) {
        self.string = component.string ?? ""
        self.type = component.htmlComponent
        self.className = component.className
    }
}
