

// what to do here next:
// remove status: and instead have it say outload full count with voice
// add option to mute sound though.

import SwiftUI

import AVFoundation
var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        }
        catch {
            print("error message")
        }
    }
}

func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }

struct TheCount : View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("balls") var balls: Int = 0
    @AppStorage("strikes") var strikes: Int = 0
    @AppStorage("fouls") var fouls: Int = 0
    @AppStorage("outs") var outs: Int = 0
    @AppStorage("status") var status = ""
    @AppStorage("displayBalls") var displayBalls = " ⃝⃝  ⃝⃝  ⃝⃝  ⃝⃝"
    @AppStorage("displayStrikes") var displayStrikes = " ⃝⃝  ⃝⃝  ⃝⃝"
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("strikeSound") var strikeSound: Bool = true
    @AppStorage("fullCountSound") var fullCountSound: Bool = true
    @AppStorage("threeOuts") var threeOuts: Bool = false
    @AppStorage("ballSound") var ballSound: Bool = true
    @AppStorage("showStatus") var showStatus: Bool = true
    
    @State private var isShowingDialog = false
    
    func playAudio(soundName: String) {
        if soundEnabled {
            playSound(sound: soundName, type: "wav")
        }
        else {
            if soundName == "Strike" {
                if strikeSound {
                    playSound(sound: soundName, type: "wav")
                }
            }
            
            if soundName == "FullCount" {
                if fullCountSound {
                    playSound(sound: soundName, type: "wav")
                }
            }
            
            if soundName == "Ball" {
                if ballSound {
                    playSound(sound: soundName, type: "wav")
                }
            }
        }
    }
    
    
    func restart() {
        balls = 0
        strikes = 0
        fouls = 0
        displayBalls = " ⃝⃝  ⃝⃝  ⃝⃝  ⃝⃝"
        displayStrikes = " ⃝⃝  ⃝⃝  ⃝⃝"
    }
    
    func restartAll() {
        restart()
        status = ""
        outs = 0
        threeOuts = false
    }
    
    func giveStatus(takeStatus: String) {
        status = takeStatus
        if status == "out" {
            outs += 1
        }
        else {
            restart()
        }
        
        if outs == 3 {
            threeOuts = true
        }
    }
    
    func strikeHit() {
        
        playAudio(soundName: "Strike")
        
        if strikes == 3 {
            strikes = 0
            displayStrikes = " ⃝⃝  ⃝⃝  ⃝⃝"
        }
        else {
            strikes += 1
        }
        
        if strikes == 2 && balls == 3 {
            playAudio(soundName: "FullCount")
            status = "Full Count"
        }
        
        if strikes == 1 {
            displayStrikes = "⚾️  ⃝⃝  ⃝⃝"
        }
        else if strikes == 2 {
            displayStrikes = "⚾️ ⚾️  ⃝⃝"
        }
        else if strikes == 3 {
            displayStrikes =  "⚾️ ⚾️ ⚾️"
            giveStatus(takeStatus: "out")
        }
        else {
            displayStrikes = " ⃝⃝  ⃝⃝  ⃝⃝"
        }
        
        if strikes == 3 {
            strikes = 0
            displayStrikes = " ⃝⃝  ⃝⃝  ⃝⃝"
        }
        
        
    }
    
    
    var body: some View {
        ZStack {
            
            
            VStack {
                TopTitle()
                
                ScrollView {
                    
                    Text("\(outs) out" + (outs == 1 ? "" : "s"))
                        .font(.largeTitle)
                        .bold()
                    
                    HStack {
                        
                        
                        Button("⚾️ ball") {
                            
                            status = "ball"
                            playAudio(soundName: "Ball")
                            
                            if balls >= 4 {
                                balls = 0
                            }
                            else {
                                balls += 1
                            }
                            
                            if balls == 3 && strikes == 2 {
                                playAudio(soundName: "FullCount")
                                status = "Full Count"
                            }
                            
                            if balls == 1 {
                                displayBalls = "⚾️  ⃝⃝  ⃝⃝  ⃝⃝"
                            }
                            else if balls == 2 {
                                displayBalls = "⚾️ ⚾️  ⃝⃝  ⃝⃝"
                            }
                            else if balls == 3 {
                                displayBalls =  "⚾️ ⚾️ ⚾️  ⃝⃝"
                            }
                            else if balls == 4 {
                                displayBalls = "⚾️ ⚾️ ⚾️ ⚾️"
                                giveStatus(takeStatus: "walk")
                            }
                            else {
                                displayBalls = " ⃝⃝  ⃝⃝  ⃝⃝  ⃝⃝"
                            }
                            
                            
                        
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/, height: 50)
                        
                        
                        Text(displayBalls)
                        
                    }
                    
                    
                    
                          HStack {
                              Button("❌ strike") {
                                  strikeHit()
                                  status = "strike"
                              }
                              .alert(isPresented: $threeOuts) {
                                  Alert(
                                    title: Text("Inning over"),
                                    message: Text("A new batter is up and the outs are reset to zero."),
                                    dismissButton: .default(Text("OK")) {
                                        // Action to perform when "OK" is pressed
                                        restartAll()
                                    }
                                  )
                                  

                              }
                              
                              .buttonStyle(.bordered)
                              .foregroundColor(colorScheme == .dark ? .white : .black)
                              .frame(width: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/, height: 50)
                              .edgesIgnoringSafeArea(.all)
                              .padding()
                              
                              
                              
                              Text(displayStrikes)
                          }
                          
                          HStack {
                              Button(action: {
                                          // Action to perform when button is tapped
                                  fouls += 1
                                  if !(strikes >= 2) {
                                      strikeHit()
                                  }
                                  status = "foul ball"
                                      }) {
                                          HStack {
                                              Image(systemName: "figure.baseball")
                                              Text("foul")
                                          }
                                      }
                              .buttonStyle(.bordered)
                              .foregroundColor(colorScheme == .dark ? .white : .black)
                              .edgesIgnoringSafeArea(.all)
                              .padding()
                              .frame(width: 120.0, height: 50)
                              
                              
                              Text("\(fouls)")
                          }
                    
                    if showStatus {
                        Text(status)
                            .font(.largeTitle)
                            .bold()
                    }
     
                    
                    
                    // Clear All/Redo All
                    HStack {
                        Button("Restart") {
                            isShowingDialog = true
                        }
                        .confirmationDialog(
                          "Delete all data on this page?",
                          isPresented: $isShowingDialog,
                          titleVisibility: .visible
                        ) {
                          Button("Delete outs, balls, strikes, and fouls", role: .destructive) {
                              restartAll()
                          }

                          Button("Cancel", role: .cancel) {
                            isShowingDialog = false
                          }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(colorScheme == .dark ?  .white : .black)
                        .edgesIgnoringSafeArea(.all)
                        .padding()
                        .padding()
                    }
                    
                    
                    
                }
                .padding()
                .frame(height: 557.0)

            }.preferredColorScheme(colorScheme == .dark ? .dark : .light)
        }
    }
}

#Preview {
    TheCount()
}

