//
//  TVcell.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 14/1/23.
//

import UIKit

class TVcell: UITableViewCell {

    @IBOutlet weak var tvCellTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTime: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tiles: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
