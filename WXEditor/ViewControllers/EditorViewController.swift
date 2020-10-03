//
//  EditorViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import UIKit

class EditorViewController: UICollectionViewController {
    
    init(generator: HTMLGenerator) {
        self.generator = generator
        super.init(collectionViewLayout: EditorViewController.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: Int, Hashable {
        case main
    }
    
    struct Item: Hashable {
        var id = UUID()
        var type: HTMLComponent
        var string: String?
        var hasChild: Bool
        var imageName: String
        init(component: Component) {
            type = component.htmlComponent
            string = component.string
            hasChild = component.childs.count != 0
            imageName = type.imageName
        }
    }
    
    var generator: HTMLGenerator
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureNavItem()
        configureDataSource()
        applyInitialSnapshots()
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
        for component in HTMLComponent.allCases {
            children.append(UIAction(title: component.head, image: UIImage(systemName: component.imageName)) { _ in
                self.addComponent(type: component)
            })
        }
        let button = UIBarButtonItem(title: nil, image: UIImage(systemName: "plus"), primaryAction: nil, menu: UIMenu(children: children))
        return button
    }
    
    func configureHierarchy() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    static func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let _ = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            section = NSCollectionLayoutSection.list(using: .init(appearance: .sidebar), layoutEnvironment: layoutEnvironment)
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
            cell.contentConfiguration = content
            cell.accessories = [
                .label(text: item.type.head),
                .reorder(),
                .multiselect()
            ]
            if item.hasChild {
                cell.accessories += [
                    .outlineDisclosure(options: .init(style: .cell))
                ]
            }
        }
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: self.configuredOutlineCell(), for: indexPath, item: item)
        }
    }
    
    func applyInitialSnapshots() {
        // Order of the section
        let section = Section.main
        var snapShot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapShot.appendSections([section])
        dataSource.apply(snapShot, animatingDifferences: false)
        let snapShots = getSnapShot()
        dataSource.apply(snapShots, to: section)
        
    }


}


extension EditorViewController {
    func getSnapShot() -> NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
        for component in generator.components {
            let rootItem = Item(component: component)
            snapShot.append([rootItem])
            snapShot = getChilds(item: rootItem, component: component, snapShot: snapShot)
        }
        return snapShot
    }
    
    private func getChilds(item: Item, component: Component, snapShot: NSDiffableDataSourceSectionSnapshot<Item>) ->  NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = snapShot
        for child in component.childs {
            let childItem = Item(component: child)
            snapShot.append([childItem], to: item)
            snapShot = getChilds(item: childItem, component: child, snapShot: snapShot)
        }
        return snapShot
    }
}

extension EditorViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension EditorViewController {
    func addComponent(type: HTMLComponent) {
        
    }
}
