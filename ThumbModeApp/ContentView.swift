//
//  ContentView.swift
//  OMSDemo
//
//  Created by Takuto Nakamura on 2024/03/02.
//

import OpenMultitouchSupport
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack {
           
           
        }
        .fixedSize()
        .padding()
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }


}

#Preview {
    ContentView()
}
