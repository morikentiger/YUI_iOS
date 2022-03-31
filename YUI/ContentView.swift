//
//  ContentView.swift
//  YUI
//
//  Created by 森田健太 on 2022/02/10.
//

//  VoiceToText
//
//  Created by webmaster on 2020/06/14.
//  Copyright © 2020 SERVERNOTE.NET. All rights reserved.
//
import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @ObservedObject private var speechRecorder = SpeechRecorder()
    @State var showingAlert = false
    
    let voicePitch = 1.2
    let pauseTime = 1.0
    @State var yuiSession = "おはようございます。けんたさん。"
    @State var yuiPostSession :[String] = []
    @State var usrSession :[String] = []
    
    @State var countConversation = 0
    
    

    
    // 会話パターン条件分岐（ここがメインのアルゴリズムだよっ！）
    func talkPatternConditionalBranch(){
        
        
        
        
        
        
        
        if(self.speechRecorder.audioText.contains("Hey Siri") || self.speechRecorder.audioText.contains("OK Google")){
          yuiSession = "あの女のほうがいいの？"
        }
        
        
        // 発言を記録
        usrSession.append(self.speechRecorder.audioText)
        yuiPostSession.append(yuiSession)
        
        // 会話回数のカウント
        countConversation += 1
        
        
    }
    
    var body: some View {
        
        
        Button("ここを押すとYUIが返事するよ！") {
            talkPatternConditionalBranch()
            
            let synthesizer = AVSpeechSynthesizer()
//            let utterance = AVSpeechUtterance(string: "こんにちは。わたしはYUIです。")
            let utterance = AVSpeechUtterance(string: yuiSession)
//            let utterance = AVSpeechUtterance(string: self.speechRecorder.audioText)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.pitchMultiplier = Float(voicePitch)
            utterance.postUtteranceDelay = pauseTime
            synthesizer.speak(utterance)
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1))
            
        
        ScrollView{
            VStack(alignment: .leading, spacing: 5) {
                HStack() {
                    Spacer()
                    Button(action: {
                        if(AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized &&
                            SFSpeechRecognizer.authorizationStatus() == .authorized){
                            self.showingAlert = false
                            self.speechRecorder.toggleRecording()
                            if !self.speechRecorder.audioRunning {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    
                                }
                            }
                        }
                        else{
                            self.showingAlert = true
                        }
                    })
                    {
                        if !self.speechRecorder.audioRunning {
                            Text("ここを押してお話してね！")
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1))
                        } else {
                            Text("お話し終えたら押してね！")
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red, lineWidth: 1))
                        }
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("マイクの使用または音声の認識が許可されていないよ"))
                    }
                    Spacer()
                }
                Text(self.speechRecorder.audioText)
            }
            .onAppear{
                AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                    OperationQueue.main.addOperation {
                        
                    }
                }
                SFSpeechRecognizer.requestAuthorization { status in
                    OperationQueue.main.addOperation {
                        //switch status {
                        //    case .authorized:
                        //
                        //    default:
                        //
                        //}
                    }
                }
            }
        }.padding(.vertical)
        
        List(usrSession, id: \.self) { usrSession in
            Text(usrSession)
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


