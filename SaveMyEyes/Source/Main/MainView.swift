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
        VStack(spacing: 6) {
            statusCard
            intervalSection
            generalSection
            actionButtons
        }
        .padding(14)
        .frame(width: 300)
        .onAppear {
            if settings.shouldTimerRun { viewModel.startTimer() }
        }
        .onChange(of: settings.shouldTimerRun) { _, shouldRun in
            if shouldRun { viewModel.startTimer() } else { viewModel.stopTimer() }
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Text(viewModel.isBreakTimeNow ? "On break".localized : "Working".localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
            }

            HStack {
                Text(viewModel.remainingSeconds.asDurationString)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(viewModel.isBreakTimeNow ? .blue : .primary)
                    .monospacedDigit()

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        settings.shouldTimerRun.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: settings.shouldTimerRun
                                        ? [Color.blue, Color.blue.opacity(0.7)]
                                        : [Color.gray.opacity(0.5), Color.gray.opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)

                        Image(systemName: settings.shouldTimerRun ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(settings.shouldTimerRun ? 1.08 : 1.0)
                            .symbolEffect(.bounce.down, options: .speed(1.5), value: settings.shouldTimerRun)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.quaternary.opacity(0.4))
        )
    }

    // MARK: - Interval Section

    private var intervalSection: some View {
        VStack(spacing: 2) {
            intervalRow(
                icon: "briefcase.fill",
                title: "Work".localized,
                value: $settings.workInterval,
                range: Constants.workIntervalRange,
                unit: "min".localized
            )

            intervalRow(
                icon: "cup.and.saucer.fill",
                title: "Break".localized,
                value: $settings.breakInterval,
                range: Constants.breakIntervalRange,
                unit: "min".localized
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quaternary.opacity(0.3))
        )
    }

    private func intervalRow(
        icon: String,
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 22)

            Text(title.localized)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            Stepper(value: value, in: range) {
                Text("\(value.wrappedValue) \(unit.localized)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .frame(minWidth: 58, alignment: .trailing)
            }
            .controlSize(.small)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    // MARK: - General Section

    private var generalSection: some View {
        VStack(spacing: 2) {
            settingsRow(
                icon: "speaker.wave.2.fill",
                title: "Sound".localized,
                isOn: $settings.isSoundEnabled
            )

            settingsRow(
                icon: "power",
                title: "Launch at login".localized,
                isOn: $settings.launchAtLogin
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quaternary.opacity(0.3))
        )
    }

    private func settingsRow(
        icon: String,
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 22)

            Text(title.localized)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            Toggle(title.localized, isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button("Reset".localized, action: viewModel.resetToDefaults)
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Spacer()

            Button("Quit".localized, action: viewModel.quit)
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }
}

// MARK: - Preview

#Preview {
    @MainActor in
    let vm = PreviewFactory.makeViewModel()
    MainView(viewModel: vm, settings: vm.settings)
        .padding()
        .background(Color.black.opacity(0.3))
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
