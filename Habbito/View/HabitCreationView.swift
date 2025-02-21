//
//  HabitCreationView.swift
//  Habbito
//
//  Created by Khondakar Afridi on 21/2/25.
//

import SwiftData
import SwiftUI
import UserNotifications

struct HabitCreationView: View {

    var habit: Habit?

    @State private var name: String = ""
    @State private var frequencies: [Frequency] = []
    @State private var notificationDate: Date = Date()
    @State private var enableNotification: Bool = false
    @State private var isNotificationPermissionGranted: Bool = false

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [.init(\Habit.createdAt, order: .reverse)], animation: .snappy)
    private var habits: [Habit]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Workout for 15 Min's", text: $name)
                    .font(.title)
                    .padding(.bottom, 10)

                Text("Habit Frequency")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)

                HabitCalendarView(
                    isDemo: isNewhabit, createdAt: habit?.createdAt ?? .now,
                    frequencies: frequencies,
                    completedDates: habit?.completedDates ?? []
                )
                .applyPaddedBackground(15)

                if isNewhabit {
                    FrequencyPicker()
                        .applyPaddedBackground(15)
                }

                Text("Notification's")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)

                NotificationProperties()
                HabitCreationButton()
                    .padding(.top, 10)

            }
            .padding(15)
        }
        .animation(.snappy, value: enableNotification)
        .background(.primary.opacity(0.05))
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            guard let habit else { return }
            name = habit.name
            enableNotification = habit.isNotificationEnabled
            notificationDate = habit.notificationTiming ?? .now
            frequencies = habit.frequencies

        }
        .task {
            isNotificationPermissionGranted =
                (try? await UNUserNotificationCenter.current()
                    .requestAuthorization(
                        options: [.alert, .sound]
                    )) ?? false
        }
    }

    var isNewhabit: Bool {
        habit == nil
    }

    private func createHabit() {
        Task { @MainActor in
            if let habit {
                habit.name = name
                cancelNotifications(habit.notificationIDs)
                if enableNotification {
                    let ids = (try? await scheduleNotifications()) ?? []
                    habit.notificationTiming = notificationDate
                    habit.notificationIDs = ids

                } else {
                    habit.notificationTiming = nil
                    habit.notificationIDs = []
                }
            } else {
                if enableNotification {
                    let notificationIDs =
                        (try? await scheduleNotifications()) ?? []
                    let habit = Habit(
                        name: name, frequencies: frequencies,
                        notificationIDs: notificationIDs,
                        notificationTiming: notificationDate)
                    context.insert(habit)

                } else {
                    let habit = Habit(name: name, frequencies: frequencies)
                    context.insert(habit)
                }
            }
            do {
                try context.save()
                dismiss()
            } catch {
                print("Error saving habit: \(error)")
            }
        }

    }

    private func cancelNotifications(_ ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ids
        )
    }

    private func scheduleNotifications() async throws -> [String] {
        var notificationIDs: [String] = []

        let weekdaySymbols: [String] = Calendar.current.weekdaySymbols

        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Complete your \(name) habit"

        for frequency in frequencies {
            let hour = Calendar.current.component(.hour, from: notificationDate)
            let minute = Calendar.current.component(
                .minute, from: notificationDate)
            let id: String = UUID().uuidString

            if let dayIndex = weekdaySymbols.firstIndex(of: frequency.rawValue)
            {
                var scheduleDateComponent = DateComponents()
                scheduleDateComponent.weekday = dayIndex + 1
                scheduleDateComponent.hour = hour
                scheduleDateComponent.minute = minute

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: scheduleDateComponent, repeats: true)
                let request = UNNotificationRequest(
                    identifier: id, content: content, trigger: trigger)
                try await UNUserNotificationCenter.current().add(request)

                notificationIDs.append(id)
            }
        }

        return notificationIDs
    }

    var habitValidation: Bool {
        frequencies.isEmpty || name.isEmpty
    }

    @ViewBuilder
    func HabitCreationButton() -> some View {
        HStack(spacing: 10) {
            Button(action: createHabit) {
                HStack(spacing: 10) {
                    Text("\(isNewhabit ? "Create" : "Update")Habit")
                    Image(systemName: "checkmark.circle.fill")
                }
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .hSpacing(.center)
                .padding(.vertical, 12)
                .background(.purple.gradient, in: .rect(cornerRadius: 10))
                .contentShape(.rect)
            }
            .disableWithOpacity(habitValidation)

            if !isNewhabit {
                Button {

                    guard let habit else { return }
                    dismiss()
                    Task {
                        try? await Task.sleep(for: .seconds(0.2))
                        context.delete(habit)
                        try? context.save()
                    }

                } label: {
                    Image(systemName: "trash")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(.red.gradient, in: .circle)
                }
            }
        }
    }

    @ViewBuilder
    func NotificationProperties() -> some View {
        Toggle("Enable Remainder Notification", isOn: $enableNotification)
            .font(.callout)
            .applyPaddedBackground(12)
            .disableWithOpacity(!isNotificationPermissionGranted)

        if enableNotification && isNotificationPermissionGranted {
            DatePicker(
                "Preferred Reminder Time", selection: $notificationDate,
                displayedComponents: [.hourAndMinute]
            )
            .applyPaddedBackground(12)
            .transition(.blurReplace)
        }

        if !isNotificationPermissionGranted {
            Text(
                "Notification permission is denied, please enable it in settings."
            )
            .font(.caption2)
            .foregroundStyle(.gray)
        }

    }

    @ViewBuilder
    func FrequencyPicker() -> some View {
        HStack(spacing: 5) {
            ForEach(Frequency.allCases, id: \.rawValue) { frequency in
                Text(frequency.rawValue.prefix(3))
                    .font(.caption)
                    .hSpacing(.center)
                    .frame(height: 30)
                    .background {
                        if frequencies.contains(frequency) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.fill)
                        }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            if frequencies.contains(frequency) {
                                frequencies.removeAll(where: { $0 == frequency }
                                )
                            } else {
                                frequencies.append(frequency)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    HabitCreationView()
}
