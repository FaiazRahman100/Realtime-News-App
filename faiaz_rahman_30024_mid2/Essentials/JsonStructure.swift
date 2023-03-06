//
//  JsonStructure.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 19/1/23.
//

import Foundation

struct NewsData: Codable{
    
    let status : String
    let articles: [Articles]
}

struct Articles: Codable{
    
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

}
