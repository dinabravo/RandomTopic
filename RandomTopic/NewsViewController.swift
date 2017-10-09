//
//  NewsViewController.swift
//  RandomTopic
//
//  Created by Igor Stojakovic on 17/09/2017.
//  Copyright © 2017 stojakovic. All rights reserved.
//

import UIKit
import WebKit

class NewsViewController: UIViewController, WKUIDelegate
{
    var newsUrl: String! = "empty"
    
    var webView: WKWebView!
    
    override func loadView()
    {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
 
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let url: URL = URL(string: newsUrl)!
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
