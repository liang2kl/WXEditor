//
//  MainSplitViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import SwiftUI

class MainSplitViewController: UISplitViewController {
    static let blankViewController = UIHostingController<BlankView>(rootView: BlankView())
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .twoBesideSecondary
        preferredSplitBehavior = .tile
        let generator = HTMLGenerator(rootComponent: Component(type: .root, parent: nil))
        setViewController(FileViewController.defaultController, for: .primary)
        setViewController(HTMLPreviewViewController(generator: generator), for: .secondary)
        setViewController(MainSplitViewController.blankViewController, for: .supplementary)
    }
    
    init() {
        super.init(style: .tripleColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
