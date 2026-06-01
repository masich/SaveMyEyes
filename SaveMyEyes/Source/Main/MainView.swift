//
//  MainView.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var viewModel: MainViewModel
    @Bindable var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusSection
            Divider().padding(.vertical, 8)
            timerSection
            Divider().padding(.vertical, 8)
            intervalSection
            Divider().padding(.vertical, 8)
            generalSection
            Divider().padding(.vertical, 8)
            actionsSection
        }
        .padding(16)
        .frame(width: 280)
        .onAppear {
            if settings.shouldTimerRun { viewModel.startTimer() }
        }
        .onChange(of: settings.shouldTimerRun) { _, shouldRun in
            if shouldRun { viewModel.startTimer() } else { viewModel.stopTimer() }
        }
    }

    // MARK: - Sections

    private var statusSection: some View {
        HStack {
            Image(systemName: viewModel.isBreakTimeNow ? "cup.and.saucer.fill" : "deskclock.fill")
                .foregroundStyle(viewModel.isBreakTimeNow ? .blue : .accentColor)
                .font(.title3)

            Text(viewModel.isBreakTimeNow ? "On break" : "Focusing")
                .font(.headline.weight(.semibold))

            Spacer()

            Text(viewModel.remainingSeconds.asDurationString)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundStyle(viewModel.isBreakTimeNow ? .blue : .primary)
        }
    }

    private var timerSection: some View {
        HStack {
            Text("Run timer")
            Spacer()
            Toggle("Run timer", isOn: $settings.shouldTimerRun)
                .labelsHidden()
        }
    }

    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Intervals")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack {
                Text("Work")
                    .frame(width: 60, alignment: .leading)
                Spacer()
                Stepper(value: $settings.workInterval, in: Constants.workIntervalRange) {
                    Text("\(settings.workInterval) min")
                        .frame(width: 60, alignment: .trailing)
                        .font(.system(.body, design: .monospaced))
                }
            }

            HStack {
                Text("Break")
                    .frame(width: 60, alignment: .leading)
                Spacer()
                Stepper(value: $settings.breakInterval, in: Constants.breakIntervalRange) {
                    Text("\(settings.breakInterval) min")
                        .frame(width: 60, alignment: .trailing)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("General")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack {
                Text("Sound")
                Spacer()
                Toggle("Sound", isOn: $settings.isSoundEnabled)
                    .labelsHidden()
            }

            HStack {
                Text("Launch at login")
                Spacer()
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .labelsHidden()
            }
        }
    }

    private var actionsSection: some View {
        HStack {
            Button("Reset", action: viewModel.resetToDefaults)
                .buttonStyle(.borderless)

            Spacer()

            Button("Quit", action: viewModel.quit)
                .buttonStyle(.borderless)
                .keyboardShortcut("q", modifiers: .command)
        }
    }
}

// MARK: - Preview

#Preview {
    @MainActor in
    let vm = PreviewFactory.makeViewModel()
    MainView(viewModel: vm, settings: vm.settings)
}

@MainActor
enum PreviewFactory {
    static func makeViewModel() -> MainViewModel {
        MainViewModel(
            timerInterval: 1,
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: { print("Preview quit") }
        )
    }
}
