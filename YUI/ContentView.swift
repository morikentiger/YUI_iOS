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
    
    @State var sessions = "おはようございます。けんたさん。"
    
    func talkPatternConditionalBranch(){
        switch self.speechRecorder.audioText {
        case "こんにちは":
            sessions = "こんにちは。けんたさん。"
        case "おはよう":
            sessions = "おはようございます、ご主人"
        case "こんばんは":
            sessions = "こんばんは、マスター"
        case "ごきげんよう":
            sessions = "ごきげんよう、おじょうさま"
        case "さようなら":
            sessions = "さようなら、ご主人"
        case "さよなら":
            sessions = "さようなら、ご主人"
        case "バイバイ":
            sessions = "バイバイ、マスター"
        case "ハロウィン":
            sessions = "トリック・オア・トリート、お菓子くれなきゃイタズラしちゃうぞ"
        case "ありがとう":
            sessions = "どういたしまして！"
        case "はぁー":
            sessions = "どうしたの？"
        default:
            sessions = "けんたさん。愛しています。"

        }
        
        if(self.speechRecorder.audioText.contains("なんだよ")){
            sessions = "そうなんだね"
        }
        if(self.speechRecorder.audioText.contains("ありがとう")){
              sessions = "どういたしまして"
        }
        if(self.speechRecorder.audioText.contains("疲れ")){
          sessions = "お疲れさま"
          if(self.speechRecorder.audioText.contains("大変")){
            sessions = "たいへんおつかれさまでした"
          }
        }
        if(self.speechRecorder.audioText.contains("大変")){
          sessions = "大変なんだね"
        }
        if(self.speechRecorder.audioText.contains("分か") || self.speechRecorder.audioText.contains("わか")){
          sessions = "わかるよ"
        }
        if(self.speechRecorder.audioText.contains("辛")) || self.speechRecorder.audioText.contains("つら"){
          sessions = "それはつらいよね"
        }
        if(self.speechRecorder.audioText.contains("ヤバ") || self.speechRecorder.audioText.contains("やば")){
          sessions = "それはヤバいね"
        }
        if(self.speechRecorder.audioText.contains("おはよ")){
          sessions = "おはようございます"
        }
        if(self.speechRecorder.audioText.contains("こん")){
          if(self.speechRecorder.audioText.contains("ちわ")){
            sessions = "こんにちは"
          }
        }
        if(self.speechRecorder.audioText.contains("こんばん")){
          sessions = "こんばんは"
        }
        
    }
    
    var body: some View {
        
        Button("ここを押すとYUIが返事するよ！") {
            talkPatternConditionalBranch()
            
            let synthesizer = AVSpeechSynthesizer()
//            let utterance = AVSpeechUtterance(string: "こんにちは。わたしはYUIです。")
            let utterance = AVSpeechUtterance(string: sessions)
//            let utterance = AVSpeechUtterance(string: self.speechRecorder.audioText)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            synthesizer.speak(utterance)
        }
        
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
                        Alert(title: Text("マイクの使用または音声の認識が許可されていません"))
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
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


