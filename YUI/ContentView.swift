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
    @State var yuiSession = "あなたのお話、聞かせてください。"
//    @State var yuiSessions :[String] = []
    var yuiSessions : Array<String> = ["そうなんだね","そうだよね","わかるよ","大変だったね","うんうん","それで？","そうなんだ","わかるよ","ふんふん","で？","それから？","うん","そうだね","それでどうなったの？","そうなんだね"]
    
    // 会話パターン条件分岐（ここがメインのアルゴリズムだよっ！）
    func talkPatternConditionalBranch(){
        yuiSession = "あなたのお話、聞かせてください。"
        
        // ランダムであいづちを打つ
        if(self.speechRecorder.audioText.utf8.count > 1){
            yuiSession = yuiSessions.randomElement()!
        }
        
        if(self.speechRecorder.audioText.contains("答え") || self.speechRecorder.audioText.contains("教えて") || self.speechRecorder.audioText.contains("どう")){
          yuiSession = "        ‣ YUIはあなたのお話を聞くことしかできません。答えを出す、選択をするのはあなた自身なのです。そのお手伝いができたら、YUIは本望です！それじゃダメかな？"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(self.speechRecorder.audioText)
                .frame(maxWidth: .infinity, maxHeight: 400)
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
                        Image(systemName: "mic")
                            .font(.system(size: 60))
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60))
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("マイクの使用または音声の認識が許可されていません"))
                }
                Spacer()
            }
            
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
        
        
        Button {
            talkPatternConditionalBranch()
            
            let synthesizer = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: yuiSession)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            utterance.pitchMultiplier = Float(voicePitch)
            utterance.postUtteranceDelay = pauseTime
            synthesizer.speak(utterance)
        } label: {
            Image(systemName: "mouth")
                .font(.system(size: 60))
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


