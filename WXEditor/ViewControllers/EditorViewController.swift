//
//  EditorViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import UIKit

class EditorViewController: UICollectionViewController {
    
    var url: URL
    var isTutorial: Bool
    
    init(url: URL, isTutorial: Bool = false) {
        _ = url.startAccessingSecurityScopedResource()
        let file = FileHandle(forReadingAtPath: url.path)
        url.stopAccessingSecurityScopedResource()
        let data = file!.readDataToEndOfFile()
        let rootComponent = try! JSONDecoder().decode(Component.self, from: data)
        self.generator = HTMLGenerator(rootComponent: rootComponent)
        self.url = url
        self.isTutorial = isTutorial
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum DataSection: Int, Hashable {
        case main
    }
    
    struct Item: Hashable {
        private var component: Component
        var id: UUID { component.id }
        var type: HTMLComponent { component.htmlComponent }
        var string: String? { component.string }
        var hasChild: Bool { component.childs.count != 0 }
        var imageName: String { type.imageName }
        init(component: Component) {
            self.component = component
        }
    }
    
    var generator: HTMLGenerator
    var dataSource: UICollectionViewDiffableDataSource<DataSection, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureNavItem()
        configureDataSource()
        applySnapshots()
        configurePreview()
    }

}

extension EditorViewController {
    func configureNavItem() {
        if !isTutorial {
            navigationItem.title = NSLocalizedString("Editor", comment: "")
            navigationItem.rightBarButtonItems = [
                getAddButton(),
                editButtonItem
            ]
        } else {
            navigationItem.title = NSLocalizedString("Tutorial", comment: "")
        }
    }
    
    private func getAddButton() -> UIBarButtonItem {
        var menus = [UIMenu]()
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
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func configurePreview() {
        let newVc = HTMLPreviewViewController(generator: generator)
        let navVc = UINavigationController(rootViewController: newVc)

        splitViewController?.setViewController(navVc, for: .secondary)
    }

    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let _ = DataSection(rawValue: sectionIndex) else { return nil }
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
                if self.isTutorial { return nil }
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                return self.trailingSwipeActionsConfigurationForProjectCellItem(item: item)
            }

            let section: NSCollectionLayoutSection
            section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    
    
    func configuredOutlineCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.string
            content.image = UIImage(systemName: item.imageName)

            cell.tintColor = .tint
            cell.accessories = [
                .label(text: item.type.head),
            ]
            if !self.isTutorial {
                cell.accessories += [
                    .reorder(),
                    .delete()
                ]
            }
            if item.hasChild {
                cell.accessories += [
                    .outlineDisclosure(options: .init(style: .cell))
                ]
            }
            cell.contentConfiguration = content
        }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DataSection, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: self.configuredOutlineCell(), for: indexPath, item: item)
        }
        dataSource.reorderingHandlers.canReorderItem = { item in return true }

        dataSource.reorderingHandlers.didReorder = { transaction in
            let difference = transaction.difference
            self.reorder(with: difference)
        }
    }
    
    func applySnapshots(animated: Bool = false) {
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let section = DataSection.main
        var snapShot = NSDiffableDataSourceSnapshot<DataSection, Item>()
        snapShot.appendSections([section])
        dataSource.apply(snapShot, animatingDifferences: animated)
        let snapShots = getSnapShot()
        dataSource.apply(snapShots, to: section)
        if let indexPath = indexPath {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }
    }
    

    
    func updateHTML() {
        guard let navVc = splitViewController?.viewController(for: .secondary) as? UINavigationController,
              let previewVc = navVc.topViewController as? HTMLPreviewViewController else { return }
        previewVc.reload()
    }

}

//MARK: - Update Snapshots

extension EditorViewController {
    func applySnapshots(updateForID id: UUID) {
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        var snapShot = dataSource.snapshot()
        let item = snapShot.itemIdentifiers.first(where: {$0.id == id})!
        let newComponent = Component.getComponent(id: id, rootComponent: generator.rootComponent)!
        let newItem = Item(component: newComponent)
        guard newItem != item else { return }
        snapShot.insertItems([newItem], afterItem: item)
        snapShot.deleteItems([item])
        dataSource.apply(snapShot, animatingDifferences: true)
        if let indexPath = indexPath {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    func applySnapshots(removeForID id: UUID) {
        var snapShot = dataSource.snapshot()
        let item = snapShot.itemIdentifiers.first(where: {$0.id == id})!
        snapShot = snapShotForDeletingItem(item: item, snapShot: snapShot)
        splitViewController?.setViewController(MainSplitViewController.blankViewController, for: .supplementary)
        dataSource.apply(snapShot)
    }
    
    private func snapShotForDeletingItem(item: Item, snapShot: NSDiffableDataSourceSnapshot<DataSection, Item>) -> NSDiffableDataSourceSnapshot<DataSection, Item> {
        var snapShot = snapShot
        snapShot.deleteItems([item])
        let component = Component.getComponent(id: item.id, rootComponent: generator.rootComponent)!
        for child in component.childs {
            let childItem = snapShot.itemIdentifiers.first(where: {$0.id == child.id})!
            snapShot = snapShotForDeletingItem(item: childItem, snapShot: snapShot)
        }
        return snapShot
    }
    
    func applySnapshots(appendForComponent component: Component) {
        var snapShot = dataSource.snapshot(for: .main)
        let parentID = component.parent!.id
        let newItem = Item(component: component)
        if let rootItem = dataSource.snapshot().itemIdentifiers.first(where: {$0.id == parentID}) {
            snapShot.append([newItem], to: rootItem)
        } else {
            snapShot.append([newItem])
        }
        snapShot.expand([newItem])
        snapShot = snapShotWithChilds(ofItem: newItem, ofComponent: component, snapShot: snapShot)
        dataSource.apply(snapShot, to: .main)
        updateParent(parentID: parentID)
    }
    
    func updateParent(parentID: UUID) {
        var snapShot = dataSource.snapshot()
        guard let parentItem = snapShot.itemIdentifiers.first(where: {$0.id == parentID}) else { return }
        snapShot.reloadItems([parentItem])
        dataSource.apply(snapShot)
    }

}


extension EditorViewController {
    func getSnapShot() -> NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
        for component in generator.rootComponent.childs {
            let rootItem = Item(component: component)
            snapShot.append([rootItem])
            snapShot.expand([rootItem])
            snapShot = snapShotWithChilds(ofItem: rootItem, ofComponent: component, snapShot: snapShot)
        }
        return snapShot
    }
    
    private func snapShotWithChilds(ofItem: Item, ofComponent: Component, snapShot: NSDiffableDataSourceSectionSnapshot<Item>) -> NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = snapShot
        for child in ofComponent.childs {
            let childItem = Item(component: child)
            snapShot.append([childItem], to: ofItem)
            snapShot.expand([childItem])
            snapShot = snapShotWithChilds(ofItem: childItem, ofComponent: child, snapShot: snapShot)
        }
        return snapShot
    }
    

}

