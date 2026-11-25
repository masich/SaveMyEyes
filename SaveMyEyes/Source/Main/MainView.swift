//
//  MainView.swift
//  SaveMyEyes
//
//  Created by Maksym Omelchenko on 2020-02-24.
//  SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct MainView: View {
    var viewModel: MainViewModel
    @Bindable var settings: SettingsStore

    var body: some View {
        VStack(spacing: 6) {
            if let error = viewModel.launchAtLoginError {
                errorBanner(message: error)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8, anchor: .top).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8)),
                        removal: .scale(scale: 0.8, anchor: .top).combined(with: .opacity).animation(.easeIn(duration: 0.15))
                    ))
            }
            statusCard
            intervalSection
            generalSection
            actionButtons
        }
        .padding(14)
        .frame(width: 300)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.launchAtLoginError)
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 12))

            Text(message)
                .font(.system(size: 11))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: { viewModel.launchAtLoginError = nil }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.orange.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.orange.opacity(0.3), lineWidth: 0.5)
        )
    }

    // MARK: - Status Card

    @State private var switchRotation: Double = 0

    private var statusCard: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left side: status text + timer countdown
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isBreakTimeNow ? "On break".localized : "Working".localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(viewModel.remainingSeconds.asDurationString)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(viewModel.isBreakTimeNow ? .blue : .primary)
                    .monospacedDigit()
            }

            Spacer()

            // Right side: switch button to the left, play/pause to the right
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        switchRotation += 180
                        viewModel.toggleBreakState()
                    }
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(switchRotation))
                        .background(Circle().fill(.quaternary.opacity(0.6)))
                }
                .buttonStyle(.plain)
                .help(viewModel.isBreakTimeNow ? "Switch to work".localized : "Switch to break".localized)

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        settings.shouldTimerRun.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(settings.shouldTimerRun
                                ? Color.blue
                                : Color(nsColor: .quaternaryLabelColor).opacity(0.6))
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

            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            Stepper(value: value, in: range) {
                Text("\(value.wrappedValue) \(unit)")
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
                isOn: Binding(
                    get: { settings.launchAtLogin },
                    set: { settings.setLaunchAtLogin($0) }
                )
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

            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

            Spacer()

            Toggle(title, isOn: isOn)
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
