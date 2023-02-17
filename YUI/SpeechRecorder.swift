//
//  SpeechRecorder.swift
//  YUI
//
//  Created by 森田健太 on 2022/02/10.
//
//
//  SpeechRecorder.swift
//  VoiceToText
//
//  Created by webmaster on 2020/06/14.
//  Copyright © 2020 SERVERNOTE.NET. All rights reserved.
//
import Foundation
import Combine
import AVFoundation
import Speech
 
final class SpeechRecorder: ObservableObject {
    @Published var audioText: String = ""
    @Published var audioRunning: Bool = false
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func toggleRecording(){
        if self.audioEngine.isRunning {
            self.stopRecording()
        }
        else{
            try! self.startRecording()
        }
    }
    
    func stopRecording(){
        self.recognitionTask?.cancel()
        self.recognitionTask?.finish()
        self.recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.audioEngine.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch{
            print("AVAudioSession error")
        }
        self.audioRunning = false
    }
    
    func startRecording() throws {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        self.recognitionTask = SFSpeechRecognitionTask()
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        if(self.recognitionTask == nil || self.recognitionRequest == nil){
            self.stopRecording()
            return
        }
        self.audioText = ""
        recognitionRequest?.shouldReportPartialResults = true
        if #available(iOS 13, *) {
            recognitionRequest?.requiresOnDeviceRecognition = false
        }
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if(error != nil){
                print (String(describing: error))
                self.stopRecording()
                return
            }
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                self.audioText = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
            }
            if isFinal { //録音タイムリミット
                print("recording time limit")
                self.stopRecording()
                inputNode.removeTap(onBus: 0)
            }
        }
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
            
            /*
            // 無音期間をカウントする変数
            var silenceCount = 0
            
            // 閾値
            let threshold = 0.1

            // 平均電力レベルを取得
            let averagePowerLevel = buffer.averagePowerLevel
            // 平均電力レベルがしきい値よりも小さい場合
            if averagePowerLevel < threshold {
                // 無音期間をカウント
                silenceCount += 1
            } else {
                // 無音期間をリセット
                silenceCount = 0
            }
            // 無音期間が数秒以上続いた場合
            if silenceCount >= 3 {
                // 音声認識を終了
                audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                recognitionRequest.endAudio()
                // 無音期間をリセット
                silenceCount = 0
            }
             
             */

            
//            // 無音を検出するための閾値
//            let threshold = 0.01
//            // 音声を格納したAVAudioPCMBufferから、各フレームの大きさを計算
//            let frameSizes = buffer.floatChannelData!.map { abs($0.pointee) }
//            // 無音を検出する
//            let isSilence = frameSizes.allSatisfy { $0 < threshold }

            
            /*
            // 無音期間をカウントし、数秒経ったら音声認識をやめる
            let threshold = 2.0 // 無音期間の閾値（秒）
            var silenceCount = 0.0 // 無音期間のカウント（秒）
            let silenceThreshold = Double(recordingFormat.sampleRate) * Double(threshold) / Double(buffer.frameLength)
            for i in 0..<Int(buffer.frameLength) {
                if buffer.floatChannelData?[0][i] == 0 {
                    silenceCount += 1
                }
                if silenceCount > silenceThreshold {
                    // 音声認識をやめる
                    self.recognitionRequest?.endAudio()
                    self.recognitionTask?.cancel()
                    self.recognitionTask = nil
                    break
                }
            }
             
             */
        }
        
//        // Check for silence after a few seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            if self.audioEngine.isRunning {
//                self.audioEngine.stop()
//                self.recognitionRequest?.endAudio()
//            }
//        }
        
        
        
        self.audioEngine.prepare()
        try self.audioEngine.start()
        self.audioRunning = true
    }
    
//    func detectFinishReadingAndStop() throws {
//        if((SFSpeechRecognitionTaskDelegate.speechRecognitionTaskFinishedReadingAudio(self.recognitionTask as! SFSpeechRecognitionTaskDelegate) != nil) == false){
//            try self.stopRecording()
//        }
//    }
}
