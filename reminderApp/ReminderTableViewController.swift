//
//  ReminderTableViewController.swift
//  reminderApp
//
//  Created by Aleksa on 17.07.2020.
//  Copyright © 2020 Aleksa. All rights reserved.
//

import UIKit

class ReminderTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reminder"
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    func sendNotification(datePicker: UIDatePicker, reminder: Base.Reminder) {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.name
        content.body = reminder.description
        content.badge = 1
        
        let date = datePicker.calendar.dateComponents([.day, .hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.guid, content: content, trigger: trigger)
        
        center.add(request) { (error) in }
        
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveSegue" else { return }
        
        let sourceViewController = segue.source as! NewReminderTableViewController
        var reminder = sourceViewController.reminder
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            Base.shared.info[selectedIndexPath.row] = reminder
            tableView.reloadRows(at: [selectedIndexPath], with: .fade)
            sendNotification(datePicker: sourceViewController.datePicker, reminder: reminder)
        } else {
            reminder = Base.Reminder(name: reminder.name, description: reminder.description, guid: UUID().uuidString)
            let newIndexPath = IndexPath(row: Base.shared.info.count, section: 0)

            Base.shared.info.reverse()
            Base.shared.info.append(reminder)
            Base.shared.info.reverse()
            
            tableView.insertRows(at: [newIndexPath], with: .fade)
            tableView.reloadData()
            
            sendNotification(datePicker: sourceViewController.datePicker, reminder: reminder)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Base.shared.info.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderTableViewCell
        
        let reminder = Base.shared.info[indexPath.row]
        print("Reminder: \(reminder)")
        cell.set(reminder: reminder)
        return cell
    }
     
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Base.shared.info.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedReminder = Base.shared.info.remove(at: sourceIndexPath.row)
        Base.shared.info.insert(movedReminder, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "editReminder" else {return}
        let indexPath = tableView.indexPathForSelectedRow!
        let reminder = Base.shared.info[indexPath.row]
        let navigationViewController = segue.destination as! UINavigationController
        let newReminderViewController = navigationViewController.topViewController as! NewReminderTableViewController
        newReminderViewController.reminder = reminder
        newReminderViewController.title = "Edit"
    }
}
