//
//  DetailVC.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 15/1/23.
//

import UIKit
import CoreData

class DetailVC: UIViewController {

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var enlargedImage: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bmBtn: UIButton!
    
    
    var passedArticle = ArticleTable()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailLabel.text = passedArticle.title
        descriptionText.text = passedArticle.descriptn
        enlargedImage.layer.cornerRadius = 20
        authorName.text = passedArticle.author
        
        //timeLabel.text = passedArticle.publishedAt
        
        let imageURL = URL(string: passedArticle.urlToImage ?? "https://craftsnippets.com/articles_images/placeholder/placeholder.jpg")
        
        enlargedImage.sd_setImage(with: imageURL)
        
        let dateString = passedArticle.publishedAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: dateString!) else {
            fatalError("Unable to parse date")
        }

        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        let formattedDate = dateFormatter.string(from: date)
        
        timeLabel.text = formattedDate
        
        
        


        // Do any additional setup after loading the view.
    }
    
    @IBAction func readMoreBtn(_ sender: Any) {
        performSegue(withIdentifier: "detailToWeb", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? WebVC{
            destinationVC.urlToLoad = passedArticle.url
    }
    }
    
    
    @IBAction func bookmarkBtn(_ sender: Any) {
        
        let alreadyBookmarked = CoreDataManager.shared.searchCatergoryBookmark(catType: passedArticle.url!)
        if (alreadyBookmarked!.count > 0){
            
            self.showToast(message: "This article is already bookmarked", font: .systemFont(ofSize: 12.0))
            print("This Item is already bookmarked ")
            return
        }
        

        let temp = BookMarkTable(context: self.context) // this is how new object need to create
        temp.author = passedArticle.author
        temp.content = passedArticle.content
        temp.descriptn = passedArticle.descriptn
        temp.publishedAt = passedArticle.publishedAt
        temp.title = passedArticle.title
        temp.url = passedArticle.url
        temp.urlToImage = passedArticle.urlToImage
        temp.catName = passedArticle.catName
        //temp.parent = CategoryArray[0]
        CoreDataManager.shared.saveItems()
        
        self.showToast(message: "Saved to bookmark list", font: .systemFont(ofSize: 12.0))
        
        
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

extension UIViewController {

 func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height - 200, width: 220, height: 35))
     toastLabel.backgroundColor =   #colorLiteral(red: 0.7843137255, green: 0.6941176471, blue: 0.4, alpha: 1).withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
