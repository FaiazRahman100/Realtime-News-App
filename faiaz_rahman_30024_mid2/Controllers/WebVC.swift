//
//  WebVC.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 15/1/23.
//

import UIKit
import WebKit



class WebVC: UIViewController {

    
    
    var webView : WKWebView!
    var urlToLoad: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        
        self.view = webView
        
        let request = URLRequest(url: URL(string: urlToLoad! )!)
        
        webView.load(request)

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
