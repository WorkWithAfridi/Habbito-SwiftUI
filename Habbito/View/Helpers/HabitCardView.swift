//
//  HabitCardView.swift
//  Habbito
//
//  Created by Khondakar Afridi on 21/2/25.
//

import SwiftUI

struct HabitCardView: View {
    var animationId: Namespace.ID
    var habit: Habit
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(habit.name)
                        .font(.callout)

                    Text("Created At " + habit.createdAt.format("dd MMM, YYYY"))
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                Spacer()
                CompletionProgressIndicator()
            }
            HabitCalendarView(
                createdAt: habit.createdAt, frequencies: habit.frequencies,
                completedDates: habit.completedDates
            )
            .applyPaddedBackground(10)
            .matchedTransitionSource(id: habit.uniqueID, in: animationId)
            
            if habit.frequencies.contains(where: { $0.rawValue == Date.now.weekDay }) &&
                !habit.completedDates.contains(Date.now.startOfDay.timeIntervalSince1970) {
                CompleteButton()
            }
        }
    }
    
    @ViewBuilder
    func CompleteButton() -> some View {
        VStack (spacing: 10) {
            Text("Have you completed the habit today?")
                .font(.callout)
            
            HStack(spacing: 10) {
                Button("Yes, completed 🎉") {
                    withAnimation(.snappy) {
                        let todayTimeStamp = Date.now.startOfDay.timeIntervalSince1970
                        habit.completedDates.append(todayTimeStamp)
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 10))
                .tint(.green)
                .applyPaddedBackground(10)
            }
        }
        .hSpacing(.center)
        .applyPaddedBackground(10)
    }

    @ViewBuilder
    func CompletionProgressIndicator() -> some View {
        let habitMatchingDatesInThisMonth = Date.datesInThisMonth.filter {
            date in
            habit.frequencies.contains {
                $0.rawValue == date.weekDay
            } && date.startOfDay >= habit.createdAt.startOfDay
        }

        let habitsCompletedInThisMonth = habitMatchingDatesInThisMonth.filter {
            habit.completedDates.contains($0.timeIntervalSince1970)
        }

        let progress =
            CGFloat(habitsCompletedInThisMonth.count)
            / CGFloat(habitMatchingDatesInThisMonth.count)

        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(.fill, lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.green.gradient, lineWidth: 3)
                    .rotationEffect(.init(degrees: -90))
            }
            .frame(width: 30, height: 30)
            
            Text("\(habitsCompletedInThisMonth.count)/\(habitMatchingDatesInThisMonth.count)")
                .font(.caption2)
                .foregroundStyle(.gray)
        }
    }
}
