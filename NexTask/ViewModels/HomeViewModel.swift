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
    @Published var searchValue: String = "" {
        didSet {
            if(!self.searchValue.isEmpty) {
                switch taskListTypeSelection {
                case .DueToday:
                    self.tasksShown = self.todayTaskEntities.filter({ task in
                        if(task.title!.contains(self.searchValue)) {
                            return true
                        } else {
                            return false
                        }
                    })
                case .Upcoming:
                    self.tasksShown = self.upcomingTaskEntities.filter({ task in
                        if(task.title!.contains(self.searchValue)) {
                            return true
                        } else {
                            return false
                        }
                    })
                case .Completed:
                    self.tasksShown = self.completedTaskEntities.filter({ task in
                        if(task.title!.contains(self.searchValue)) {
                            return true
                        } else {
                            return false
                        }
                    })
                }
            } else {
                withAnimation(.easeInOut) {
                    switch taskListTypeSelection {
                    case .DueToday:
                        self.tasksShown = self.todayTaskEntities
                    case .Upcoming:
                        self.tasksShown = self.upcomingTaskEntities
                    case .Completed:
                        self.tasksShown = self.completedTaskEntities
                    }
                }
            }
        }
    }
    @Published var taskListTypeSelection: TaskListType = .DueToday {
        didSet {
            withAnimation(.bouncy) {
                switch self.taskListTypeSelection {
                case .DueToday:
                    self.tasksShown = self.todayTaskEntities
                case .Upcoming:
                    self.tasksShown = self.upcomingTaskEntities
                case .Completed:
                    self.tasksShown = self.completedTaskEntities
                }
            }
            
        }
    }
    @Published var tasksShown: [TaskEntity] = []
    
    // SHEET STATES
    @Published var userNameSheetIsPresented: Bool = false
    @Published var addTaskSheetIsPresented: Bool = false
    
    // CORE DATA
    var container: NSPersistentContainer
    @Published var todayTaskEntities: [TaskEntity] = [] {
        didSet {
            if(self.taskListTypeSelection == .DueToday) {
                withAnimation(.bouncy) {
                    self.tasksShown = self.todayTaskEntities
                }
            }
        }
    }
    @Published var upcomingTaskEntities: [TaskEntity] = [] {
        didSet {
            if(self.taskListTypeSelection == .Upcoming) {
                withAnimation(.bouncy) {
                    self.tasksShown = self.upcomingTaskEntities
                }
            }
        }
    }
    @Published var completedTaskEntities: [TaskEntity] = [] {
        didSet {
            if(self.taskListTypeSelection == .Completed) {
                withAnimation(.bouncy) {
                    self.tasksShown = self.completedTaskEntities
                }
            }
        }
    }
    
    // SETUP
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
                self.fetchTasks()
            }
        }
        // NOTIFICATIONS SETUP
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
        self.tasksShown = []
        self.todayTaskEntities = []
        self.upcomingTaskEntities = []
        self.completedTaskEntities = []
        self.numberOfTasksToday = 0
        // filtering tasks
        withAnimation(.bouncy) {
            for task in fetchedTasks {
                if(task.isCompleted) {
                    self.completedTaskEntities.append(task)
                } else {
                    let dateDay = Calendar.current.dateComponents([.day], from: task.dueDate!)
                    let today = Calendar.current.dateComponents([.day], from: Date.now)
                    if(dateDay == today) {
                        self.todayTaskEntities.append(task)
                        self.numberOfTasksToday += 1
                    } else {
                        let taskDayInSeconds = task.dueDate!.timeIntervalSince1970
                        let todayDateInSeconds = Date.now.timeIntervalSince1970
                        if(taskDayInSeconds < todayDateInSeconds) {
                            self.todayTaskEntities.insert(task, at: 0)
                        } else {
                            self.upcomingTaskEntities.append(task)
                        }
                    }
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
    
    func deleteTask(task: TaskEntity) {
        self.container.viewContext.delete(task)
        self.saveData()
    }
    
    func updateTask(task: TaskEntity) {
        task.isCompleted = true
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
