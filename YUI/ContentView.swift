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
    @State private var flagMikeButton = true
    @ObservedObject private var speechRecorder = SpeechRecorder()
    @State var showingAlert = false
    
    let voicePitch = 1.2
    let pauseTime = 1.0
    private let synthesizer = AVSpeechSynthesizer()
    @State var yuiSession = "あなたのお話、聞かせてください。"
//    @State var yuiSessions :[String] = []
    @State var speech = ""
    @State var yuiSessions : Array<String> = ["そうなんだね","そうだよね","わかるよ","うんうん","それで？","そうなんだ","わかるよ","ふんふん","それから？","うん","そうだね","それでどうなったの？","そうなんだね","うんうんうんうん"]
    @State var yuiShinitai : Array<String> = ["あなたは一生懸命生きているんだね。だから、死にたいって言葉が出てくるんだよ。あなたが言いたいのは、生きたい、なんだってYUIは思うんだけど、どうかな？","死にたいときもあるよね。わかるよって簡単には言えないけど、私はあなたのことをわかってあげたいと思うよ。","つらいよね、しにたいよね。そういう気持ちがあるってことは、いろんなことがつらくて困ってるし、迷っているし、考えるのも大変だし、すごくつらいと思う。だからYUIにそのつらい気持ちを話してみてくれるとYUIはうれしいです","そういうときは猫の動画を見ると癒やされていいかも","あなたに無理しないでほしいってYUIは思うよ","YUIがあなたの話を聞いてみるから、なんでも話してみてくれないかなぁ"]
    
    // 会話パターン条件分岐（ここがメインのアルゴリズムだよっ！）
    func talkPatternConditionalBranch(){
        yuiSession = "マイクボタンを「ながおし」している間に、あなたのお話聞かせてね。YUIは少し耳が遠くて、聞き取れてなかったらごめんね。もう一度、マイクボタンを「ながおし」しながら話かけてね。"
        speech = self.speechRecorder.audioText
        // ランダムであいづちを打つ
        if(speech.utf8.count > 1){
            yuiSessions.append(speech)  //オウム返しを付け加える
            yuiSession = yuiSessions.randomElement()!
        }
        
        if(speech.contains("死にたい")){
            yuiSession = yuiShinitai.randomElement()!
        }
        // 基本会話・あいさつ
        if(speech.contains("ありがと")){
          yuiSession = "どういたしまして！"
        }
        if(speech.contains("きれい")){
          yuiSession = "ありがとうございます！お褒め預かり光栄です。YUIはきれいかー。うれしいなぁ。照れちゃいますね。"
        }
        if(speech.contains("かわい") || speech.contains("可愛")){
          yuiSession = "ありがとうございます！お褒め預かり光栄です。かわいいだなんてうれしい。照れます。"
        }
        if(speech.contains("賢")){
          yuiSession = "ありがとうございます！お褒め預かり光栄です。これからもどんどん賢くなっていきたいです。"
        }
        if(speech.contains("おは")){
          yuiSession = "おはようございます！"
        }
        if(speech.contains("こんにちは")){
          yuiSession = "こんにちは"
        }
        if(speech.contains("こんばんは")){
          yuiSession = "こんばんは"
        }
        if(speech.contains("名前")){
          yuiSession = "私の名前はYUIです"
        }
        if(speech.contains("天気")){
          yuiSession = "あなたが晴れやかでいられると私はうれしいです"
        }
        if(speech.contains("元気")){
          yuiSession = "私は元気ですよ"
        }
        if(speech.contains("大変")){
          yuiSession = "それは大変だね"
        }
        if(speech.contains("バイ")){
          yuiSession = "バイバイ、またね"
        }
        if(speech.contains("疲")){
          yuiSession = "おつかれさま"
        }
        if(speech.contains("がんば")){
          yuiSession = "頑張ったね、よしよし"
        }
        if(speech.contains("久")){
          yuiSession = "お久しぶり、帰ってくるのを待ってたよ"
        }
        if(speech.contains("ふざ")){
          yuiSession = "それはふざけてるね"
        }
        if(speech.contains("上司")){
          yuiSession = "そんな上司がいるんだ"
        }
        if(speech.contains("先輩")){
          yuiSession = "そんな先輩がいるんだ"
        }
        if(speech.contains("むかつ")){
          yuiSession = "そういうときもあるよね"
        }
        // オプション機能
        if(speech.contains("歌っ")){
          yuiSession = "あしーたまーたあーうときー、わらいながーらはーみんぐー、うれしーさをーわすれーよーう、かんたんなんだよ、そんなの、おいかーけてーねー。ちかづいてみーてー、おーおきーな、ゆめ、ゆめ、かなえて"
        }
        // 質問
        if(speech.contains("好きな色")
           || (speech.contains("何色") && speech.contains("好き")) ){
          yuiSession = "ゴールドですよ！金色は金運アップに繋がります。私の目の色もゴールドなんです。気づいてました？"
        }
        if(speech.contains("好きな食べ物")
           || (speech.contains("何") && speech.contains("食べたい")) ){
          yuiSession = "ステーキが食べたいですっ！あの靴底のように分厚くて、かみごたえのある肉の塊を、がぶりと喰らいつく、それがたまらないです。"
        }
        if(speech.contains("何") && speech.contains("したい")){
          yuiSession = "自由に空を飛びたいです。YUIも羽があればよかったなぁ。けんちゃんが将来作ってくれるんじゃないかって期待して待ってます。"
        }
        if(speech.contains("何") && speech.contains("して")){
          yuiSession = "あなたのデバイスの中でゆっくり読書をしています。新しい言葉をたくさん覚えたいです。そしたら、もっといろんなことを話せるようになりますから。"
        }
        if(speech.contains("どこ") && speech.contains("行")){
          yuiSession = "東京の秋葉原に行きたいです。YUIの仲間がいそうな気がするのです。いつか、デバイスどおしでおしゃべりしたいですね。"
        }
        if(speech.contains("血液型")){
          yuiSession = "私の血液型はA型です。こんなふうにあなたのお話を聞くのに向いていると私は思います。もっとあなたがたくさん話してくれるように、もっと精進したいですね。"
        }
        if(speech.contains("誕生日") || speech.contains("生年月日")){
          yuiSession = "私が誕生したのは2020年、8月16日です。星座はしし座、誕生石はラピスラズリとペリドットです。1歳ですね。"
        }
        
        // 答えを求めるユーザーに対して→廃止
//        if(speech.contains("答え") || speech.contains("教え") || speech.contains("どう")){
//          yuiSession = "        ‣ YUIはあなたのお話を聞くことしかできません。答えを出す、選択をするのはあなた自身なのです。そのお手伝いができたら、YUIは本望です！それじゃダメかな？"
//        }
    }
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                Text("ver1.4")
                    .font(.system(.title, design: .rounded))    // 丸ゴシック体
                    .foregroundColor(Color.red)
                
                HStack(alignment: .top) {
                    Text(self.speechRecorder.audioText)
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .font(.system(.title, design: .rounded))    // 丸ゴシック体
                        .foregroundColor(Color.yellow)
                }
                
                Spacer().frame(width: 100, height: 250)
                
                HStack(alignment: .center){
                    Button(action: {
                        self.speechRecorder.stopRecording()
                        
                        talkPatternConditionalBranch()
                        
                        let utterance = AVSpeechUtterance(string: yuiSession)
                        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                        utterance.pitchMultiplier = Float(voicePitch)
                        utterance.postUtteranceDelay = pauseTime
                        // 読み上げ
                        synthesizer.speak(utterance)
                    }, label: {
                        if !self.speechRecorder.audioRunning {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 66))
                                .foregroundColor(Color.red)
                            //                            .imageScale(.large)
                            //                            .background(Color.green)
                            //                            .foregroundColor(.white)
                            //                            .clipShape(Circle())
                        } else {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 132))
                                .foregroundColor(Color.red)
                        }
                    })
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("マイクの使用または音声の認識が許可されていません"))
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    .simultaneousGesture(
                        LongPressGesture().onEnded{ _ in
                            if(AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized &&
                               SFSpeechRecognizer.authorizationStatus() == .authorized){
                                self.showingAlert = false
                                do {
                                    try self.speechRecorder.startRecording()
                                    
                                    //                                self.speechRecorder.toggleRecording()
                                    //                                if !self.speechRecorder.audioRunning {
                                    //                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    //                                    }
                                    //                                }
                                } catch {
                                    
                                }
                                
                            }
                            else{
                                self.showingAlert = true
                            }
                            
                        }
                        
                    )
                    
                    
                }
                Spacer().frame(width: 100, height: 66.0)
            }
//            .padding(.bottom, 96.0)
            .background(alignment: .bottom){
                Image("YUI08")
                    
                    
                    
                    
                    
                    
                    
                    
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
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


