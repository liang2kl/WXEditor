//
//  HTMLPreviewViewController.swift
//  WXEditor
//
//  Created by 梁业升 on 2020/10/3.
//

import WebKit

class HTMLPreviewViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    private var contentOffset: CGPoint?
    private var webView: WKWebView!
    var generator: HTMLGenerator
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHTML()
        navigationItem.title = NSLocalizedString("Preview", comment: "")
    }
    
    func reload() {
        self.contentOffset = webView.scrollView.contentOffset
        loadHTML()
    }
    
    func loadHTML() {
        let url = URL(fileURLWithPath: "file:///WXEditor/Support")
        webView.loadHTMLString(generator.generateHTML(), baseURL: url)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            if let contentOffset = self.contentOffset {
                self.webView.scrollView.setContentOffset(contentOffset, animated: false)
            }
        }
    }
    
    
    init(generator: HTMLGenerator) {
        self.generator = generator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

