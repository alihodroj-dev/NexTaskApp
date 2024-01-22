//
//  HomeViewModel.swift
//  NexTask
//
//  Created by Ali Hodroj on 22/01/2024.
//

import Foundation

final class HomeViewModel: ObservableObject {
    
    // DATA
    @Published var userName: String
    @Published var numberOfTasksToday: String
    
    // SHEETS STATES
    @Published var userNameSheetIsPresented: Bool = false
    
    init() {
        self.userName = UserDefaults.standard.string(forKey: "USERNAME") ?? ""
        self.numberOfTasksToday = "2"
    }
    
}
