//
//  EditorViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import UIKit

class EditorViewController: UICollectionViewController {
    
    var url: URL
    
    init(url: URL) {
        _ = url.startAccessingSecurityScopedResource()
        let file = FileHandle(forReadingAtPath: url.path)
        url.stopAccessingSecurityScopedResource()
        let data = file!.readDataToEndOfFile()
        let rootComponent = (try! JSONDecoder().decode(Component.self, from: data))
        
        self.generator = HTMLGenerator(rootComponent: rootComponent)
        self.url = url
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum DataSection: Int, Hashable {
        case main
    }
    
    struct Item: Hashable {
        var id: UUID
        var type: HTMLComponent
        var string: String?
        var hasChild: Bool
        var imageName: String
        init(component: Component) {
            id = component.id
            type = component.htmlComponent
            string = component.string
            hasChild = component.childs.count != 0
            imageName = type.imageName
        }
    }
    
    var generator: HTMLGenerator
    var dataSource: UICollectionViewDiffableDataSource<DataSection, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureNavItem()
        configureDataSource()
        applySnapshots(initial: true)
        configurePreview()
    }

}

extension EditorViewController {
    func configureNavItem() {
        navigationItem.title = NSLocalizedString("Editor", comment: "")
        navigationItem.rightBarButtonItems = [
            getAddButton(),
            editButtonItem
        ]
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
                .reorder(),
                .delete()
            ]
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
//        // Allow every item to be reordered
//        dataSource.reorderingHandlers.canReorderItem = { item in return true }
//
//        // Option 1: Update the backing store from a CollectionDifference
//        dataSource.reorderingHandlers.didReorder = { transaction in
//        }
    }
    
    func applySnapshots(initial: Bool = false) {
        let indexPath = collectionView.indexPathsForSelectedItems?.first
        let section = DataSection.main
        var snapShot = NSDiffableDataSourceSnapshot<DataSection, Item>()
        snapShot.appendSections([section])
        dataSource.apply(snapShot, animatingDifferences: !initial)
        let snapShots = getSnapShot()
        dataSource.apply(snapShots, to: section)
        if let indexPath = indexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        }
    }


}


extension EditorViewController {
    func getSnapShot() -> NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
        for component in generator.rootComponent.childs {
            let rootItem = Item(component: component)
            snapShot.append([rootItem])
            snapShot.expand([rootItem])
            snapShot = getChilds(item: rootItem, component: component, snapShot: snapShot)
        }
        return snapShot
    }
    
    private func getChilds(item: Item, component: Component, snapShot: NSDiffableDataSourceSectionSnapshot<Item>) ->  NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = snapShot
        for child in component.childs {
            let childItem = Item(component: child)
            snapShot.append([childItem], to: item)
            snapShot.expand([childItem])
            snapShot = getChilds(item: childItem, component: child, snapShot: snapShot)
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
    
    func deleteItem(_ id: UUID) {
        guard let component = getComponent(id: id, rootComponent: generator.rootComponent) else { return }
        component.parent!.remove(id: id)
        applySnapshots()
        splitViewController?.setViewController(MainSplitViewController.blankViewController, for: .supplementary)
    }
}

extension EditorViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let component = getComponent(id: item.id, rootComponent: generator.rootComponent) else { return }
        let componentEditorVc = ComponentEditorViewController(component: component)
        splitViewController?.setViewController(componentEditorVc, for: .supplementary)
    }
    
    func getComponent(id: UUID, rootComponent: Component) -> Component? {
        if let component = rootComponent.childs.first(where: {$0.id == id}) {
            return component
        } else {
            for child in rootComponent.childs {
                let component = getComponent(id: id, rootComponent: child)
                if component != nil {
                    return component
                }
            }
        }
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath
    }
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension EditorViewController {
    func addComponent(type: HTMLComponent) {
        let rootComponent = generator.rootComponent
        let newComponent: Component = Component(type: type, parent: rootComponent)
        rootComponent.append(newComponent)
        applySnapshots()
        saveDocument()
        updateHTML()
        let item = Item(component: newComponent)
        let indexPath = dataSource.indexPath(for: item)!
        collectionView(collectionView, didSelectItemAt: indexPath)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
    }
    
    func updateHTML() {
        guard let navVc = splitViewController?.viewController(for: .secondary) as? UINavigationController,
              let previewVc = navVc.topViewController as? HTMLPreviewViewController else { return }
        previewVc.reload()
    }
    
    func saveDocument() {
        DispatchQueue.global(qos: .background).async {
            guard let data = FileGenerator.generate(fromRoot: self.generator.rootComponent) else { return }
            try? FileManager.default.removeItem(at: self.url)
            FileManager.default.createFile(atPath: self.url.path, contents: data, attributes: nil)
        }
    }

}
