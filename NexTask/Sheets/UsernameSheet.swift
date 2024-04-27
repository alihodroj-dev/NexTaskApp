//
//  UsernameSheet.swift
//  NexTask
//
//  Created by Ali Hodroj on 22/01/2024.
//

import SwiftUI

struct UsernameSheet: View {
    
    // viewModel
    @ObservedObject var viewModel: HomeViewModel
    // textfield value
    @State private var name: String = ""
    // error message state
    @State private var errorMessageOpacity: Double = 0
    
    var body: some View {
        // root
        ZStack {
            // background color
            Color.bg.ignoresSafeArea()
            // main container
            VStack(spacing: 10) {
                // main text
                HStack {
                    Text(" Name")
                        .foregroundStyle(.accent)
                        .bold()
                    Spacer()
                }
                // textfield and save button
                HStack {
                    // textfield
                    TextField("", text: $name)
                        .frame(height: 20)
                        .padding(10)
                        .background { Color.gray.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 12)) }
                    // save button
                    Button {
                        self.saveName(name)
                    } label: {
                        Text("Save")
                            .foregroundStyle(.white)
                            .bold()
                            .frame(width: 80, height: 20)
                            .padding(8)
                            .background { Color.accentColor.clipShape(RoundedRectangle(cornerRadius: 12)) }
                    }
                }
                // error message
                HStack {
                    Text(" Field should not be empty!")
                        .foregroundStyle(.red)
                        .font(.caption)
                        .opacity(errorMessageOpacity)
                    Spacer()
                }
            }
            .padding(30)
        }
    }
    
    private func saveName(_ name: String) {
        // checking if name is not empty
        if(!name.isEmpty) {
            // saving
            UserDefaults.standard.set(name, forKey: "USERNAME")
            // updating the UI
            withAnimation(.easeIn) {
                viewModel.userName = name
            }
            // dismissing the sheet
            viewModel.userNameSheetIsPresented = false
        } else {
            // error message animation
            withAnimation(.bouncy()) {
                self.errorMessageOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.bouncy()) {
                    self.errorMessageOpacity = 0
                }
            }
        }
    }
}

#Preview {
    UsernameSheet(viewModel: HomeViewModel())
}
