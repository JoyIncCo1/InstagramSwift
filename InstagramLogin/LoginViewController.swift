//
//  LoginViewController.swift
//
//  Created by Vlad Hociotă on 27/10/2020.
//

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate {
    private var request: URLRequest
    private let callbackURLScheme: String
    private let completion: (URL?, NSError?) -> Void

    private lazy var topView: UIView = {
        let topView = UIView(frame: CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: 510.0)))
        topView.backgroundColor = UIColor(red: 247.0, green: 247.0, blue: 247.0, alpha: 1.0)
        topView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topView)

        let topAnchor = view.safeAreaLayoutGuide.topAnchor
        let bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor

        let topConstraint = topView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = topView.bottomAnchor.constraint(equalTo: topAnchor, constant: 50.0)
        let leadingAnchor = topView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingAnchor = topView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingAnchor, trailingAnchor])

        let button = UIButton(frame: CGRect(x: 10.0, y: 8.0, width: 70.0, height: 34.0))
        button.backgroundColor = .clear
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.magenta, for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        topView.addSubview(button)
        
        let buttonTopConstraint = button.topAnchor.constraint(equalTo: topView.topAnchor, constant: 8.0)
        let buttonLeadingAnchor = button.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 10.0)

        NSLayoutConstraint.activate([buttonTopConstraint, buttonLeadingAnchor])

        return topView
    }()

    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)

        let topAnchor = view.safeAreaLayoutGuide.topAnchor
        let bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor

        let topConstraint = webView.topAnchor.constraint(equalTo: topAnchor, constant: 50.0)
        let bottomConstraint = webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        let leadingAnchor = webView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingAnchor = webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingAnchor, trailingAnchor])

        return webView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(request: URLRequest, callbackURLScheme: String, completion: @escaping (URL?, NSError?) -> Void) {
        self.request = request
        self.callbackURLScheme = callbackURLScheme
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        topView.isHidden = false
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(request)
    }
    
    @objc func cancel(_ sender: UIButton) {
        let error = NSError(domain: "InstagramAuth",
                            code: 400,
                            userInfo: [NSLocalizedFailureReasonErrorKey : "user_denied"])
        completion(nil, error)
    }


    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = webView.title
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let url = navigationAction.request.url!

        if url.absoluteString.hasPrefix(callbackURLScheme) {
            decisionHandler(.cancel)
            DispatchQueue.main.async {
                self.completion(url, nil)
            }
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        guard let httpResponse = navigationResponse.response as? HTTPURLResponse else {
            decisionHandler(.allow)
            return
        }

        switch httpResponse.statusCode {
        case 400:
            decisionHandler(.cancel)
            DispatchQueue.main.async {
                self.completion(nil, NSError(domain: "InstagramAuth", code: 400, userInfo: nil))
            }
        default:
            decisionHandler(.allow)
        }
    }
}
