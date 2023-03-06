//
//  CoreDataManager.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 19/1/23.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    // table <-> entity <-> class
    
    static let shared = CoreDataManager()
    // var count = 0
    
    private init() {}
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func eraseEverythingFromCoreData(){
        
        let coreDataItems = loadEverythingFromCoreData()!
        
        if coreDataItems.count == 0 {
            return
        }

        for i in 0..<coreDataItems.count{
            context.delete(coreDataItems[i])
        }
        saveItems()
    }
    
    func loadEverythingFromCoreData() -> [ArticleTable]?{
        
        var arrayList = [ArticleTable]()
        let request : NSFetchRequest<ArticleTable> = ArticleTable.fetchRequest()

        do{
            arrayList = try context.fetch(request)
        }catch {
            print("Error\(error)")
        }
        
        return arrayList
}
    
    func saveItems(){
        do{
            try context.save() // save the state
  
        }catch{
            print("error")
        }
    }

    
    func searchCatergory(catType: String) -> [ArticleTable]?{

        let predicateX = NSPredicate(format: "catName MATCHES %@", catType)

        let request : NSFetchRequest<ArticleTable> = ArticleTable.fetchRequest()
        request.predicate = predicateX

        var matchedArray = [ArticleTable]()
        do{
          matchedArray = try context.fetch(request)

        }catch {
            print("Error\(error)")
        }

        return matchedArray

    }
    
    func searchCatergoryBookmark(catType: String) -> [BookMarkTable]?{

        let predicateX = NSPredicate(format: "url MATCHES %@", catType)

        let request : NSFetchRequest<BookMarkTable> = BookMarkTable.fetchRequest()
        request.predicate = predicateX

        var matchedArray = [BookMarkTable]()
        do{
          matchedArray = try context.fetch(request)

        }catch {
            print("Error\(error)")
        }

        return matchedArray

    }
    
}
