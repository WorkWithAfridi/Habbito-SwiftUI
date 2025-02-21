//
//  HabbitoApp.swift
//  Habbito
//
//  Created by Khondakar Afridi on 1/9/25.
//

import SwiftUI

@main
struct HabbitoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Habit.self)
        }
    }
}
