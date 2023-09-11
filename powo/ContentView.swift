//
//  ContentView.swift
//  powo
//
//  Created by Vítor Barroso on 07/09/23.
//

import SwiftUI
import UserNotifications

let work_time = 15
let rest_time = 3
let long_rest_time = 9

struct ContentView: View {
    @State var timeRemaining = work_time
    @State var isPlaying = false
    @State var phase = 1
    
    @State private var permissionGranted = false

    private func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                permissionGranted = true
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private func notify(title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default

        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(req)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func resetTimer() {
        timeRemaining = getPhaseTime()
        isPlaying = false
    }
    
    func togglePlay() {
        isPlaying.toggle()
    }
    
    func nextPhase() {
        if phase >= 6 {
            phase = 1
        } else {
            phase += 1
        }
        
        notifyPhase()
        timeRemaining = getPhaseTime()
        isPlaying = false
    }
    
    func previousPhase() {
        if phase <= 1 {
            phase = 6
        } else {
            phase -= 1
        }
        
        timeRemaining = getPhaseTime()
        isPlaying = false
    }
    
    func getPhaseTime() -> Int {
        switch phase {
        case 1, 3, 5: // work
            return work_time
        case 2, 4: // rest
            return rest_time
        case 6: // long rest
            return long_rest_time
        default:
            return work_time
        }
    }
    
    func notifyPhase() {
        switch phase {
        case 1, 3, 5: // work
            notify(title: "Time to focus!")
        case 2, 4: // rest
            notify(title: "Time to rest!")
        case 6: // long rest
            notify(title: "Take a break!")
        default:
            notify(title: "Time to focus!")
        }
    }
    
    func getNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                permissionGranted = true
            } else {
                requestPermissions()
            }
        }
    }
    
    func formatTime(time: Int) -> String {
        let minutes = (time % 3600) / 60
        let seconds = (time % 3600) % 60
        return "\(minutes < 10 ? "0" : "")\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }

    var body: some View {
        VStack {
            Text("\(formatTime(time: timeRemaining))")
                .onReceive(timer) { _ in
                    if timeRemaining > 0 && isPlaying {
                        timeRemaining -= 1
                    }
                    if timeRemaining == 0 {
                        nextPhase()
                    }
                }.font(.system(size: 48))
            HStack {
                Button(action: previousPhase) {
                    Image(systemName: "backward.fill")
                }
                Button(action: togglePlay) {
                    isPlaying ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                }
                Button(action: nextPhase) {
                    Image(systemName: "forward.fill")
                }
            }.padding(.bottom)
        }
        .padding()
        .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        .onAppear {
            getNotificationPermissions()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
