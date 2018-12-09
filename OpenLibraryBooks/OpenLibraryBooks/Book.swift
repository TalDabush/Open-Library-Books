//
//  Book.swift
//  OpenLibraryBooks
//
//  Created by Tal on 06/12/2018.
//  Copyright © 2018 Tal. All rights reserved.
//

import UIKit

class Book {
    
    var title: String
    var coverID: (name: String, code: String?)
    var author: String?
    var contributors: [String]?
    var subjects: [String]?
    var first_publish_year: Int?
    var persons : [String]?
    
    
    init (_ title: String, _ author: String?, _ coverID: (name: String, code: String?), _ contributors: [String]?, _ subjects: [String]?, _ first_publish_year: Int?, _ persons: [String]?){
        self.title = title
        self.author = author
        self.coverID = coverID
        self.contributors = contributors
        self.subjects = subjects
        self.first_publish_year = first_publish_year
        self.persons = persons
    }
    
    
    
    
}
