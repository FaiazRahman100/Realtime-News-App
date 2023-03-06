//
//  ViewController.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 14/1/23.
//

import UIKit
import CoreData
import SDWebImage

class ViewController: UIViewController {
    

    @IBOutlet weak var tableVw: UITableView!
    @IBOutlet weak var collectionVw: UICollectionView!
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var sectionLabel: UILabel!
    var refreshControl = UIRefreshControl()
    
    var imageArray = ["newspaper","briefcase","sparkles.tv","newspaper","cross.vial","testtube.2","gamecontroller","waveform.path.ecg.rectangle"]
    var pagingMode = true
    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let whitePlaceholderText = NSAttributedString(string: "Search...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                    
            searchTextField.attributedPlaceholder = whitePlaceholderText
        }
    }
    @IBOutlet weak var topView: UIView!
    
    var loaderArray: [Articles] = []
    var tableArray = [ArticleTable]()
    var businessArticles = [ArticleTable]()
    var bookmarkArticles = [BookMarkTable]()
    var defaults = UserDefaults.standard
    var key = Constants.key1
    var currentCategory = "all"
    var context = CoreDataManager.shared.context
    var categoryType = ["All", "Business","Entertainment","General","Health","Science","Sports","Technology"]
    var pageCounter = Constants.initialPageCount
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        checkForUpdate()
        
        Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(Action), userInfo: nil, repeats: true)
        
        pageCounter = (defaults.object(forKey: Constants.pageCounterKey) as? [Int]) ?? Constants.initialPageCount

        loadTheArrays(catTyp: currentCategory)
        //currentCategory = categoryType[0]
        tableVw.dataSource = self
        tableVw.delegate = self
        searchTextField.delegate = self
        
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableVw.addSubview(refreshControl)
        refreshControl.tintColor = #colorLiteral(red: 0.7843137255, green: 0.6941176471, blue: 0.4, alpha: 1)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 50)
        layout.scrollDirection = .horizontal
        collectionVw.collectionViewLayout = layout
        
        
        topView.layer.cornerRadius = 20
        collectionVw.delegate = self
        collectionVw.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        defaults.set(pageCounter,forKey: Constants.pageCounterKey)
        print(pageCounter)

    }
    
    @objc func refresh(send: UIRefreshControl){
        pageCounter = [1,1,1,1,1,1,1,1]
        refreshCoreData()
        defaults.set (Date(), forKey: Constants.lastUpdateKey)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [self] in
            refreshControl.isEnabled = true
            refreshControl.endRefreshing ()
        }
        refreshControl.isEnabled = false
        refreshControl.endRefreshing ()

    }
    
    @objc func Action(){
        checkForUpdate()
        }
    
    
    func checkForUpdate() {
        
        let currentTime = Date()
        
        
        if let lastUpdate = (defaults.object(forKey: Constants.lastUpdateKey) as? Date){
            let timeInterval = currentTime.timeIntervalSince(lastUpdate)
            
            if timeInterval > 7200{
                print("if block")
                print("Refreshed CD")
                
                pageCounter = Constants.initialPageCount
                refreshCoreData()

                defaults.set (Date(), forKey: Constants.lastUpdateKey)
                
            } else { return }
        }else{
            pageCounter = Constants.initialPageCount
            fetchAllCategorytoCD()
            self.defaults.set (Date(), forKey: Constants.lastUpdateKey)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    func loadTheArrays(catTyp : String = "all"){
        tableArray = CoreDataManager.shared.searchCatergory(catType: catTyp)!
        print(tableArray.count)
        
        DispatchQueue.main.async {
            self.tableVw.reloadData()
            //self.refreshControl.endRefreshing ()
        }
        
    }

    func fetchAllCategorytoCD() {
        for i in 0..<categoryType.count {
            getDatatoCoreData(catType: categoryType[i])
            if i == categoryType.count{
                self.refreshControl.isEnabled = true
                        DispatchQueue.main.async { [self] in
                            loadTheArrays(catTyp: currentCategory)
                        }
            }
        }
    }
    
    func refreshCoreData(){
        CoreDataManager.shared.eraseEverythingFromCoreData()
        fetchAllCategorytoCD()
    }


   public func saveToBookmark(indexPath: IndexPath){
        
        let alreadyBookmarked = CoreDataManager.shared.searchCatergoryBookmark(catType: tableArray[indexPath.row].url!)
        
        if (alreadyBookmarked!.count > 0) {
            
            self.showToast(message: "This article is already bookmarked", font: .systemFont(ofSize: 12.0))
           // self.view.makeToast("This Item is already bookmarked")
            print("This Item is already bookmarked ")
            return
        }
        
        
        let temp = BookMarkTable(context: self.context) // this is how new object need to create
        temp.author = tableArray[indexPath.row].author
        temp.content = tableArray[indexPath.row].content
        temp.descriptn = tableArray[indexPath.row].descriptn
        temp.publishedAt = tableArray[indexPath.row].publishedAt
        temp.title = tableArray[indexPath.row].title
        temp.url = tableArray[indexPath.row].url
        temp.urlToImage = tableArray[indexPath.row].urlToImage
        temp.catName = tableArray[indexPath.row].catName
        
        CoreDataManager.shared.saveItems()
        self.showToast(message: "Saved to bookmark list", font: .systemFont(ofSize: 12.0))
    }
    
    
    func getDatatoCoreData(catType : String, pageNo : Int = 1){
         
        var apiLink = ("https://newsapi.org/v2/top-headlines?country=us&category=\(catType.lowercased())&apiKey=\(key)&page=\(pageNo)")
        
        if(catType == "All" || catType == "all"){
            apiLink = ("https://newsapi.org/v2/top-headlines?country=us&apiKey=\(key)&page=\(pageNo)")
        }
        
        if pageNo > 1{
            apiLink = ("https://newsapi.org/v2/top-headlines?country=us&category=\(catType.lowercased())&apiKey=\(key)&page=\(pageNo)")
            
            if(catType == "All" || catType == "all"){
                apiLink = ("https://newsapi.org/v2/top-headlines?country=us&apiKey=\(key)&page=\(pageNo)")
            }
            
        }

    
        let url = URL(string: apiLink)!
        //self.refreshControl.isEnabled = false
        // Perform data loading operations here
        
        getNewsData(url: url) { [self] result in
            switch result{
            case .success(let response):
                
                loaderArray = response

                for i in 0..<loaderArray.count{
                    
                    let temp = ArticleTable(context: self.context) // this is how new object need to create
                    temp.author = loaderArray[i].author ?? ""
                    temp.content = loaderArray[i].content ?? ""
                    temp.descriptn = loaderArray[i].description ?? ""
                    temp.publishedAt = loaderArray[i].publishedAt ?? ""
                    temp.title = loaderArray[i].title ?? ""
                    temp.url = loaderArray[i].url ?? ""
                    temp.urlToImage = loaderArray[i].urlToImage ?? ""
                    temp.catName = catType.lowercased()
                    
                    self.businessArticles.append(temp)

                }
                CoreDataManager.shared.saveItems()
                //refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
                DispatchQueue.main.async { [self] in
                    loadTheArrays(catTyp: currentCategory)
                    
                }

                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
       // self.refreshControl.isEnabled = true
    }

    }


// MARK: Collectionview Methods
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoryType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionVw.dequeueReusableCell(withReuseIdentifier: "cellA", for: indexPath) as! CellCvA
        
        cell.cVLabel.text = categoryType[indexPath.row]
        cell.layer.cornerRadius = 20
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let y = x > 0 ? "positive" : "non-positive"
        
        labelImage.image = UIImage(systemName: imageArray[indexPath.row])
        sectionLabel.text = indexPath.row > 0 ? categoryType[indexPath.row] : "All News"
        currentCategory = categoryType[indexPath.row].lowercased()
        loadTheArrays(catTyp: categoryType[indexPath.row].lowercased())
    }
}


//MARK: - Tableview Methods
extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableVw.dequeueReusableCell(withIdentifier: "TVcell", for: indexPath) as! TVcell
        cell.tvCellTitle.text = tableArray[indexPath.row].title
        cell.authorLabel.text = tableArray[indexPath.row].author
        
        let imageURL = URL(string: tableArray[indexPath.row].urlToImage ?? "https://craftsnippets.com/articles_images/placeholder/placeholder.jpg")

        cell.articleImage.sd_setImage(with: imageURL)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = tableArray[indexPath.row].publishedAt ?? "2023-01-17T11:37:00Z"
        let date = dateFormatter.date(from: dateString)
        let passedTimeSecond = Date().timeIntervalSince(date!)
        
        let minutes = round(passedTimeSecond/60)
        
        if minutes > 59.0{
            let hour = round(minutes/60)
            if hour>23{
                let day = round(hour/24)
                cell.articleTime.text = ("\(Int(day)) day ago")
            }else{
                cell.articleTime.text = ("\(Int(hour)) hours ago")
                
            }
            
        }else {
            cell.articleTime.text = ("\(Int(minutes)) min ago")
        }
        //////////
        ///
        //cell.tiles.layer.cornerRadius = 20
        cell.bgView.layer.cornerRadius = 20
        cell.articleImage.layer.cornerRadius = 20
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
             
        performSegue(withIdentifier: "wayToDetail", sender: self)

        tableVw.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = tableVw.indexPathForSelectedRow
        
        if let destinationVC = segue.destination as? DetailVC{
            destinationVC.passedArticle = tableArray[index!.row]
        }
            
        
    }
    
    // Trailing Action Setup
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {


            let bookmarkAction = UIContextualAction(style: .destructive, title: nil) {[weak self] _, _, completion in

                guard let self = self else {return}

                self.performBookmarkAction(indexPath: indexPath)
                completion(true)
            }
            bookmarkAction.image = UIImage(systemName: "bookmark.circle.fill")
            bookmarkAction.backgroundColor = #colorLiteral(red: 0.7843137255, green: 0.6941176471, blue: 0.4, alpha: 1)


            let swipeActions = UISwipeActionsConfiguration(actions: [bookmarkAction])
            swipeActions.performsFirstActionWithFullSwipe = true
            return swipeActions

        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: indexPath.section) - 1
        
        
       // print("paging mode \(pagingMode)")
        if (!pagingMode){
            
            //print("paging mode \(pagingMode)")
            return
        }
        
        if indexPath.row == lastRowIndex {
           // print("last row reached")
            
            let indexOfCurrenrtArray = categoryType.firstIndex(of: currentCategory.capitalized)
            
            
            if pageCounter[indexOfCurrenrtArray!] < 5 {
                pageCounter[indexOfCurrenrtArray!] += 1
                let pageToLoad = pageCounter[indexOfCurrenrtArray!]
                getDatatoCoreData(catType : currentCategory, pageNo: pageToLoad)
            }else{
                self.showToast(message: "No more article to load", font: .systemFont(ofSize: 12.0))
            }
        }
    }
        func performBookmarkAction(indexPath: IndexPath){
            saveToBookmark(indexPath: indexPath)
        }
    
    
}

