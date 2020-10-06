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
    
    private var tempUrl: URL?
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareHTML(_:)))
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
    
    @objc func shareHTML(_ sender: UIBarButtonItem) {
        let fileManager = MyFileManager(url: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
        do {
            let string = generator.exportHTML()
            let url = try fileManager.availableURL(forName: "Exported_HTML", withExtension: "html")
            try string.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            let objectsToShare = [url]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.barButtonItem = sender
            activityVC.popoverPresentationController?.delegate = self
            tempUrl = url
            present(activityVC, animated: true)
        } catch {
            print(error)
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

extension HTMLPreviewViewController: UIPopoverPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let tempUrl = tempUrl {
            try? FileManager.default.removeItem(at: tempUrl)
            self.tempUrl = nil
        }
    }
}
