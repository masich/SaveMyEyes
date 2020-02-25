//
//  ContentView.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import SwiftUI

struct PopoverContent: View {
    // TODO: make it possible to take these values from user
    private let timeIntervals = [15, 20, 30, 40, 60, 90, 120]
    private let breakTimes = [2, 3, 5, 10, 15, 20, 30]
    
    @State private var isBreakNow = false
    @State private var remainingMins: Int = 0
    @State private var timer: Timer?
    @State private var shouldTimerRun: Bool = false
    @State private var selectedTimeInterval: Int = getSelectedTimeIntervalValue() ?? 0
    @State private var selectedBreakTime: Int = getSelectedBreakTimeValue() ?? 0
    
    init() {
        _remainingMins = State<Int>.init(initialValue: isBreakNow ? breakTimes[selectedBreakTime] : timeIntervals[selectedTimeInterval])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 20) {
                Text(isBreakNow ? "Time to work" : "Time to break")
                Spacer()
                Text("\(remainingMins) \("min".localized)")
            }.scaledToFill()
            Divider()
            HStack(spacing: 20) {
                Text("Run timer")
                Spacer()
                Toggle("Run timer toggle", isOn: $shouldTimerRun.onChange(toggleTimer)).labelsHidden()
            }.scaledToFill()
            HStack(spacing: 20) {
                Text("Time interval")
                Spacer()
                Picker("Time interval picker", selection: $selectedTimeInterval.onChange(applyTimeIntervalValue)) {
                    ForEach(timeIntervals.indices, id: \.self) { index in
                        Text(String(self.timeIntervals[index])).tag(index)
                    }
                }.labelsHidden().scaledToFit().fixedSize()
            }
            HStack(spacing: 20) {
                Text("Break time")
                Spacer()
                Picker("Break time picker", selection: $selectedBreakTime.onChange(applyBreakTimeValue)) {
                    ForEach(breakTimes.indices, id: \.self) { index in
                        Text(String(self.breakTimes[index])).tag(index)
                    }
                }.labelsHidden().scaledToFit().fixedSize()
            }
            Divider()
            Button("Quit", action: AppDelegate.terminateApp).buttonStyle(BorderlessButtonStyle())
        }.padding().fixedSize()
    }
    
    func toggleTimer(_ shouldTimerRun: Bool) {
        if shouldTimerRun {
            timer = createTimer(timerHandler)
        } else {
            timer?.invalidate()
        }
    }
    
    func applyTimeIntervalValue(_ timeIntervalIndex: Int) {
        if !isBreakNow {
            remainingMins = timeIntervals[timeIntervalIndex]
        }
        setSelectedTimeIntervalValue(timeIntervalIndex)
    }
    
    // Creates timer which will be invoking handler every 60 seconds
    func createTimer(_ handler: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: handler)
    }
    
    func timerHandler(timer: Timer) {
        remainingMins -= 1
        if remainingMins <= 0 {
            if isBreakNow {
                remainingMins = timeIntervals[selectedTimeInterval]
            } else {
                remainingMins = breakTimes[selectedBreakTime]
            }
            isBreakNow = !isBreakNow
            sendNotification(isBreakNow)
        }
    }
    
    func applyBreakTimeValue(_ breakTimeIndex: Int) {
        if isBreakNow {
            remainingMins = breakTimes[breakTimeIndex]
        }
        setSelectedBreakTimeValue(breakTimeIndex)
    }
    
    func sendNotification(_ isNotificationForBreak: Bool) {
        let notification: AppNotification
        if isNotificationForBreak {
            notification = AppNotification(title: "It's time for break".localized, subtitle: String(format: "Relax from your computer for %d minutes.".localized, breakTimes[selectedBreakTime]))
        } else {
            notification = AppNotification(title: "It's time to work".localized, subtitle: "Let's continue to do amazing things!".localized)
        }
        notification.send()
    }
}
