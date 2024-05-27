//
//  CustomTableViewCell.swift
//  ExpensesTracker-New
//
//  Created by Mayur Vaity on 25/05/24.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    @IBOutlet weak var expenseLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
