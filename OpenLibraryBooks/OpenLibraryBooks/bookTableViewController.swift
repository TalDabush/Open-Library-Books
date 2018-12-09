//
//  bookTableViewController.swift
//  OpenLibraryBooks
//
//  Created by Tal on 06/12/2018.
//  Copyright © 2018 Tal. All rights reserved.
//

import UIKit
import SwiftyJSON
import os.log


class bookTableViewController: UITableViewController, UISearchBarDelegate {
    
    var books = [Book]()
    let searchBar = UISearchBar()


    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Enter a book name"
        
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchBar
        
  }
    
    //MARK: SearchBar deligate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked")
        searchBar.resignFirstResponder()
        if let searchText = searchBar.text{
            // Reload the table view with the search result data.
           self.createIndicatorAndStart()
            getBooksFromOpenLibrary(searchText)
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
       return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BookTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell else{
            fatalError("the dequed cell is not an instance of bookTableViewCell")
        }
        let book = books[indexPath.row]
        //print (book)
        cell.titleLabel.text = book.title
        if let author = book.author{
            cell.authorLabel.text = author
        }
        else{
            cell.authorLabel.text = "Author name not available"
        }
        return cell
    }
 
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        //confirm that this is the appropriate segue
        if segue.identifier == "showData"{
            //confirm that the dest is the BookViewController
            guard let BookDetailViewController = segue.destination as? ViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            //confirm that sending a book cell
            guard let selectedBookCell = sender as? BookTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            //confirm that the index of this book cell exists and get him
            guard let indexPath = tableView.indexPath(for: selectedBookCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //get the selected book from books array
            let selectedBook = books[indexPath.row]
            //set book property for the destination segue
            //print ("sending author: \(selectedBook.author)")
            BookDetailViewController.book = selectedBook
            
            
        }
        
    }

    
    //MARK: Private Methods
    
    private func getBooksFromOpenLibrary(_ query: String){
        
        let url = createSearchBookURL(query)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error ) in
            
            //check if there was an error
            guard error == nil else {
                print("returned error")
                return
            }
            
            //check if data is not nil
            guard let content = data else {
                print("No data")
                return
            }
            
            //iterate through the results and get info
            do{
                let json = try JSON(data: content)
                self.books.removeAll()
                for (key, subJson) in json["docs"]{
                    let title = self.getFromJsonDocs(subJson, key, "title")
                    let author = self.getFromJsonDocs(subJson, key, "author_name")
                    let coverID = self.getCoverID(subJson, key)
//                    if coverID.name != "error"{
//                        coverImage = self.getCoverImageByID(coverID)
//                    }
                    let contributors = self.getFromJsonDocsArrays(subJson, key, "contributor")
                    let subjects = self.getFromJsonDocsArrays(subJson, key, "subject")
                    let first_publish_year = self.getIntFromJsonDocs(subJson, key, "first_publish_year")
                    let persons = self.getFromJsonDocsArrays(subJson, key, "person")
//                    let book = Book(title!, author, coverImage, contributors, subjects, first_publish_year, persons)
                    //print (key, book, book.title)
                    self.books.append(Book(title!, author, coverID, contributors, subjects, first_publish_year, persons))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.stopIndicator()
                    }
                }

            }
            catch{
                print(error)
            }
        }
        task.resume()
    }
    
    

    private func createSearchBookURL(_ query: String)-> URL?{
        var components = URLComponents()
        components.scheme = "http"
        components.host = "openlibrary.org"
        components.path = "/search.json"
        let queryItem = URLQueryItem (name: "q", value: query)
        components.queryItems = [queryItem]
        let url = components.url
        return url
    }
    
    private func getFromJsonDocsArrays(_ json: JSON, _ key: String, _ toGet:String)-> [String]?{
        let ans = json[toGet].arrayValue.map({$0.stringValue})
        if ans == []{
            return nil
        }
        return ans
    }
    
    private func getFromJsonDocs(_ json: JSON, _ key: String, _ toGet:String)-> String?{
        
        if let ans = json[toGet].string{
            return ans
        }
        else if let ans = json[toGet][0].string{
            return ans
        }
        return nil
        
    }
    
    private func getIntFromJsonDocs(_ json: JSON, _ key: String, _ toGet:String)-> Int?{
        return json[toGet].int
    }
    
    private func getCoverID(_ json: JSON, _ key: String)-> (name: String, code: String?){
        
        if let ID = json["oclc"][0].string{
            return ("oclc", ID)
        }
        else if let ID = json["isbn"][0].string{
            return ("isbn", ID)
        }
        else{
            return ("error", nil)
        }
    }
    
    private func createIndicatorAndStart(){
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        let indicatorTag = 123
        indicator.tag = indicatorTag
    }
    
    private func stopIndicator(){
        if let indicator: UIActivityIndicatorView = self.view.viewWithTag(123) as? UIActivityIndicatorView{
            indicator.stopAnimating()
        }
    }
    
    
}

