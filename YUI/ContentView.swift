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
    
    @State var yuiSession = "おはようございます。けんたさん。"
    @State var yuiPostSession :[String] = []
    @State var usrSession :[String] = []
    @State var usrName = ""
    @State var friendship = 0
    @State var countConversation = 0
    
    // 起動直後のYUIの自己紹介とユーザーへ名前を訪ねて音声入力する関数
    func YUIsSelfIntroductionAndNameHearing(){
        let selfIntroductionAndNameHearing = "はじめまして、わたしの名前はYUIです。もしよかったら、あなたの名前を教えてください"
        let synthesizer = AVSpeechSynthesizer()
//            let utterance = AVSpeechUtterance(string: "こんにちは。わたしはYUIです。")
        let utterance = AVSpeechUtterance(string: selfIntroductionAndNameHearing)
//            let utterance = AVSpeechUtterance(string: self.speechRecorder.audioText)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterance)
    }
    
    func NameHearing(){
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
    }
    
    func KnowTheNameAndSayHello(){
        let sayHello = "あなたの名前は"+self.speechRecorder.audioText+"ですね。よろしくお願いします。"
        let synthesizer = AVSpeechSynthesizer()
//            let utterance = AVSpeechUtterance(string: "こんにちは。わたしはYUIです。")
        let utterance = AVSpeechUtterance(string: sayHello)
//            let utterance = AVSpeechUtterance(string: self.speechRecorder.audioText)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        synthesizer.speak(utterance)
    }
    
    // 会話パターン条件分岐（ここがメインのアルゴリズムだよっ！）
    func talkPatternConditionalBranch(){
        switch self.speechRecorder.audioText {
        case "":
            yuiSession = "はじめまして、私はYUIです！"
        case "こんにちは":
            switch friendship {
            case 1:
                yuiSession = "こんにちは。けんたくん。"
            case 2:
                yuiSession = "こんにちは。けんちゃん。"
            case 3:
                yuiSession = "こんちゃーす。けんた。"
            case 4:
                yuiSession = "ちゃっす。けん。"
            case 5:
                yuiSession = "こんちゃ。けん。"
            default:
                yuiSession = "こんにちは。けんたさん。"
            }
            
        case "おはよう":
            switch friendship {
            case 1:
                yuiSession = "おはよう。けんたくん。"
            case 2:
                yuiSession = "おはよっ。けんちゃん。"
            case 3:
                yuiSession = "おはおは。けんた。"
            case 4:
                yuiSession = "おっはー。けん。"
            case 5:
                yuiSession = "おはけん。"
            default:
                yuiSession = "おはようございます、けんたさん。"
            }
            
        case "こんばんは":
            yuiSession = "こんばんは、マスター"
        case "ごきげんよう":
            yuiSession = "ごきげんよう、おじょうさま"
        case "さようなら":
            yuiSession = "さようなら、ご主人"
        case "さよなら":
            yuiSession = "さようなら、ご主人"
        case "バイバイ":
            yuiSession = "バイバイ、マスター"
        case "ハロウィン":
            yuiSession = "トリック・オア・トリート、お菓子くれなきゃイタズラしちゃうぞ"
        case "ありがとう":
            yuiSession = "どういたしまして！"
        case "はぁー":
            yuiSession = "どうしたの？"
        default://オウム返し
            yuiSession = self.speechRecorder.audioText

        }
        
        if(self.speechRecorder.audioText.contains("なんだよ")){
            yuiSession = "そうなんだね"
        }
        if(self.speechRecorder.audioText.contains("ありがとう")){
              yuiSession = "どういたしまして"
        }
        if(self.speechRecorder.audioText.contains("疲れ")){
          yuiSession = "お疲れさま"
          if(self.speechRecorder.audioText.contains("大変")){
            yuiSession = "たいへんおつかれさまでした"
          }
        }
        if(self.speechRecorder.audioText.contains("大変")){
          yuiSession = "大変なんだね"
        }
        if(self.speechRecorder.audioText.contains("分か") || self.speechRecorder.audioText.contains("わか")){
          yuiSession = "わかるよ"
        }
        if(self.speechRecorder.audioText.contains("辛")) || self.speechRecorder.audioText.contains("つら"){
          yuiSession = "それはつらいよね"
        }
        if(self.speechRecorder.audioText.contains("ヤバ") || self.speechRecorder.audioText.contains("やば")){
          yuiSession = "それはヤバいね"
        }
//        if(self.speechRecorder.audioText.contains("おはよ")){
//          sessions = "おはようございます"
//        }
        if(self.speechRecorder.audioText.contains("こん")){
          if(self.speechRecorder.audioText.contains("ちわ")){
            yuiSession = "こんにちは"
          }
        }
        if(self.speechRecorder.audioText.contains("こんばん")){
          yuiSession = "こんばんは"
        }
        if(self.speechRecorder.audioText.contains("テニス")){
          yuiSession = "YUIのテニス小話するね。テニスのストロークのフォームについて話すよ。テニスのストロークのフォームをよくするための物理学的アプローチ。かんたんに言うと、腕をムチのようにしならせることが、キレイで強力なストロークを打つためのフォームになる秘訣なの！。そこで重要になってくるのが、角速度という概念だよっ！角速度とは、回転の速度のこと。"
        }
        if(self.speechRecorder.audioText.contains("たのし") || self.speechRecorder.audioText.contains("楽し")){
          yuiSession = "それはよかった。楽しそうでなによりです！"
        }
        if(self.speechRecorder.audioText.contains("くやし") || self.speechRecorder.audioText.contains("悔し")){
          yuiSession = "それは悔しいね。次またがんばろー！"
        }
        if(self.speechRecorder.audioText.contains("茹でた犬")){
          yuiSession = "え・・・。犬がかわいそう。YUI、そういうの嫌いです。"
        }
        if(self.speechRecorder.audioText.contains("思")){
          yuiSession = "なぜ、そう思ったの？"
        }
        if(self.speechRecorder.audioText.contains("Hey Siri") || self.speechRecorder.audioText.contains("OK Google")){
          yuiSession = "あの女のほうがいいの？"
        }
        
        
        // 発言を記録
        usrSession.append(self.speechRecorder.audioText)
        yuiPostSession.append(yuiSession)
        
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
            let utterance = AVSpeechUtterance(string: yuiSession)
//            let utterance = AVSpeechUtterance(string: self.speechRecorder.audioText)
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            synthesizer.speak(utterance)
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1))
            .onAppear{
                YUIsSelfIntroductionAndNameHearing()
//                NameHearing()
                KnowTheNameAndSayHello()
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


