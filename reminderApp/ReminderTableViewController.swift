//
//  ReminderTableViewController.swift
//  reminderApp
//
//  Created by Aleksa on 17.07.2020.
//  Copyright © 2020 Aleksa. All rights reserved.
//

import UIKit

class ReminderTableViewController: UITableViewController, UNUserNotificationCenterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Reminder"
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        checkNotificationSettings(center: UNUserNotificationCenter.current())
        
        for i in 0 ..< Base.shared.info.count {
            print("Name: \(Base.shared.info[i].name) Description: \(Base.shared.info[i].description)")
        }
    }

    func checkNotificationSettings(center: UNUserNotificationCenter) {
        
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                // Notification permission has not been asked yet, go for it!
                center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
            } else if settings.authorizationStatus == .denied {
                // Notification permission was previously denied, go to settings & privacy to re-enable
            } else if settings.authorizationStatus == .authorized {
                // Notification permission was already granted
            }
        })
    }
    
    func sendNotification(datePicker: UIDatePicker, reminder: Base.Reminder) {
        
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        let content = UNMutableNotificationContent()
        content.title = reminder.name
        content.body = reminder.description
        content.categoryIdentifier = "category"
        
        let date = datePicker.calendar.dateComponents([.day, .hour, .minute], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.guid, content: content, trigger: trigger)
        
        let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Snooze", options: [])
//        let doneAction = UNNotificationAction(identifier: "done", title: "Done", options: [])
        let category = UNNotificationCategory(identifier: "category", actions: [snoozeAction], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])

        center.add(request) { (error) in }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "snooze" {
            var dayComponent = DateComponents()
            dayComponent.minute = 9
            let theCalendar = Calendar.current
            let nextDate = theCalendar.date(byAdding: dayComponent, to: Date())
            let comps = Calendar.current.dateComponents([.day, .hour, .minute], from: nextDate!)

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: response.notification.request.identifier,
                                                content: response.notification.request.content, trigger: trigger)
//            print(response.notification.request.identifier)
//            print(response.notification.request.content)
//            print(comps)
            center.add(request) { (error) in }
        }
        
        completionHandler()
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

            Base.shared.info.append(reminder)
            
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
        // print("Reminder: \(reminder)")
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
