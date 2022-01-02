//
//  LocationCell.swift
//  MyLocations
//
//  Created by Xiao Quan on 1/1/22.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with location: Location) {
        self.addressLabel.text = location.address
        self.descriptionLabel.text = location.locationDescription
    }

}
