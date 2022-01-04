//
//  LocationCell.swift
//  MyLocations
//
//  Created by Xiao Quan on 1/1/22.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.bounds.size.width / 6
        thumbnailImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with location: Location) {
        addressLabel.text = location.address
        descriptionLabel.text = location.locationDescription
        thumbnailImageView.image = thumbnail(for: location)
    }

    func thumbnail(for location: Location) -> UIImage {
      if location.hasPhoto, let image = location.photoImage {
          return image.resized(withBounds: CGSize(
            width: 68,
            height: 68))
      }
        return UIImage(systemName: "questionmark.app")!
    }

}
