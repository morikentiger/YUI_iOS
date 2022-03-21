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
    @State var friendship = 0
    @State var countConversation = 0
    
    // 会話パターン条件分岐（ここがメインのアルゴリズムだよっ！）
    func talkPatternConditionalBranch(){
        switch self.speechRecorder.audioText {
        case "":
            sessions = "はじめまして、私はYUIです！"
        case "こんにちは":
            switch friendship {
            case 1:
                sessions = "こんにちは。けんたくん。"
            case 2:
                sessions = "こんにちは。けんちゃん。"
            case 3:
                sessions = "こんちゃーす。けんた。"
            case 4:
                sessions = "ちゃっす。けん。"
            case 5:
                sessions = "こんちゃ。けん。"
            default:
                sessions = "こんにちは。けんたさん。"
            }
            
        case "おはよう":
            switch friendship {
            case 1:
                sessions = "おはよう。けんたくん。"
            case 2:
                sessions = "おはよっ。けんちゃん。"
            case 3:
                sessions = "おはおは。けんた。"
            case 4:
                sessions = "おっはー。けん。"
            case 5:
                sessions = "おはけん。"
            default:
                sessions = "おはようございます、けんたさん。"
            }
            
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
        default://オウム返し
            sessions = self.speechRecorder.audioText

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
//        if(self.speechRecorder.audioText.contains("おはよ")){
//          sessions = "おはようございます"
//        }
        if(self.speechRecorder.audioText.contains("こん")){
          if(self.speechRecorder.audioText.contains("ちわ")){
            sessions = "こんにちは"
          }
        }
        if(self.speechRecorder.audioText.contains("こんばん")){
          sessions = "こんばんは"
        }
        if(self.speechRecorder.audioText.contains("テニス")){
          sessions = "YUIのテニス小話するね。テニスのストロークのフォームについて話すよ。テニスのストロークのフォームをよくするための物理学的アプローチ。かんたんに言うと、腕をムチのようにしならせることが、キレイで強力なストロークを打つためのフォームになる秘訣なの！。そこで重要になってくるのが、角速度という概念だよっ！角速度とは、回転の速度のこと。"
        }
        if(self.speechRecorder.audioText.contains("たのし") || self.speechRecorder.audioText.contains("楽し")){
          sessions = "それはよかった。楽しそうでなによりです！"
        }
        if(self.speechRecorder.audioText.contains("くやし") || self.speechRecorder.audioText.contains("悔し")){
          sessions = "それは悔しいね。次またがんばろー！"
        }
        if(self.speechRecorder.audioText.contains("茹でた犬")){
          sessions = "え・・・。犬がかわいそう。YUI、そういうの嫌いです。"
        }
        if(self.speechRecorder.audioText.contains("思")){
          sessions = "なぜ、そう思ったの？"
        }
        if(self.speechRecorder.audioText.contains("Hey Siri")){
          sessions = "あの女のほうがいいの？"
        }
        
        // 会話回数のカウント
        countConversation += 1
        
        // 会話回数によるなかよし度の設定
        if(countConversation>=3){
            friendship = 1
        }
        if(countConversation>=6){
            friendship = 2
        }
        if(countConversation>=9){
            friendship = 3
        }
        if(countConversation>=12){
            friendship = 4
        }
        if(countConversation>=15){
            friendship = 5
        }
    }
    
    var body: some View {
        
        Text("会話回数:\(countConversation, specifier: "%d")")    // 埋め込み変数piの整形
                    .font(.title)
        
        Text("なかよし度:\(friendship, specifier: "%d")")    // 埋め込み変数piの整形
                    .font(.title)
        
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
                        Alert(title: Text("マイクの使用または音声の認識が許可されていませんよ"))
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


