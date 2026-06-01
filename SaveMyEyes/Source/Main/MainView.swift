//
//  MainView.swift
//  SaveMyEyes
//
//  Created by Max Omelchenko on 02/24/20.
//  Copyright © 2020 Max Omelchenko. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var settings: SettingsStore

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
    }

    // MARK: - Sections

    private var statusSection: some View {
        HStack {
            Image(nsImage: NSImage(named: NSImage.touchBarQuickLookTemplateName) ?? NSImage())

            Text(viewModel.isBreakTimeNow ? "On break" : "Focusing")
                .font(.headline.weight(.semibold))

            Spacer()

            Text(viewModel.remainingSeconds.asDurationString)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(viewModel.isBreakTimeNow ? .blue : .primary)
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
                .foregroundColor(.secondary)

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
                .foregroundColor(.secondary)

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
                .buttonStyle(BorderlessButtonStyle())

            Spacer()

            Button("Quit", action: viewModel.quit)
                .buttonStyle(BorderlessButtonStyle())
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = PreviewFactory.makeViewModel()
        MainView(viewModel: vm, settings: vm.settings)
    }
}

@MainActor
enum PreviewFactory {
    static func makeViewModel() -> MainViewModel {
        MainViewModel(
            timerInterval: Constants.minute,
            allowedUserInactivityInterval: Constants.allowedUserInactivityInterval,
            terminateApp: { print("Preview quit") }
        )
    }
}
#endif
