//
//  BookmarkVC.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 15/1/23.
//

import UIKit
import CoreData

class BookmarkVC: UIViewController{
    

    @IBOutlet weak var topViewBV: UIView!
    
    @IBOutlet weak var searchTextB: UITextField!{
        didSet{
            searchTextB.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let whitePlaceholderText = NSAttributedString(string: "Search...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                    
            searchTextB.attributedPlaceholder = whitePlaceholderText
        }
    }
    
    
    @IBOutlet weak var TableVwBVC: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tableArray2 = [BookMarkTable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableArray2 = loadEverythingCD()!
        topViewBV.layer.cornerRadius = 20
        TableVwBVC.delegate = self
        TableVwBVC.dataSource = self
        searchTextB.delegate = self
        searchTextB.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        tableArray2 = loadEverythingCD()!
        TableVwBVC.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    func loadEverythingCD() -> [BookMarkTable]?{
                var arrayList = [BookMarkTable]()
                let request : NSFetchRequest<BookMarkTable> = BookMarkTable.fetchRequest()
        
                do{
                    arrayList = try context.fetch(request)
                }catch {
                    print("Error\(error)")
                }
                
                return arrayList
    }
    
    func deleteItem(index : Int){
        context.delete(tableArray2[index])
        print("deleted")
        tableArray2.remove(at: index)
        CoreDataManager.shared.saveItems()
        DispatchQueue.main.async {
            self.TableVwBVC.reloadData()
        }
    }
}

extension BookmarkVC : UITextFieldDelegate {
    
    @IBAction func searchBtnClicked(_ sender: Any) {
        let query  = searchTextB.text!
        searchThisQuery(query)
        searchTextB.text = ""
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        print("User typed: \(searchTextB.text!)")
        
        searchThisQuery(searchTextB.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextB.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let query  = searchTextB.text!
        searchThisQuery(query)
        searchTextB.text = ""
    }

    
    func searchThisQuery(_ query : String){
        if query.count == 0 {
            self.showToast(message: "Please input you query", font: .systemFont(ofSize: 12.0))
            return
        }
        
        let predicateX = NSPredicate(format: "(title CONTAINS[c] %@ || author CONTAINS[c] %@ || descriptn CONTAINS[c] %@)", query,query,query)

        let request : NSFetchRequest<BookMarkTable> = BookMarkTable.fetchRequest()
        request.predicate = predicateX

        var matchedArray = [BookMarkTable]()
        do{
          matchedArray = try context.fetch(request)

        }catch {
            print("Error\(error)")
        }
        if matchedArray.count == 0{
            self.showToast(message: "No Article Found", font: .systemFont(ofSize: 12.0))
            return
        }
        tableArray2 = matchedArray
        TableVwBVC.reloadData()
    }
    
    
}



extension BookmarkVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableArray2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableVwBVC.dequeueReusableCell(withIdentifier: "TVcell2", for: indexPath) as! TVcell2
        cell.titleBVC.text = tableArray2[indexPath.row].title
        
        cell.authorText.text = tableArray2[indexPath.row].author
        
        let imageURL = URL(string: tableArray2[indexPath.row].urlToImage ?? "https://craftsnippets.com/articles_images/placeholder/placeholder.jpg")
        
        //cell.imgNews.image = UIImage(named: "database")
        cell.imageViewBVC.layer.cornerRadius = 10
        cell.imageViewBVC.sd_setImage(with: imageURL)

        
        /////// date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = tableArray2[indexPath.row].publishedAt!
        let date = dateFormatter.date(from: dateString)
        let passedTimeSecond = Date().timeIntervalSince(date!)
        
        let minutes = round(passedTimeSecond/60)
        
        if minutes > 59.0{
            let hour = round(minutes/60)
            if hour>23{
                let day = round(hour/24)
                cell.timeText.text = ("\(Int(day)) day ago")
            }else{
                cell.timeText.text = ("\(Int(hour)) hours ago")
                
            }
            
        }else {
            cell.timeText.text = ("\(Int(minutes)) min ago")
        }

        let catName = tableArray2[indexPath.row].catName!.capitalized
        cell.catNameText.text = catName == "All" ? "General" : catName
        cell.bgView.layer.cornerRadius = 20
        cell.imageViewBVC.layer.cornerRadius = 20
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "wayToWeb", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = TableVwBVC.indexPathForSelectedRow
        
        if let destinationVC = segue.destination as? WebVC{
            destinationVC.urlToLoad = tableArray2[index!.row].url
        }
    }
    
    
    
    // Trailing Action Setup
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {


            let deleteAction = UIContextualAction(style: .destructive, title: nil) {[weak self] _, _, completion in

                guard let self = self else {return}

                self.deleteItem(index: indexPath.row) // performDeleteAction(indexPath: indexPath)
                completion(true)
            }
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed


            let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
            swipeActions.performsFirstActionWithFullSwipe = true
            return swipeActions


        }



        func performDeleteAction(indexPath: IndexPath){

            tableArray2.remove(at: indexPath.row)
            TableVwBVC.reloadData()

        }
}
