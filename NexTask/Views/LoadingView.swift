//
//  LoadingView.swift
//  NexTask
//
//  Created by Ali Hodroj on 21/01/2024.
//

import SwiftUI

struct LoadingView: View {
    
    // animation states
    @State private var scaleFactor: Double = 1
    @State private var opacityFactor: Double = 1
    
    var body: some View {
        // root
        ZStack {
            HomeView()
            // background color
            Color.bg.ignoresSafeArea().opacity(opacityFactor)
            // logo image
            Image("NexTaskLogo")
                .resizable()
                .frame(width: 150, height: 150)
                .scaleEffect(scaleFactor)
                .opacity(opacityFactor)
        }
        // performing animtation
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.bouncy(duration: 0.25)) {
                    scaleFactor = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeIn(duration: 0.35)) {
                        scaleFactor = 20
                        opacityFactor = 0
                    }
                    
                }
            }
        }
    }
}

#Preview {
    LoadingView()
}
