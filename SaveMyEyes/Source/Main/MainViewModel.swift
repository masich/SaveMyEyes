//
//  MainViewModel.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 03/03/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import Foundation
import Combine

class TimerWorker {
    private var timer: Timer?
    private var timerHandler: (Timer) -> Void
    private var timerInterval: TimeInterval
    
    init(timerInterval: TimeInterval, timerHandler: @escaping (Timer) -> Void) {
        self.timerHandler = timerHandler
        self.timerInterval = timerInterval
    }
    
    func initInternalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: timerHandler)
    }
    
    func stopInternalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resumeInternalTimer() {
        initInternalTimer()
    }
    
    func isTimerRunning() -> Bool {
        return timer != nil
    }
    
    func toggleInternalTimer(_ shouldTimerRun: Bool) {
        if shouldTimerRun {
            resumeInternalTimer()
        } else {
            stopInternalTimer()
        }
    }
}


class MainViewModel: ObservableObject {
    @Published private(set) var isBreakTimeNow = false
    @Published private(set) var remainingMins: Int = 0
    
    @Published var shouldTimerRun = Observable<Bool>(false)
    @Published var isSoundEnabled = Observable<Bool>(Preferences.isSoundEnabled(true))
    @Published var workIntervalIndex = Observable<Int>(Preferences.getWorkIntervalIndexValue(0))
    @Published var breakIntervalIndex = Observable<Int>(Preferences.getBreakIntervalIndexValue(0))
    
    private var timerWorker: TimerWorker!
    private var cancellables = [AnyCancellable]()
    private var isUserInactive = false
    
    private let allowedUserInactivityInterval: TimeInterval
    private let timerInterval: TimeInterval
    
    let breakIntervals: [Int]
    let workIntervals: [Int]
    let terminateApp: () -> ()
    
    init(
        workIntervals: [Int],
        breakIntervals: [Int],
        timerInterval: TimeInterval,
        allowedUserInactivityInterval: TimeInterval,
        terminateApp: @escaping () -> ()
    ) {
        self.workIntervals = workIntervals
        self.breakIntervals = breakIntervals
        self.timerInterval = timerInterval
        self.allowedUserInactivityInterval = allowedUserInactivityInterval
        self.terminateApp = terminateApp
        
        remainingMins = isBreakTimeNow ? breakIntervals[breakIntervalIndex.value] : workIntervals[workIntervalIndex.value]
        timerWorker = TimerWorker(timerInterval: timerInterval, timerHandler: timerHandler)
        
        cancellables = [
            shouldTimerRun.subject.sink(receiveValue: timerWorker.toggleInternalTimer),
            isSoundEnabled.subject.sink(receiveValue: Preferences.setSoundEnabled),
            workIntervalIndex.subject.sink(receiveValue: onWorkIntervalChanged),
            workIntervalIndex.subject.sink(receiveValue: Preferences.setWorkTimeIntervalIndexValue),
            breakIntervalIndex.subject.sink(receiveValue: onBreakIntervalChanged),
            breakIntervalIndex.subject.sink(receiveValue: Preferences.setBreakIntervalIndexValue),
        ]
    }
    
    /**
     Applyes changes on the work time interval value index
     */
    private func onWorkIntervalChanged(_ workIntervalIndex: Int) {
        if !isBreakTimeNow {
            remainingMins = workIntervals[workIntervalIndex]
        }
    }
    
    /**
     Applyes changes on the break time interval value index
     */
    private func onBreakIntervalChanged(_ breakIntervalIndex: Int) {
        if isBreakTimeNow {
            remainingMins = breakIntervals[breakIntervalIndex]
        }
    }
    
    /**
     Handles timer ticks
     
     Performs time management only if user was active for at least last `allowedUserInactivityInterval` seconds
     */
    public func timerHandler(timer: Timer) {
        let isUserIncativeNew = System.isUserInactive(forMinutes: Constants.allowedUserInactivityMinutes)
        if !isUserInactive && isUserIncativeNew {
            let maxIncrementValue = workIntervals[workIntervalIndex.value] - remainingMins
            remainingMins += min(maxIncrementValue, Constants.allowedUserInactivityMinutes)
        }
        isUserInactive = isUserIncativeNew
        
        if isBreakTimeNow || !isUserInactive {
            remainingMins -= 1
            if remainingMins <= 0 {
                if isBreakTimeNow {
                    remainingMins = workIntervals[workIntervalIndex.value]
                } else {
                    remainingMins = breakIntervals[breakIntervalIndex.value]
                }
                isBreakTimeNow.toggle()
                sendNotification()
            }
        }
    }
    
    /**
     Sends user notification
     
     Notification content depends on the `isBreakTimeNow`
     */
    public func sendNotification() {
        let notification: AppNotification
        let notificationSound = isSoundEnabled.value ? AppNotification.defaultSound : AppNotification.withoutSound
        if isBreakTimeNow {
            notification = AppNotification(title: "It's time for break".localized, subtitle: String(format: "Relax from your computer for %d minutes.".localized, breakIntervals[breakIntervalIndex.value]), sound: notificationSound)
        } else {
            notification = AppNotification(title: "It's time to work".localized, subtitle: "Let's continue to do amazing things!".localized, sound: notificationSound)
        }
        AppNotificationManager.sendSingle(notification)
    }
    
    public func pauseTimer() {
        shouldTimerRun.value = false
        
        // A temporary crutch to update view content:)
        // TODO: Remove it
        remainingMins -= 0
    }
}
