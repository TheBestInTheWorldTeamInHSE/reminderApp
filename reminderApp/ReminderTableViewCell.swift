 //
 //  RemindTableViewCell.swift
 //  reminderApp
 //
 //  Created by Aleksa on 17.07.2020.
 //  Copyright © 2020 Aleksa. All rights reserved.
 //
 
 import UIKit
 
 class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var checked: Bool = false
    
    @IBOutlet weak var donButton: UIButton!
    
    @IBAction func donButton(_ sender: UIButton) {
        checked = !checked
        if checked {
            sender.tintColor = .blue
            donButton.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
//            donButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            nameLabel.textColor = .lightGray
            descriptionLabel.textColor = .lightGray
//            self.isHidden = true
//            design
        } else {
            sender.tintColor = .opaqueSeparator
            donButton.setImage(UIImage(systemName: "circle"), for: .normal)
            nameLabel.textColor = .black
            descriptionLabel.textColor = .systemGray2
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(reminder: Base.Reminder) {
        self.nameLabel.text = reminder.name
        self.descriptionLabel.text = reminder.description
        
        // print(self.nameLabel.text!)
        // print(self.descriptionLabel.text!)
    }
    
    
 }
 
