//
//  HomeViewModel.swift
//  NexTask
//
//  Created by Ali Hodroj on 22/01/2024.
//

import Foundation
import CoreData
import SwiftUI
import UserNotifications

final class HomeViewModel: ObservableObject {
    
    // UI
    @Published var userName: String
    @Published var numberOfTasksToday: Int = 0
    
    // SHEET STATES
    @Published var userNameSheetIsPresented: Bool = false
    @Published var addTaskSheetIsPresented: Bool = false
    
    // CORE DATA
    let container: NSPersistentContainer
    @Published var todayTaskEntities: [TaskEntity] = []
    @Published var upcomingTaskEntities: [TaskEntity] = []
    @Published var completedTaskEntities: [TaskEntity] = []
    
    init() {
        // UI SETUP
        self.userName = UserDefaults.standard.string(forKey: "USERNAME") ?? ""
        
        // CORE DATA SETUP
        self.container = NSPersistentContainer(name: "TasksContainer")
        container.loadPersistentStores { desc, err in
            if let _ = err {
                print("Error loading coreData")
            } else {
                print("LOADED CORE DATA SUCCESSFULLY")
                withAnimation(.bouncy) {
                    self.fetchTasks()
                }
            }
        }
        // NOTIFICATIONS
        checkNotificationPermission()
    }
    
    func fetchTasks() {
        // creating fetch request
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        // fetching request
        var fetchedTasks: [TaskEntity] = []
        do {
            // trying to save
            fetchedTasks = try self.container.viewContext.fetch(request)
        } catch {
            // handling errors
            print("error fetching")
        }
        // reseting data before adding new data
        self.todayTaskEntities = []
        self.upcomingTaskEntities = []
        self.completedTaskEntities = []
        // filtering tasks
        for task in fetchedTasks {
            if(task.isCompleted) {
                self.completedTaskEntities.append(task)
                self.numberOfTasksToday += 1
            } else {
                let dateDay = Calendar.current.dateComponents([.day], from: task.dueDate!)
                let today = Calendar.current.dateComponents([.day], from: Date.now)
                if(dateDay == today) {
                    self.todayTaskEntities.append(task)
                } else {
                    self.upcomingTaskEntities.append(task)
                }
            }
        }
    }
    
    func addTask(title: String, desc: String, dueDate: Date, isCompleted: Bool, option: String) {
        let newTask = TaskEntity(context: container.viewContext)
        newTask.title = title
        newTask.desc = desc
        newTask.dueDate = dueDate
        newTask.isCompleted = isCompleted
        
        // adding notification
        scheduleNotification(title: title, desc: desc, dueDate: dueDate, option: option)
        // saving
        self.saveData()
    }
    
    func saveData() {
        do {
            // saving
            try container.viewContext.save()
            // fetching data again to update UI
            self.fetchTasks()
        } catch {
            print("error saving")
        }
    }
    
}

// HELPER FUNCTION
private func scheduleNotification(title: String, desc: String, dueDate: Date, option: String) {
    // creating notification date
    let notificationDate: Date
    switch option {
    case "fiveMinutesBefore":
        notificationDate = Date(timeIntervalSince1970: dueDate.timeIntervalSince1970 - 300)
    case "thirtyMinutesBefore":
        notificationDate = Date(timeIntervalSince1970: dueDate.timeIntervalSince1970 - 1800)
    case "oneHourBefore":
        notificationDate = Date(timeIntervalSince1970: dueDate.timeIntervalSince1970 - 3600)
    case "oneDayBefore":
        notificationDate = Date(timeIntervalSince1970: dueDate.timeIntervalSince1970 - 86400)
    case "oneWeekBefore":
        notificationDate = Date(timeIntervalSince1970: dueDate.timeIntervalSince1970 - 604800)
    default:
        notificationDate = dueDate
    }
    // creating content
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = desc
    content.sound = .default
    // creating trigger
    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate), repeats: false)
    // creating request
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    // adding notification request to center
    UNUserNotificationCenter.current().add(request)
}

private func checkNotificationPermission() {
    // getting current noti center
    let current = UNUserNotificationCenter.current()

    current.getNotificationSettings(completionHandler: { (settings) in
        if settings.authorizationStatus == .notDetermined {
            // asking for permission + delaying until loading animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                current.requestAuthorization(options: [.alert, .badge, .sound]) { result, err in
                    if result {
                        print("Notifications Allowed")
                    } else {
                        print(err?.localizedDescription ?? "")
                    }
                }
            }
        } else if settings.authorizationStatus == .denied {
            // asking for permission + delaying until loading animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                current.requestAuthorization(options: [.alert, .badge, .sound]) { result, err in
                    if result {
                        print("Notifications Allowed")
                    } else {
                        print(err?.localizedDescription ?? "")
                    }
                }
            }
        }
    })
}
