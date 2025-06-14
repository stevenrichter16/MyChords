//
//  ContentView.swift
//  MyChords
//
//  Created by Steven Richter on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ChordPadView()
                    .navigationTitle("Chords")
            }
            .tabItem {
                Label("Chords", systemImage: "music.note")
            }
            
            NavigationStack {
                ProgressionsListView()
                    .navigationTitle("Progressions")
            }
            .tabItem {
                Label("Progressions", systemImage: "music.note.list")
            }
        }
    }
}

#Preview {
    ContentView()
}
