//
//  ViewController.swift
//  OpenLibraryBooks
//
//  Created by Tal on 05/12/2018.
//  Copyright © 2018 Tal. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    
    
    var book: Book?
  
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("view did load")
        
        if let book = book {
            print ("got book")
            bookTitle.text = book.title
            print ("title: \(bookTitle.text!)")

            if let bookAuthor = book.author{
                print (bookAuthor)
                author.text = book.author
            }
            getCoverImageByID(book.coverID)

        }
    }
    
    
    //MARK: Private Methods
    private func getCoverImageByID(_ coverID: (name: String, code: String?)){
        if let coverCode = coverID.code{
            let url = self.createImageUrl(coverID)
            self.createIndicatorAndStart()
            
            var coverImage: UIImage?
            let task = URLSession.shared.dataTask(with: url!) {(data, response, error ) in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 404{
                        self.createNoImageLabel()
                    }
                    
                    // do stuff.
                }
                //check if there was an error
                if error != nil{
                    print("returned error")
                    coverImage = nil
                }

                //check if data is not nil
                if let content = data{
                    coverImage = UIImage(data: content)
                    DispatchQueue.main.async {
                        self.stopIndicatorAndRemove()
                        self.coverImage.image = coverImage
                    }
                }
                else{
                    print("No data")
                    coverImage = nil
                }


            }
            task.resume()
        }
        else{
            
            self.createNoImageLabel()

        }

    }

    
    private func createNoImageLabel(){
        print("creating no image label")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = self.view.center
        label.textAlignment = .center
        label.text = "no cover image to show"
        self.view.addSubview(label)
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
    
    private func stopIndicatorAndRemove(){
        if let indicator: UIActivityIndicatorView = self.view.viewWithTag(123) as? UIActivityIndicatorView{
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
    private func createImageUrl(_ coverID: (name: String, code: String?)) -> URL?{
        var urlString: String = "http://covers.openlibrary.org/b/"
        urlString += coverID.name + "/" + coverID.code! + "-L.jpg?default=false"
        print (urlString)
        let url = URL(string: urlString)
        return url
    }
}