extension EditorViewController {
    func trailingSwipeActionsConfigurationForProjectCellItem(item: Item) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "contextual")) { _,_,_ in
            self.deleteItem(item.id)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

extension EditorViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let component = Component.getComponent(id: item.id, rootComponent: generator.rootComponent) else { return }
        let componentEditorVc = ComponentEditorViewController(component: component, isTutorial: isTutorial)
        splitViewController?.setViewController(componentEditorVc, for: .supplementary)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension EditorViewController {
    
    // MARK: -
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !isTutorial else { return nil }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { fatalError() }
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil,
            actionProvider: { _ in
                let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: "context menu"),image: UIImage(systemName: "trash"), attributes: [.destructive], state: .off) { _ in self.deleteItem(item.id) }
                let duplicateAction = UIAction(title: NSLocalizedString("Duplicate", comment: "context menu"),image: UIImage(systemName: "plus.square.on.square"), attributes: [.init()], state: .off) { _ in self.duplicateItem(id: item.id) }
                let children: [UIMenuElement] = [
                    duplicateAction,
                    UIMenu(options: .displayInline, children: [deleteAction])
                ]
                return UIMenu(title: "", children: children)
            })
    }
    
}

// MARK: - Edit Components

extension EditorViewController {
    func addComponent(type: HTMLComponent) {
        let rootComponent = generator.rootComponent
        let newComponent: Component = Component(type: type, parent: rootComponent)
        rootComponent.append(newComponent)
        saveDocument()
        applySnapshots(appendForComponent: newComponent)
        updateHTML()
        let item = Item(component: newComponent)
        let indexPath = dataSource.indexPath(for: item)!
        collectionView(collectionView, didSelectItemAt: indexPath)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
    }
    
    func deleteItem(_ id: UUID) {
        guard let component = Component.getComponent(id: id, rootComponent: generator.rootComponent) else { return }
        applySnapshots(removeForID: id)
        component.parent!.remove(id: id)
        updateParent(parentID: component.parent!.id)
        saveDocument()
        updateHTML()
    }
    
    func duplicateItem(id: UUID) {
        guard let component = Component.getComponent(id: id, rootComponent: generator.rootComponent) else { return }
        let newComponent = component.componentCopy(parent: component.parent!)
        component.parent!.append(newComponent)
        saveDocument()
        applySnapshots(appendForComponent: newComponent)
        updateHTML()
    }
    
    
    func saveDocument() {
        guard !isTutorial else { return }
        DispatchQueue.global(qos: .background).async {
            guard let data = FileGenerator.generate(fromRoot: self.generator.rootComponent) else { return }
            try? FileManager.default.removeItem(at: self.url)
            FileManager.default.createFile(atPath: self.url.path, contents: data, attributes: nil)
        }
    }
    
    func reorder(with difference: CollectionDifference<Item>) {
        let snapShot = dataSource.snapshot()
        let sectionSnapShot = dataSource.snapshot(for: .main)
        for diff in difference {
            switch diff {
            case .insert(_, let item, _):
                print("append_remove_")
                let component = Component.getComponent(id: item.id, rootComponent: generator.rootComponent)!
                let parentComponent = component.parent!
                if let parentItem = sectionSnapShot.parent(of: item) {
                    let newParentComponent = Component.getComponent(id: parentItem.id, rootComponent: generator.rootComponent)!
                    let newComponent = component.componentCopy(parent: newParentComponent)
                    let parentSnapShot = sectionSnapShot.snapshot(of: parentItem)
                    let index = parentSnapShot.items.firstIndex(of: item)!
                    print("indexx", index)
                    parentComponent.remove(id: item.id)
                    newParentComponent.childs.insert(newComponent, at: index)
                } else {
                    let newComponent = component.componentCopy(parent: generator.rootComponent)
                    let index = snapShot.indexOfItem(item)!
                    print("indexx", index)
                    parentComponent.remove(id: item.id)
                    generator.rootComponent.childs.insert(newComponent, at: index)
                    print(generator.rootComponent.childs[index].htmlComponent)
                }
                DispatchQueue.main.async {
                    self.saveDocument()
                    self.applySnapshots()
                }
            case .remove:
                print("remove_append")
            }
        }
    }

}
