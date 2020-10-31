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
    
    func updateComponent(component: Component, type: HTMLComponent, className: String, string: String?, styles: String, refreshSideBar: Bool) {
        guard !isTutorial else { return }
        let childs = component.childs
        let id = component.id
        let parent = component.parent!
        self.component = Component(type: type, id: id, className: className, childs: childs, string: string, styles: styles, parent: parent)
        let originalComponentIndex = parent.childs.firstIndex(where: {$0.id == id})!
        parent.remove(at: originalComponentIndex)
        parent.insert(self.component, at: originalComponentIndex)
        for index in 0..<childs.count {
            self.component.childs[index].parent = self.component
        }
        
        guard let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        editorVc.saveDocument()
        
        if refreshSideBar {
            updateSideBar(id: self.component.id)
        }
    }
    
    func updateSideBar(id: UUID) {
        guard !isTutorial else { return }
        guard let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        editorVc.applySnapshots(updateForID: id)
    }
    
    
    func updatePreview() {
        guard !isTutorial else { return }
        guard let navVc = splitViewController?.viewController(for: .secondary) as? UINavigationController,
              let previewVc = navVc.topViewController as? HTMLPreviewViewController else { return }
        previewVc.reload()
    }
    
    private func getAddButton() -> UIBarButtonItem {
        var menus = [UIMenu]()
        let pasteAction = UIAction(title: NSLocalizedString("Paste", comment: ""), image: nil) { _ in
            guard let data = UIPasteboard.general.data(forPasteboardType: "Whiz_Component"),
                  let newComponent = FileGenerator.read(data) else { return }
            self.pasteComponent(newComponent)
        }
        menus.append(UIMenu(options: .displayInline, children: [pasteAction]))
        for classification in HTMLComponent.Classification.allCases {
            var classChildren: [UIAction] = []
            for component in HTMLComponent.allCases where component != .root {
                if component.classification == classification {
                    classChildren.append(UIAction(title: component.head, image: UIImage(systemName: component.imageName)) { _ in
                        self.addComponent(type: component)
                    })
                }
            }
            menus.append(UIMenu(options: .displayInline, children: classChildren))
        }
        let button = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: UIMenu(children: menus))
        return button
    }

    func addComponent(type: HTMLComponent) {
        guard !isTutorial else { return }
        var newComponent: Component
        let rootComponent = component
        newComponent = Component(type: type, parent: rootComponent)
        rootComponent.append(newComponent)
        update(newComponent: newComponent)
    }
    
    func pasteComponent(_ component: Component) {
        component.parent = self.component
        self.component.append(component)
        update(newComponent: component)
    }
    
    func update(newComponent: Component) {
        guard !isTutorial else { return }
        guard let navVc = splitViewController?.viewController(for: .secondary) as? UINavigationController,
              let previewVc = navVc.topViewController as? HTMLPreviewViewController,
              let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        previewVc.reload()
        editorVc.applySnapshots(appendForComponent: newComponent)
        editorVc.saveDocument()
        if let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController,
           let item = editorVc.dataSource.snapshot().itemIdentifiers.first(where: {$0.id == newComponent.id}),
           let indexPath = editorVc.dataSource.indexPath(for: item) {
            editorVc.collectionView(editorVc.collectionView, didSelectItemAt: indexPath)
            editorVc.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }

    }


}

class ComponentState: ObservableObject {
    @Published var className: String {
        didSet { update(refreshSideBar: false) }
    }
    @Published var string: String
    @Published var styles: String {
        didSet { update(refreshSideBar: false) }
    }
    @Published var type: HTMLComponent {
        didSet {
            update(refreshSideBar: true)
            viewController?.updatePreview()
        }
    }
    @Published var isEditingContent: Bool = false
    var viewController: ComponentEditorViewController?
    
    private func update(refreshSideBar: Bool) {
        if let vc = viewController {
            vc.updateComponent(component: vc.component, type: type, className: className, string: string, styles: styles, refreshSideBar: refreshSideBar)
        }
    }
    init(component: Component) {
        self.string = component.string ?? ""
        self.type = component.htmlComponent
        self.className = component.className
        self.styles = component.styles
    }
}
