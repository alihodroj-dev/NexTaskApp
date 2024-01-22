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
                            Text(viewModel.numberOfTasksToday + " tasks for today")
                                .foregroundStyle(.white)
                        }
                        // spacer
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            // USERNAME SHEET
            .sheet(isPresented: $viewModel.userNameSheetIsPresented) {
                UsernameSheet(viewModel: viewModel)
                    .presentationDetents([.fraction(0.2)])
            }
        }
    }
}

#Preview {
    HomeView()
}
