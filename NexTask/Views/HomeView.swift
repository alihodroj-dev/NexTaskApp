//
//  HomeView.swift
//  NexTask
//
//  Created by Ali Hodroj on 22/01/2024.
//

import SwiftUI

struct HomeView: View {
    
    init() {
        // styling the segmented picker
        UISegmentedControl.appearance().selectedSegmentTintColor = .accent
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.white], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor(white: 1, alpha: 0.05)
    }
    
    // ViewModel
    @ObservedObject private var viewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        // navigation root
        NavigationStack {
            // view root
            ZStack {
                // background color
                Color.bg.ignoresSafeArea()
                // main container
                VStack(spacing: 0) {
                    // topBar
                    HStack(spacing: 15) {
                        // image
                        Image("NexTaskLogo")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding(2)
                            .background { Color.accentColor }
                            .clipShape(Circle())
                        // welcome and todays' tasks
                        VStack(alignment: .leading, spacing: 5) {
                            // welcome text
                            Text(viewModel.userName == "" ? "Tap to enter your name" : "Hey " + viewModel.userName + ",")
                                .foregroundStyle(.white)
                                .font(.title2)
                                .bold()
                                .onTapGesture {
                                    viewModel.userNameSheetIsPresented = true
                                }
                            // todays' tasks
                            Text(String(viewModel.numberOfTasksToday) + " tasks for today")
                                .foregroundStyle(.gray)
                        }
                        // spacer
                        Spacer()
                        // add task button
                        Button {
                            viewModel.addTaskSheetIsPresented = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.accent)
                                .bold()
                                .frame(width: 35, height: 25)
                                .background { (RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 2)) }
                        }
                        
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    // search bar
                    HStack(spacing: 0) {
                        // icon
                        Image(systemName: "magnifyingglass")
                            .padding(.leading)
                            .foregroundStyle(.accent)
                            .bold()
                        // textfield
                        TextField("Search", text: $viewModel.searchValue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 35)
                            .padding(.leading)
                    }
                    .background { Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 12)) }
                    .padding(.horizontal)
                    // task list type picker
                    Picker("", selection: $viewModel.taskListTypeSelection) {
                        ForEach(TaskListType.allCases, id:\.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    // task list
                    ScrollView(.vertical) {
                        ForEach(viewModel.tasksShown) {
                            TaskView(task: $0, vm: viewModel)
                                .frame(maxHeight: 150)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                }
                // USERNAME SHEET
                .sheet(isPresented: $viewModel.userNameSheetIsPresented) {
                    UsernameSheet(viewModel: viewModel)
                        .presentationDetents([.fraction(0.2)])
                }
                // ADD TASK SHEET
                .sheet(isPresented: $viewModel.addTaskSheetIsPresented, content: {
                    AddTaskSheet(viewModel: viewModel)
                        .presentationDetents([.fraction(0.6)])
                })
            }
        }
    }
}

#Preview {
    HomeView()
}

@ViewBuilder
private func TaskView(task: TaskEntity, vm: HomeViewModel) -> some View {
    HStack(spacing: 10) {
        // title and desc
        VStack(alignment: .leading, spacing: 5) {
            Text("Title")
                .font(.caption)
                .foregroundStyle(.accent)
                .bold()
            Text(task.title!)
                .foregroundStyle(.white)
                .font(.headline)
                .lineLimit(nil)
            Text("Description")
                .font(.caption)
                .foregroundStyle(.accent)
                .bold()
            Text(task.desc!)
                .foregroundStyle(.white)
                .font(.caption)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.leading, 10)
        // line spacer
        RoundedRectangle(cornerRadius: 2)
            .foregroundStyle(.accent)
            .frame(width: 2)
            .padding(.vertical)
        // time and date
        VStack(alignment: .leading, spacing: 10) {
            if(task.dueDate!.timeIntervalSince1970 < Date.now.timeIntervalSince1970 && !task.isCompleted) {
                Text("OVERDUE")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.red)
            }
            HStack(spacing: 0) {
                Text("Due: ")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                Text(task.dueDate!.formatted(date: .abbreviated, time: .omitted) as String)
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.subheadline)
                    .fontWeight(.light)
                    .lineLimit(1)
            }
            HStack(spacing: 0) {
                Text("Time: ")
                    .foregroundStyle(.white)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                Text(task.dueDate!.formatted(date: .omitted, time: .shortened) as String)
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.subheadline)
                    .fontWeight(.light)
                    .lineLimit(1)
            }
        }
        // line spacer
        RoundedRectangle(cornerRadius: 2)
            .foregroundStyle(.accent)
            .frame(width: 2)
            .padding(.vertical)
        // mark as completed and delete
        VStack(spacing: 5) {
            // completed button
            if(!task.isCompleted) {
                Button {
                    vm.updateTask(task: task)
                } label: {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundStyle(.accent)
                        .font(.title)
                }
            }
            // delete button
            Button {
                vm.deleteTask(task: task)
            } label: {
                Image(systemName: "trash.square.fill")
                    .foregroundStyle(.accent)
                    .font(.title)
            }
        }
        .padding(.vertical)
        .padding(.trailing, 10)
    }
    .frame(maxWidth: .infinity)
    .background { Color.accentColor.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 12)) }
}

