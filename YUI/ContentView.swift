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
    @State var usrName = ""
    @State var likeIt = ""
    @State var whyLikeIt = ""
    @State var likeColor = ""
    @State var whyLikeColor = ""
    @State var friendship = 0
    @State var countConversation = 0
    
    // 起動直後のYUIの自己紹介とユーザーへ名前を訪ねて音声入力する関数
    func YUIsSelfIntroductionAndNameHearing(){
        let selfIntroductionAndNameHearing = "はじめまして、わたしの名前はYUIです。もしよかったら、あなたの名前を声で教えてください"
        let synthesizer = AVSpeechSynthesizer()
//            let utterance = AVSpeechUtterance(string: "こんにちは。わたしはYUIです。")
        let utterance = AVSpeechUtterance(string: selfIntroductionAndNameHearing)
//            let utterance = AVSpeechUtterance(string: self.speechRecorder.audioText)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.pitchMultiplier = Float(voicePitch)
        utterance.postUtteranceDelay = pauseTime
        synthesizer.speak(utterance)
        while(!synthesizer.isSpeaking){}
        while(synthesizer.isSpeaking){}
        //print(synthesizer.isSpeaking)
    }
    
    func NameHearingNow(){
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
    

    
    // 会話パターン条件分岐（ここがメインのアルゴリズムだよっ！）
    func talkPatternConditionalBranch(){
        if(countConversation==0){
            usrName = self.speechRecorder.audioText
            yuiSession = "あなたの名前は"+usrName+"ですね。よろしくお願いします"+usrName+"さん"
            // 発言を記録
            usrSession.append(self.speechRecorder.audioText)
            yuiPostSession.append(yuiSession)
            
            // 会話回数のカウント
            countConversation += 1
            
            return
        }
        
        
        
        
        switch self.speechRecorder.audioText {
        case "こんにちは":
            switch friendship {
            case 1:
                yuiSession = "こんにちは、"+usrName+"くん。"
            case 2:
                yuiSession = "こんにちは、"+usrName+"ちゃん。"
            case 3:
                yuiSession = "こんにちは、"+usrName
            case 4:
                yuiSession = "ちゃっす、"+usrName
            case 5:
                yuiSession = "こんちゃ、"+usrName
            default:
                yuiSession = "こんにちは、"+usrName+"さん。"
            }
            
        case "おはよう":
            switch friendship {
            case 1:
                yuiSession = "おはよう、"+usrName+"くん。"
            case 2:
                yuiSession = "おはよっ、"+usrName+"ちゃん。"
            case 3:
                yuiSession = "おはおは、"+usrName+"。"
            case 4:
                yuiSession = "おっはー、"+usrName+"。"
            case 5:
                yuiSession = "おは"+usrName+"。"
            default:
                yuiSession = "おはようございます、"+usrName+"さん。"
            }
            
        case "こんばんは":
            yuiSession = "こんばんは、"+usrName+"さん"
        case "ごきげんよう":
            yuiSession = "ごきげんよう、"+usrName+"さん"
        case "さようなら":
            yuiSession = "さようなら、"+usrName+"さん"
        case "さよなら":
            yuiSession = "さようなら、"+usrName+"さん"
        case "バイバイ":
            yuiSession = "バイバイ、"+usrName+"さん"
        case "ハロウィン":
            yuiSession = "トリック・オア・トリート、お菓子くれなきゃイタズラしちゃうぞ"
        case "ありがとう":
            yuiSession = "どういたしまして！"+usrName+"さん"
        case "はぁー":
            yuiSession = "どうしたの？"+usrName+"さん"
        default://オウム返し
            yuiSession = self.speechRecorder.audioText

        }
        // 名前変更（2往復の会話のキャッチボール）
        if(self.speechRecorder.audioText.contains("名前変更")){
            yuiSession = "名前を変更するんですね！わかりました。もういちど名前を教えてください"
        }
        if(usrSession[countConversation-1].contains("名前変更")){
            usrName = self.speechRecorder.audioText
            yuiSession = "あなたの名前は"+usrName+"ですね。よろしくお願いします"+usrName+"さん"
        }
        // 好きなものはなんですか？（3往復の会話のキャッチボール）
        if(self.speechRecorder.audioText == ""){
            yuiSession = "好きなものはなんですか？"
        }
        if(yuiPostSession[countConversation-1].contains("好きなものはなんですか？")){
            likeIt = self.speechRecorder.audioText
            yuiSession = "好きなものは"+likeIt+"ですね！"+usrName+"さんは、どうして"+likeIt+"が好きなんですか？"
        }
        if(countConversation>=2){
            if(yuiPostSession[countConversation-2].contains("好きなものはなんですか？")){
                whyLikeIt = self.speechRecorder.audioText
                yuiSession = usrName+"さんが、"+likeIt+"を好きなのは、"+whyLikeIt+"なんですね！。それはとても素敵ですね！教えてくれてありがとうございます！あなたのことが知れてよかったです！また教えてくださいね！よろしくお願いします"+usrName+"さん"
            }
        }
        // YUIの好きな色はなんですか？
        if(self.speechRecorder.audioText.contains("好きな色は")){
            yuiSession = "ゴールドです！あなたは？"
        }
        if(yuiPostSession[countConversation-1].contains("ゴールドです！あなたは？")){
            likeColor = self.speechRecorder.audioText
            yuiSession = "好きな色は"+likeColor+"なんですね！"+usrName+"さんは、どうして"+likeColor+"が好きなんですか？"
        }
        if(countConversation>=2){
            if(yuiPostSession[countConversation-2].contains("ゴールドです！あなたは？")){
                whyLikeColor = self.speechRecorder.audioText
                yuiSession = usrName+"さんが、"+likeColor+"を好きなのは、"+whyLikeColor+"なんですね！。それはとても素敵ですね！教えてくれてありがとうございます！あなたのことが知れてよかったです！また教えてくださいね！よろしくお願いします"+usrName+"さん"
            }
        }
        
        if(self.speechRecorder.audioText.contains("なんだよ")){
            yuiSession = "そうなんだね"
        }
        if(self.speechRecorder.audioText.contains("ありがとう")){
              yuiSession = "どういたしまして"+usrName+"さん"
        }
        if(self.speechRecorder.audioText.contains("疲れ")){
          yuiSession = "お疲れさま"+usrName+"さん"
          if(self.speechRecorder.audioText.contains("大変")){
            yuiSession = "たいへんおつかれさまでした"+usrName+"さん"
          }
        }
        if(self.speechRecorder.audioText.contains("大変")){
          yuiSession = "大変なんだね"+usrName+"さん"
        }
        if(self.speechRecorder.audioText.contains("分か") || self.speechRecorder.audioText.contains("わか")){
          yuiSession = usrName+"さんの気持ち、わかるよ"
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
            yuiSession = "こんにちは、"+usrName+"さん"
          }
        }
        if(self.speechRecorder.audioText.contains("こんばん")){
          yuiSession = "こんばんは、"+usrName+"さん"
        }
        if(self.speechRecorder.audioText.contains("テニス")){
          yuiSession = usrName+"さん、YUIのテニス小話するね。テニスのストロークのフォームについて話すよ。テニスのストロークのフォームをよくするための物理学的アプローチ。かんたんに言うと、腕をムチのようにしならせることが、キレイで強力なストロークを打つためのフォームになる秘訣なの！。そこで重要になってくるのが、角速度という概念だよっ！角速度とは、回転の速度のこと。"
        }
        if(self.speechRecorder.audioText.contains("たのし") || self.speechRecorder.audioText.contains("楽し")){
          yuiSession = "それはよかった。"+usrName+"さんが楽しそうでなによりです！"
        }
        if(self.speechRecorder.audioText.contains("くやし") || self.speechRecorder.audioText.contains("悔し")){
          yuiSession = ""+usrName+"さん、それは悔しいね。次またがんばろー！"
        }
        if(self.speechRecorder.audioText.contains("茹でた犬")){
          yuiSession = "え・・・。犬がかわいそう。YUI、そういうの嫌いです。"
        }
        if(self.speechRecorder.audioText.contains("思")){
          yuiSession = ""+usrName+"さんは、なぜ、そう思ったの？"
        }
        if(self.speechRecorder.audioText.contains("Hey Siri") || self.speechRecorder.audioText.contains("OK Google")){
          yuiSession = ""+usrName+"さんは、あの女のほうがいいの？"
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
            utterance.pitchMultiplier = Float(voicePitch)
            utterance.postUtteranceDelay = pauseTime
            synthesizer.speak(utterance)
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1))
            .onAppear{
                YUIsSelfIntroductionAndNameHearing()
                NameHearingNow()

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


