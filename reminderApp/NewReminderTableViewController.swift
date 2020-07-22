//
//  NewReminderTableViewController.swift
//  reminderApp
//
//  Created by Aleksa on 17.07.2020.
//  Copyright © 2020 Aleksa. All rights reserved.
//

import UIKit

class NewReminderTableViewController: UITableViewController {
    
    var reminder = Base.Reminder(name: "", description: "", guid: "", DATE: "")
    public let defaults = UserDefaults.standard
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    public let datePicker = UIDatePicker()
    
    func createDatePicker() {
        dateTextField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateTextField.text = formatter.string(from: datePicker.date)
        
        
        updateSaveButtonState()
    }
    
    @objc func tapGestureDone() {
        view.endEditing(true)
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func textChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let nameLen = nameTextField.text?.count
        let dateLen = dateTextField.text?.count
        
        saveButton.isEnabled = nameLen ?? 0 > 0 && dateLen ?? 0 > 0
    }
    
    private func updateUI() {
        nameTextField.text = reminder.name
        descriptionTextField.text = reminder.description
        dateTextField.text = reminder.DATE
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()
        createDatePicker()
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "saveSegue" else { return }
        
        let name = nameTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        let datee = dateTextField.text ?? ""
        
        self.reminder = Base.Reminder(name: name, description: description, guid: self.reminder.guid, DATE: datee)
    }
    
   
    
}
