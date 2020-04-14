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
            HStack(spacing: 8) {
                Text(mainViewModel.isBreakTimeNow ? "Time to work" : "Time to break")
                Spacer()
                HStack(spacing: 4) {
                    Text("\(self.mainViewModel.remainingMins)").frame(width: 36, alignment: .trailing)
                    Text("min")
                }
            }
            Divider()
            HStack(spacing: 8) {
                Text("Run timer")
                Spacer()
                Toggle("Run timer toggle", isOn: self.$mainViewModel.shouldTimerRun.value).labelsHidden()
            }
            HStack(spacing: 8) {
                Text("Enable sound")
                Spacer()
                Toggle("Enable sound toggle", isOn: self.$mainViewModel.isSoundEnabled.value).labelsHidden()
            }
            HStack(spacing: 8) {
                Text("Work interval")
                Spacer()
                Stepper(value: self.$mainViewModel.workInterval.value, in: Constants.workIntervalRange) {
                    HStack(spacing: 4) {
                        Text("\(self.mainViewModel.workInterval.value)").frame(width: 36, alignment: .trailing)
                        Text("min")
                    }
                }
            }
            HStack(spacing: 8) {
                Text("Break interval")
                Spacer()
                Stepper(value: self.$mainViewModel.breakInterval.value, in: Constants.breakIntervalRange) {
                    HStack(spacing: 4) {
                        Text("\(self.mainViewModel.breakInterval.value)").frame(width: 36, alignment: .trailing)
                        Text("min")
                    }
                }
            }
            Divider()
            HStack(spacing: 8) {
                Button("Quit", action: mainViewModel.terminateApp).buttonStyle(BorderlessButtonStyle())
                Spacer()
                Button("Reset", action: mainViewModel.resetToDefaults).buttonStyle(BorderlessButtonStyle())
            }
        }.padding().fixedSize().scaledToFill()
    }
}
