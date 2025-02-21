//
//  Home.swift
//  Habbito
//
//  Created by Khondakar Afridi on 14/1/25.
//

import SwiftData
import SwiftUI

struct Home: View {
    @AppStorage("username") private var username: String = ""
    @Query(sort: [.init(\Habit.createdAt, order: .reverse)], animation: .snappy) private var habits: [Habit]
    @State private var selectedHabit: Habit?

    @Namespace private var animationID
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                HeaderView()
                    .padding(.bottom, 15)

                ForEach(habits) { habit in
                    HabitCardView(animationId: animationID, habit: habit)
                        .onTapGesture {
                            selectedHabit = habit
                        }
                }
            }
            .padding(15)
            .overlay(content: {
                if habits.isEmpty {
                    ContentUnavailableView(
                        "Start tracking your habits",
                        systemImage: "checkmark.seal.fill"
                    )
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .visualEffect{ content, proxy in
                        content
                            .offset(y: ((proxy.bounds(of: .scrollView)?.height ?? 0) - 50)/2)
                    }
                }
            })
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .safeAreaInset(
            edge: .bottom,
            content: {
                CreateButton()
            }
        )
        .background {
            Rectangle()
                .fill(.primary.opacity(0.05))
                .ignoresSafeArea()
                .scaleEffect(1.5)
        }
        .navigationDestination(item: $selectedHabit) { habit in
            HabitCreationView(habit: habit)
                .navigationTransition(.zoom(sourceID: habit.uniqueID, in: animationID))
        }
    }

    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back!")
                .font(.title.bold())
            HStack(spacing: 0) {
                Text(username)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text(", " + Date.startDateOfThisMonth.format("MMMM YY"))
                    .textScale(.secondary)
                    .foregroundStyle(.gray)
            }
            .font(.title3)
        }
        .hSpacing(.leading)
    }

    @ViewBuilder
    func CreateButton() -> some View {
        NavigationLink {
            HabitCreationView()
                .navigationTransition(
                    .zoom(sourceID: "CREATEBUTTON", in: animationID))
        } label: {
            HStack(spacing: 10) {
                Text("Create Habit")
                Image(systemName: "plus.circle.fill")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.purple.gradient, in: .capsule)
            .matchedTransitionSource(id: "CREATEBUTTON", in: animationID)
        }
        .hSpacing(.center)
        .padding(.vertical, 10)

        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(
                            .linearGradient(
                                colors: [
                                    .white.opacity(0), .white.opacity(0.5),
                                    .white, .white,
                                ], startPoint: .top, endPoint: .bottom)
                        )
                }
                .ignoresSafeArea()
        }
    }

}

#Preview {
    NavigationStack {
        Home()
    }
}