// MARK: Searchbar Methods
extension ViewController : UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("User typed: \(searchTextField.text!)")
        
       // pagingMode = false
        
        if searchTextField.text!.count != 0 {
            pagingMode = false
        }
        if searchTextField.text!.count == 0 {
            pagingMode = true
        }
        
        searchThisQuery(searchTextField.text!)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let query  = searchTextField.text!
        searchThisQuery(query)
        pagingMode = true
        searchTextField.text = ""
        
    }
    
    @IBAction func searchBtnClicked(_ sender: Any) {
        
        let query  = searchTextField.text!
        searchThisQuery(query)
        searchTextField.text = ""
    }
    
    
    
    
    func searchThisQuery(_ query : String){
        if query.count == 0 {
            self.showToast(message: "Please input you query", font: .systemFont(ofSize: 12.0))
            return
        }
        
        let predicateX = NSPredicate(format: "catName MATCHES %@ && (title CONTAINS[c] %@ || author CONTAINS[c] %@ || descriptn CONTAINS[c] %@)", currentCategory , query,query,query)

        let request : NSFetchRequest<ArticleTable> = ArticleTable.fetchRequest()
        request.predicate = predicateX

        var matchedArray = [ArticleTable]()
        

        
        do{
          matchedArray = try context.fetch(request)

        }catch {
            print("Error\(error)")
        }
        if matchedArray.count == 0{
            self.showToast(message: "No Article Found", font: .systemFont(ofSize: 12.0))
            return
        }
        
        tableArray = matchedArray
        tableVw.reloadData()
    }
}

