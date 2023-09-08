//
//  powoApp.swift
//  powo
//
//  Created by Vítor Barroso on 07/09/23.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {
  func makeNSView(context: Self.Context) -> NSView { return NSVisualEffectView() }
  func updateNSView(_ nsView: NSView, context: Context) { }
}

@main
struct powoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().background(VisualEffect().ignoresSafeArea())
        }.windowStyle(HiddenTitleBarWindowStyle())
    }
}
