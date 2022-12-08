//
//  ListUserTableViewCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit

protocol ListUserTableViewCellDelegate {
    func showAvatar()
}
class ListUserTableViewCell: UITableViewCell {
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var lmMessage: UILabel!
    @IBOutlet private weak var imgAvt: UIImageView!
    var delegate: ListUserTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvt.contentMode = .scaleToFill
        imgAvt.layer.cornerRadius = imgAvt.frame.height / 2
        imgAvt.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(_ user: UserRespone) {
        self.lbNameUser.text = user.name
        ImageService.share.fetchImage(with: user.avatar) { image in
            DispatchQueue.main.async {
                self.imgAvt.image = image
            }
        }
         
    }

}
