//
//  HomeView.swift
//  NexTask
//
//  Created by Ali Hodroj on 22/01/2024.
//

import SwiftUI

struct HomeView: View {
    
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
                VStack {
                    // topBar
                    HStack(spacing: 15) {
                        // pfp
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
                                .foregroundStyle(.white)
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
                    // body
                    // due today tasks
                    VStack {
                        HStack {
                            // title
                            Text("Due Today")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold()
                            Spacer()
                            // view all button
                            Button {
                                // todo
                            } label: {
                                Text("View all")
                                    .foregroundStyle(.accent)
                            }
                            
                        }
                        .padding()
                        // first two tasks
                        
                        ForEach(viewModel.todayTaskEntities) { task in
                            Text(task.title!)
                        }
                        
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background { Color.black.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 22)) }
                    .padding(.horizontal)
                    // Upcoming tasks
                    VStack {
                        HStack {
                            // title
                            Text("Upcoming")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold()
                            Spacer()
                            // view all button
                            Button {
                                // todo
                            } label: {
                                Text("View all")
                                    .foregroundStyle(.accent)
                            }
                            
                        }
                        .padding()
                        
                        ScrollView(.vertical) {
                            ForEach(viewModel.upcomingTaskEntities) { task in
                                Text(task.title!)
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background { Color.black.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 22)) }
                    .padding(.horizontal)
                    // completed tasks
                    VStack {
                        HStack {
                            // title
                            Text("Completed")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold()
                            Spacer()
                            // view all button
                            Button {
                                // todo
                            } label: {
                                Text("View all")
                                    .foregroundStyle(.accent)
                            }
                            
                        }
                        .padding()
                        
                        ScrollView(.vertical) {
                            ForEach(viewModel.completedTaskEntities) { task in
                                Text(task.title!)
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background { Color.black.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 22)) }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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

#Preview {
    HomeView()
}
