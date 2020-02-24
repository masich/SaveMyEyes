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
    private let timeIntervals = [15, 20, 25, 30, 40, 60, 90]
    private let breakTimes = [5, 10, 15, 20, 25, 30]
    
    @State private var isBreakNow = false
    @State private var shouldTimerRun: Bool = false
    @State private var selectedTimeInterval: Int = 0
    @State private var selectedBreakTime: Int = 0
    @State private var remainingMins: Int = 0
    @State private var timer: Timer?
    
    init() {
        _remainingMins = State<Int>.init(initialValue: isBreakNow ? breakTimes[selectedBreakTime] : timeIntervals[selectedTimeInterval])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(isBreakNow ? "Time to work:" : "Time to break:")
                Spacer()
                Text("\(remainingMins) min")
            }.scaledToFill()
            Divider()
            HStack {
                Text("Run timer")
                Spacer()
                Toggle("Run timer toggle", isOn: $shouldTimerRun.onChange(toggleTimer)).labelsHidden()
            }.scaledToFill()
            HStack {
                Text("Time interval")
                Spacer()
                Picker("Time interval picker", selection: $selectedTimeInterval.onChange(applyTimerSettings)) {
                    ForEach(timeIntervals.indices, id: \.self) { index in
                        Text(String(self.timeIntervals[index])).tag(index)
                    }
                }.labelsHidden()
            }
            HStack {
                Text("Break time")
                Spacer()
                Picker("Break time", selection: $selectedBreakTime.onChange(applyBreakTimeValue)) {
                    ForEach(breakTimes.indices, id: \.self) { index in
                        Text(String(self.breakTimes[index])).tag(index)
                    }
                }.labelsHidden()
            }
            Divider()
            Button("Quit", action: AppDelegate.terminateApp).buttonStyle(BorderlessButtonStyle())
        }.padding()
    }
    
    func toggleTimer(_ shouldTimerRun: Bool) {
        if shouldTimerRun {
            timer = createTimer(timerHandler)
        } else {
            timer?.invalidate()
        }
    }
    
    func applyTimerSettings(_ timeIntervalIndex: Int) {
        if !isBreakNow {
            remainingMins = timeIntervals[timeIntervalIndex]
        }
    }
    
    // Creates timer which will be invoking handler every 60 seconds
    func createTimer(_ handler: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: /*60*/2, repeats: true, block: handler)
    }
    
    func timerHandler(timer: Timer) {
        print("Hi")
        remainingMins -= 1;
        if remainingMins <= 0 {
            if isBreakNow {
                remainingMins = timeIntervals[selectedTimeInterval]
            } else {
                remainingMins = breakTimes[selectedBreakTime]
            }
            isBreakNow = !isBreakNow
        }
    }
    
    func applyBreakTimeValue(_ breakTimeIndex: Int) {
        if isBreakNow {
            remainingMins = breakTimes[breakTimeIndex]
        }
    }
}

struct PopoverContent_Previews: PreviewProvider {
    static var previews: some View {
        PopoverContent()
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}
