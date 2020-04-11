//
//  ContentView.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import SwiftUI


struct MainView: View {
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 20) {
                Text(mainViewModel.isBreakTimeNow ? "Time to work" : "Time to break")
                Spacer()
                Text("\(mainViewModel.remainingMins) \("min".localized)")
            }.scaledToFill()
            Divider()
            HStack(spacing: 20) {
                Text("Run timer")
                Spacer()
                Toggle("Run timer toggle", isOn: self.$mainViewModel.shouldTimerRun.value).labelsHidden()
            }.scaledToFill()
            HStack(spacing: 20) {
                Text("Enable sound")
                Spacer()
                Toggle("Enable sound toggle", isOn: self.$mainViewModel.isSoundEnabled.value).labelsHidden()
            }.scaledToFill()
            HStack(spacing: 20) {
                Text("Work interval")
                Spacer()
                Picker("Work interval picker", selection: self.$mainViewModel.workIntervalIndex.value) {
                    ForEach(mainViewModel.workIntervals.indices, id: \.self) { index in
                        Text(String(self.mainViewModel.workIntervals[index])).tag(index)
                    }
                }.labelsHidden().scaledToFit().fixedSize()
            }
            HStack(spacing: 20) {
                Text("Break interval")
                Spacer()
                Picker("Break interval picker", selection: self.$mainViewModel.breakIntervalIndex.value) {
                    ForEach(mainViewModel.breakIntervals.indices, id: \.self) { index in
                        Text(String(self.mainViewModel.breakIntervals[index])).tag(index)
                    }
                }.labelsHidden().scaledToFit().fixedSize()
            }
            Divider()
            Button("Quit", action: mainViewModel.terminateApp).buttonStyle(BorderlessButtonStyle())
        }.padding().fixedSize()
    }
}
