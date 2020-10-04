//
//  MainSplitViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import SwiftUI

class MainSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .twoBesideSecondary
        preferredSplitBehavior = .tile
        let generator = HTMLGenerator()
        setViewController(EditorViewController(generator: generator), for: .primary)
        setViewController(HTMLPreviewViewController(generator: generator), for: .secondary)
        setViewController(UIViewController(), for: .supplementary)
    }
    
    init() {
        super.init(style: .tripleColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
