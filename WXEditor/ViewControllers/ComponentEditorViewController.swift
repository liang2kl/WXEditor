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
        navigationItem.title = NSLocalizedString("Component Editor", comment: "")
        navigationItem.rightBarButtonItem = getAddButton()
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateComponent(component: Component, type: HTMLComponent, className: String, string: String?) {
        let childs = component.childs
        let id = component.id
        var parent = component.parent!
        print("iddd", component.id)
        print("iddd", parent.id)
        switch type {
        case .blockquote: self.component = BlockQuote(id: id, className: className, childs: childs, string: string, parent: parent)
        case .br: self.component = BR(id: id, childs: childs, parent: parent)
        case .h1: self.component = H1(id: id, className: className, childs: childs, string: string, parent: parent)
        case .h2: self.component = H2(id: id, className: className, childs: childs, string: string, parent: parent)
        case .hr: self.component = HR(id: id, className: className, childs: childs, parent: parent)
        case .img: self.component = IMG(url: string ?? "", id: id, className: className, childs: childs, parent: parent)
        case .p: self.component = P(id: id, className: className, childs: childs, string: string, parent: parent)
        case .section: self.component = Section(id: id, className: className, childs: childs, string: string, parent: parent)
        case .span: self.component = Span(id: id, className: className, childs: childs, string: string, parent: parent)
        }
        print(component)
        let originalComponentIndex = parent.childs.firstIndex(where: {$0.id == id})!
        parent.childs.remove(at: originalComponentIndex)
        parent.childs.insert(self.component, at: originalComponentIndex)
        print(self.component)
        updateSideBar()
    }
    
    func updateSideBar() {
        guard let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        editorVc.applySnapshots()
    }
    
    func updatePreview() {
        guard let previewVc = splitViewController?.viewController(for: .secondary) as? HTMLPreviewViewController else { return }
        previewVc.reload()
    }
    
    private func getAddButton() -> UIBarButtonItem {
        var children: [UIAction] = []
        for component in HTMLComponent.allCases {
            children.append(UIAction(title: component.head, image: UIImage(systemName: component.imageName)) { _ in
                self.addComponent(type: component)
            })
        }
        let button = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: UIMenu(children: children))
        return button
    }
    
    func addComponent(type: HTMLComponent) {
        var newComponent: Component
        var rootComponent = component
        switch type {
        case .h1:
            newComponent = H1(parent: rootComponent)
        case .h2:
            newComponent = H2(parent: rootComponent)
        case .blockquote:
            newComponent = BlockQuote(parent: rootComponent)
        case .br:
            newComponent = BR(parent: rootComponent)
        case .hr:
            newComponent = HR(parent: rootComponent)
        case .img:
            newComponent = IMG(parent: rootComponent)
        case .section:
            newComponent = Section(parent: rootComponent)
        case .p:
            newComponent = P(parent: rootComponent)
        case .span:
            newComponent = Span(parent: rootComponent)
        }
        rootComponent.append(newComponent)
        update()
    }
    
    func update() {
        guard let previewVc = splitViewController?.viewController(for: .secondary) as? HTMLPreviewViewController,
              let editorVc = splitViewController?.viewController(for: .primary) as? EditorViewController else { return }
        previewVc.reload()
        editorVc.applySnapshots()
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
