//
//  BookTableViewCell.swift
//  OpenLibraryBooks
//
//  Created by Tal on 06/12/2018.
//  Copyright © 2018 Tal. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
