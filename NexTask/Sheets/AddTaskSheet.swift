//
//  AddTaskSheet.swift
//  NexTask
//
//  Created by Ali Hodroj on 22/01/2024.
//

import SwiftUI

struct AddTaskSheet: View {
    
    // viewModel
    @ObservedObject var viewModel: HomeViewModel
    
    // states
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var taskDueDate: Date = Date()
    @State var reminderOptions: String = "fiveMinutesBefore"
    
    var body: some View {
        // root
        ZStack {
            // background color
            Color.bg.ignoresSafeArea()
            // main container
            VStack(spacing: 10) {
                // task title
                HStack {
                    Text("Title")
                        .foregroundStyle(.accent)
                        .bold()
                    Spacer()
                }
                // title textfield
                TextField("", text: $taskTitle)
                    .frame(height: 20)
                    .padding(10)
                    .background { Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 12)) }
                // task description
                HStack {
                    Text("Description")
                        .foregroundStyle(.accent)
                        .bold()
                    Spacer()
                }
                // description textfield
                TextField("", text: $taskDescription)
                    .frame(height: 50)
                    .padding(10)
                    .background { Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 12)) }
                // date and time
                DatePicker("Date", selection: $taskDueDate, displayedComponents: [.date, .hourAndMinute])
                    .preferredColorScheme(.dark)
                    .foregroundStyle(.accent)
                    .datePickerStyle(.compact)
                    .bold()
                    .font(.title3)
                    .padding(.top)
                    .padding(.horizontal, 10)
                // reminder option
                HStack {
                    Text("Reminder")
                        .foregroundStyle(.accent)
                        .font(.title3)
                        .bold()
                    Spacer()
                    Picker("Reminder", selection: $reminderOptions) {
                        ForEach(ReminderOptions.allCases, id:\.self) { option in
                            Text(option.rawValue)
                                .tag(option.rawValue)
                        }
                    }
                    .background { Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 12))}
                }
                .padding(.top)
                .padding(.horizontal, 10)
                // save button
                Button {
                    if(!taskTitle.isEmpty && !taskDescription.isEmpty) {
                        viewModel.addTask(title: taskTitle, desc: taskDescription, dueDate: taskDueDate, isCompleted: false, option: reminderOptions)
                        viewModel.addTaskSheetIsPresented = false
                    }
                } label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .bold()
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background { Color.accentColor.clipShape(RoundedRectangle(cornerRadius: 12)) }
                        .padding(.top)
                        .padding(.horizontal)
                }

            }
            .padding(30)
        }
    }
}

#Preview {
    AddTaskSheet(viewModel: HomeViewModel())
}
