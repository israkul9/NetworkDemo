//
//  MovieCell.swift
//  NetworkDemo
//
//  Created by Tusher on 1/17/24.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(movie : Movie){
        self.titleLabel.text = movie.title
        self.descriptionLabel.text = movie.overview
    }
}
