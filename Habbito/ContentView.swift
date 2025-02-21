//
//  ContentView.swift
//  Habbito
//
//  Created by Khondakar Afridi on 1/9/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isIntroCompleted") private var isIntroCompleted: Bool = false

    var body: some View {
        ZStack {
            if isIntroCompleted {
                Home()
                    .transition(.move(edge: .trailing))
            } else {
                NavigationStack {
                    IntroPageView()
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(
            .snappy(duration: 0.25, extraBounce: 0), value: isIntroCompleted)
    }
}

#Preview {
    ContentView()
}
