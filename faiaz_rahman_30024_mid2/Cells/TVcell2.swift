//
//  TVcell2.swift
//  faiaz_rahman_30024_mid2
//
//  Created by Faiaz Rahman on 15/1/23.
//

import UIKit

class TVcell2: UITableViewCell {

    @IBOutlet weak var imageViewBVC: UIImageView!
    
    @IBOutlet weak var titleBVC: UILabel!
    @IBOutlet weak var authorText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var catNameText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
