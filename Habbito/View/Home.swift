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
    @Query(sort: [.init(\Habit.createdAt, order: .reverse)], animation: .snappy)
    private var habits: [Habit]
    
    @Namespace private var animationID
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                HeaderView()
                    .padding(.bottom, 15)

                ForEach(habits) { habit in
                    HabitCardView(animationId: animationID, habit: habit)
                }
            }
            .padding(15)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .overlay(content: {
            if habits.isEmpty {
                ContentUnavailableView("Start tracking your habits", systemImage: "checkmark.seal.fill")
                    .offset(y: 20)
            }
        })
        .safeAreaInset(edge: .bottom, content: {
            CreateButton()
        })
        .background(.primary.opacity(0.05))
    }

    @ViewBuilder
    func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back, \(username)!")
                .font(.title.bold())
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    func CreateButton() -> some View {
        NavigationLink{
            
        } label: {
            HStack(spacing: 10){
                Text("Create Habit")
                Image(systemName: "plus.circle.fill")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.orange.gradient, in: .capsule)
            .matchedTransitionSource(id: "CREATEBUTTON", in: animationID)
        }
        .hSpacing(.center)
        .padding(.vertical, 10)
        
        .background{
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(
                            .linearGradient(colors: [.white.opacity(0), .white.opacity(0.5), .white, .white], startPoint: .top, endPoint: .bottom)
                        )
                }
                .ignoresSafeArea()
        }
    }
        
}

#Preview {
    Home()
}
