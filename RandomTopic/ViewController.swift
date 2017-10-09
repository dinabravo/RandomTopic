//
//  ViewController.swift
//  RandomTopic
//
//  Created by Igor Stojakovic on 14/09/2017.
//  Copyright © 2017 stojakovic. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var labelTopic: UILabel!
    @IBOutlet weak var textViewTopic: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var sources: [NewsSource]? = []
    var displaySources: [NewsSource]? = []
    var articles: [Article]? = []
    
    var sourceIndex: Int = 0
    var articleIndex: Int = -1
    var firstLoad: Bool = true
    var updateUI: Bool = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if firstLoad
        {
            self.articles = [Article]()
            self.sources = [NewsSource]()
            self.displaySources = [NewsSource]()
            
            let image = UIImage(named: "settings")
            let button = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(OnSettingsClick))
            self.navigationItem.setRightBarButton(button, animated: false)
            
            let gestureRecognizerTap = UITapGestureRecognizer(target: self, action: #selector(tappedTextView))
            textViewTopic.addGestureRecognizer(gestureRecognizerTap)
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(showNextArticle))
            swipeLeft.direction = .left
            textViewTopic.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(showPreviousArticle))
            swipeRight.direction = .right
            textViewTopic.addGestureRecognizer(swipeRight)

            fetchSources()
            firstLoad = false
        }
        updateUI = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if Settings.instance.changed
        {
            updateUI = true
            self.spinner.startAnimating()
            refreshCategories()
            Settings.instance.changed = false
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedTextView(sender: UITapGestureRecognizer)
    {
        self.performSegue(withIdentifier: "ShowNews", sender: nil)
    }
    
    func fetchSources()
    {
        let url: URL = URL(string: "https://newsapi.org/v1/sources?language=en")!;
        let urlRequest = URLRequest(url: url);
        
        let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if (error != nil)
            {
                print(error ?? "")
                return;
            }
            do
            {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
                
                if let sourcesFromJson = json["sources"] as? [[String : AnyObject]]
                {
                    for sourceFromJson in sourcesFromJson
                    {
                        let source = NewsSource()
                        if let id = sourceFromJson["id"] as? String,
                            let url = sourceFromJson["url"] as? String,
                            let cat = sourceFromJson["category"] as? String
                        {
                            source.sourceId = id
                            source.url = url
                            source.category = cat
                            
                            self.sources?.append(source)
                            //print(source.sourceId!)
                        }
                    }
                    
                    self.setupCategories()
                    self.refreshCategories()
                }
            }
            catch let error
            {
                print (error)
            }
        }
        task.resume()
    }
    
    func setupCategories()
    {
        for source in sources!
        {
            Settings.instance.addCategory(name: source.category!)
        }
    }
    
    
    func fetchArticles()
    {
        for source in displaySources!
        {
            fetchArticle(sourceName: source.sourceId!)
        }
    }
    
    
    func fetchArticle(sourceName: String)
    {
        let urlString: String = "https://newsapi.org/v1/articles?source=\(sourceName)&apiKey=546420f2db2f4a8c91eba368bcf2dd19"
        //print(urlString)
        let url: URL = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: urlRequest){ (data, response, error) in
            if (error != nil)
            {
                print(error ?? "");
                return;
            }
        
            do
            {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
                
                if let articlesFromJson = json["articles"] as? [[String : AnyObject]]
                {
                    for articleFromJson in articlesFromJson
                    {
                        let article = Article()
                        if let title = articleFromJson["title"] as? String,
                            let author = articleFromJson["author"] as? String,
                            let desc = articleFromJson["description"] as? String,
                            let url = articleFromJson["url"] as? String,
                            let urlToImage = articleFromJson["urlToImage"] as? String
                        {
                            article.headline = title
                            article.author = author
                            article.desc = desc
                            article.url = url
                            article.imageUrl = urlToImage
                            
                            self.articles?.append(article)
                        }
                    }
                    self.sourceIndex += 1;
                    
                    if self.sourceIndex >= self.displaySources!.count
                    {
                        self.shuffleArticles()
                        self.updateTopicOnDownload()
                    }
                }
            }
            catch let error
            {
                print(error)
            }
        }
        
        task.resume()
    }
    /*
    func chooseRandomArticle()
    {
        if articles!.count > 0
        {
            articleIndex = Int(arc4random_uniform(UInt32(articles!.count)))
            let ranArticle = articles![articleIndex] as Article
            self.textViewTopic.text = ranArticle.headline
        }
    }
    */
    
    func showNextArticle()
    {
        articleIndex += 1
        
        if articles!.count > 0
        {
            if articleIndex >= articles!.count
            {
                articleIndex = 0
            }
            
            let ranArticle = articles![articleIndex] as Article
            self.textViewTopic.text = ranArticle.headline
        }
    }
    
    func showPreviousArticle()
    {
        articleIndex -= 1
        
        if articles!.count > 0
        {
            if articleIndex < 0
            {
                articleIndex = articles!.count-1
            }
            
            let ranArticle = articles![articleIndex] as Article
            self.textViewTopic.text = ranArticle.headline
        }
    }
    
    func shuffleArticles()
    {
       for i in 0...(articles!.count-1)
        {
            let randIndex = Int(arc4random_uniform(UInt32(articles!.count-i)))+i
            articles!.swapAt(i, randIndex)
        }
    }
    
    func updateTopicOnDownload()
    {
        DispatchQueue.main.sync()
        {
            if updateUI
            {
                updateUI = false
                self.spinner.stopAnimating()
                showNextArticle()
            }
        }
    }
    
    func refreshCategories()
    {
        self.articles?.removeAll()
        self.displaySources?.removeAll()
        
        self.articleIndex = -1
        self.sourceIndex = 0
        
        let categories = Settings.instance.getActiveCategories()
        
        for cat in categories
        {
            let sourceList = self.sources!.filter{$0.category == cat.name}
            displaySources?.append(contentsOf: sourceList)
        }
        updateUI = true
        fetchArticles()
    }

    @IBAction func OnNextTopicClick(_ sender: UIButton)
    {
        showNextArticle()
    }
    
    func OnSettingsClick()
    {
        self.performSegue(withIdentifier: "ShowSettings", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowNews"
        {
            let destination = segue.destination as! NewsViewController
            
            if articleIndex >= 0
            {
                let article = articles![articleIndex] as Article
                destination.newsUrl = article.url
            }
        }
    }
}

