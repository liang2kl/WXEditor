//
//  FileViewController.swift
//  Whiz
//
//  Created by 梁业升 on 2020/8/13.
//  Copyright © 2020 梁业升. All rights reserved.
//

import UIKit
#if !targetEnvironment(macCatalyst)
import UniformTypeIdentifiers
#endif

class FileViewController: UICollectionViewController {
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var fileManager: MyFileManager
    var url: URL
    var newName: String?
    var newFolderName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureNavItem()
        configureDataSource()
        applySnapShots(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapShots(animated: false)
        splitViewController?.setViewController(MainSplitViewController.blankViewController, for: .supplementary)
    }
    
    init(url: URL) {
        self.url = url
        fileManager = MyFileManager(url: url)
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: -
    enum Section: Int, Hashable, CaseIterable {
        case folder, doc, other
    }
    struct Item: Hashable {
        let url: URL
        let type: Section
        init(url: URL) {
            self.url = url
            if url.hasDirectoryPath {
                type = .folder
            } else if url.pathExtension == "wedoc" {
                type = .doc
            } else {
                type = .other
            }
        }
    }

    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsSelectionDuringEditing = true
        collectionView.allowsMultipleSelectionDuringEditing = true
    }
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let _ = Section(rawValue: sectionIndex) else { return nil }
            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                return self.trailingSwipeActionsConfigurationForProjectCellItem(item: item)
            }
            configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                return self.leadingSwipeActionsConfigurationForProjectCellItem(item: item)
            }
            let section: NSCollectionLayoutSection
            section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func configureNavItem() {
        navigationItem.title = NSLocalizedString("Documents", comment: "")
        navigationItem.backButtonTitle = ""
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        let addFileButton = UIBarButtonItem(systemItem: .add, menu: UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Import", comment: ""), image: UIImage(systemName: "square.and.arrow.down")) { _ in
                self.importFiles()
            },
            UIAction(title: NSLocalizedString("New Document", comment: ""), image: UIImage(systemName: "plus")) { _ in
                self.addFile()
            }
        ]))

        navigationItem.rightBarButtonItems = [addFileButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info"), style: .plain, target: self, action: #selector(showTutorial))
        
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteSelectedItmes))
        ]
        toolbarItems = items
        navigationController?.setToolbarHidden(true, animated: false)
    }

    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: self.configuredCell(), for: indexPath, item: item)
        }
    }

    func configuredCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = UIListContentConfiguration.cell()
            content.text = item.url.lastPathComponent
            content.textProperties.numberOfLines = 1
            switch item.type {
            case .folder:
                content.image = UIImage(systemName: "folder")
                cell.accessories = [.disclosureIndicator()]
            case .doc:
                content.image = UIImage(systemName: "doc.richtext.fill")
            case .other:
                content.image = UIImage(systemName: "doc.text")
            }
            cell.tintColor = .tint
            cell.contentConfiguration = content
        }
    }
    
    func applySnapShots(animated: Bool = true) {
        for section in Section.allCases {
            var sectionSnapShot = NSDiffableDataSourceSnapshot<Section, Item>()
            sectionSnapShot.appendSections([section])
            let snapShot = getSnapShot(for: section)
            dataSource.apply(snapShot, to: section, animatingDifferences: animated)
        }
    }

    func trailingSwipeActionsConfigurationForProjectCellItem(item: Item) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "contextual")) { _,_,_ in
            self.delete(items: [item])
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func leadingSwipeActionsConfigurationForProjectCellItem(item: Item) -> UISwipeActionsConfiguration? {
        let renameAction = UIContextualAction(style: .normal, title: NSLocalizedString("Rename", comment: "contextual")) { _,_,_ in
            guard let indexPath = self.dataSource.indexPath(for: item) else { return }
            self.rename(indexPath: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [renameAction])
    }

    
    //MARK: -
    func getSnapShot(for section: Section) -> NSDiffableDataSourceSectionSnapshot<Item> {
        var snapShot = NSDiffableDataSourceSectionSnapshot<Item>()
        var items = [Item]()
        var urls = [URL]()
        do {
            switch section {
            case .folder:
                urls = []
            case .doc:
                urls = try fileManager.urls(forType: "wedoc")
            case .other:
                urls = []
            }
            for url in urls {
                let item = Item(url: url)
                items.append(item)
            }
            snapShot.append(items)
        } catch {
            showErrorAlert(vc: self, withError: error)
        }
        return snapShot
    }
    
    //MARK: - Editing
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setToolBar(editing: editing)
    }
    
    func setToolBar(editing: Bool) {
        if editing {
            if let count = collectionView.indexPathsForSelectedItems?.count, count > 0 {
                navigationController?.setToolbarHidden(false, animated: true)
            } else {
                navigationController?.setToolbarHidden(true, animated: true)
            }
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    @objc func deleteSelectedItmes() {
        guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems else { return }
        print(selectedIndexPaths.count)
        let items = selectedIndexPaths.map({ dataSource.itemIdentifier(for: $0)! })
        print(items.count)
        delete(items: items)
    }

    
    //MARK: -
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !collectionView.isEditing else { return }
        guard let url = dataSource.itemIdentifier(for: indexPath)?.url else { return }
        let editorVc = EditorViewController(url: url)
        navigationController?.pushViewController(editorVc, animated: true)
    }
    
    
    
    //MARK: -
    func delete(items: [Item]) {
        do {
            try self.fileManager.delete(items.map({$0.url}))
            self.applySnapShots()
        } catch {
            showErrorAlert(vc: self, withError: error)
            return
        }
    }
    
    func share(indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { fatalError() }
        let objectsToShare = [item.url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        if let rect = collectionView.layoutAttributesForItem(at: indexPath)?.frame {
            activityVC.popoverPresentationController?.sourceRect = rect
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.permittedArrowDirections = [.left]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    
    func rename(indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { fatalError() }
        
        let alert = UIAlertController(title: NSLocalizedString("Rename", comment: ""), message: NSLocalizedString("Enter a new name for the item.", comment: ""), preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: NSLocalizedString("Rename", comment: ""), style: .default) {
            (action) -> Void in
            do {
                if let newName = self.newName {
                    if newName != "" {
                        try self.fileManager.rename(url: item.url, newName: newName)
                        self.applySnapShots()
                    }
                }
                self.newName = nil
            } catch {
                showErrorAlert(vc: self, withError: error)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        alert.addTextField {
            (textField) -> Void in
            textField.delegate = self
            textField.text = item.url.deletingPathExtension().lastPathComponent
            textField.placeholder = NSLocalizedString("Enter new name", comment: "placeholder")
            textField.clearButtonMode = .always
        }
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)

    }
    
    func addFolder() {
        let alert = UIAlertController(title: NSLocalizedString("New Folder", comment: ""), message: NSLocalizedString("Enter the name for the folder.", comment: ""), preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default) {
            (action) -> Void in
            let defaultFolderName = NSLocalizedString("New Folder", comment: "")
            let newName = self.newName == "" ? defaultFolderName : (self.newName ?? defaultFolderName)
            do {
                try self.fileManager.newFolder(name: newName)
                self.applySnapShots()
                self.newName = nil
            } catch {
                showErrorAlert(vc: self, withError: error)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        alert.addTextField {
            (textField) -> Void in
            textField.delegate = self
        }
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)

    }
    
    func addFile() {
        let data = FileGenerator.generate(fromRoot: Component(type: .root, parent: nil)) ?? Data()
        try! _ = fileManager.createFile(from: data, fileName: "New File", pathExtension: "wedoc")
        applySnapShots()
    }
    
    
    func createFile(from data: Data, fileName: String, pathExtension: String) -> URL? {
        do {
            let url = try fileManager.createFile(from: data, fileName:fileName, pathExtension: pathExtension)
            return url
        } catch {
            print(error)
            return nil
        }
    }
    
    @objc func showTutorial() {
        let url = Bundle.main.url(forResource: "tutorial", withExtension: "wedoc")!
        let vc = EditorViewController(url: url, isTutorial: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension FileViewController {

    // MARK: -
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { fatalError() }
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil,
            actionProvider: { _ in
                let renameAction = UIAction(title: NSLocalizedString("Rename", comment: "context menu"), image: UIImage(systemName: "pencil.and.ellipsis.rectangle"), state: .off) { _ in self.rename(indexPath: indexPath) }
                let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: "context menu"),image: UIImage(systemName: "trash"), attributes: [.destructive], state: .off) { _ in self.delete(items: [item]) }
                let shareMenuAction = UIAction(title: NSLocalizedString("Share", comment: "context menu"),image: UIImage(systemName: "square.and.arrow.up"), attributes: [], state: .off) { _ in self.share(indexPath: indexPath) }
                let children: [UIMenuElement] = [renameAction, shareMenuAction, deleteAction]
                let title = item.url.lastPathComponent
                return UIMenu(title: title, children: children)
        })
    }
    
}

extension FileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        newName = textField.text ?? ""
    }
}

extension FileViewController {
    static let defaultController: FileViewController = FileViewController(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
}

extension FileViewController: UIDocumentPickerDelegate {
    @objc func importFiles() {
        let supportedDocumentTypes = ["com.liang2kl.whiz.editor.doc"]
        #if targetEnvironment(macCatalyst)
        let controller = UIDocumentPickerViewController(documentTypes: supportedDocumentTypes, in: .import)
        #else
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: getTypes(typeNames: supportedDocumentTypes))
        #endif
        controller.delegate = self
        controller.allowsMultipleSelection = true
        present(controller, animated: true)
    }
    
    func getTypes(typeNames: [String]) -> [UTType] {
        var types = [UTType]()
        for identifier in typeNames {
            types.append(.init(importedAs: identifier))
        }
        return types
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            try fileManager.addFiles(urls, type: .copy)
            applySnapShots()
        } catch {
            print(error)
        }
    }
}
