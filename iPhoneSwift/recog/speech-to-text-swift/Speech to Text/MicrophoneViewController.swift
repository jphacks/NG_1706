/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import SpeechToTextV1

class MicrophoneViewController: UIViewController, URLSessionTaskDelegate {

    var speechToText: SpeechToText!
    var speechToTextSession: SpeechToTextSession!
    var isStreaming = false
    var honbun = ""
    var honyakugo = ""
    //key(単語),value(意味)の表示
    var keyTemp = ""
    var key1 = ""
    var key2 = ""
    var key3 = ""
    var valueTemp = ""
    var value1 = ""
    var value2 = ""
    var value3 = ""
    var memo1: String = ""
    var memo2: String = ""
    var memo3: String = ""


    //    nsurlsession
    let request: Request = Request()
    
    @IBOutlet weak var microphoneButton: UIButton!
    
    //textViewの中身を切り替える
    @IBOutlet weak var translateButton: UIButton!
    
    //会話内容を表示するView
    @IBOutlet weak var textView: UITextView!
    
    //出現単語とその解説を表示するView
    @IBOutlet weak var wordView1: UITextView!
    @IBOutlet weak var wordView2: UITextView!
    @IBOutlet weak var wordView3: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        speechToTextSession = SpeechToTextSession(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
    }
    
    @IBAction func didPressMicrophoneButton(_ sender: UIButton) {
        
        streamMicrophoneBasic(wordView1,wordView2,wordView3)
//        print("memo1"+memo1)
//
//        self.wordView1.text = memo1
//        self.wordView2.text = memo2
//        self.wordView3.text = memo3
    }

    
    /**
     This function demonstrates how to use the basic
     `SpeechToText` class to transcribe microphone audio.
     */
    public func streamMicrophoneBasic( _: UITextView!, _: UITextView!, _: UITextView!) {
//        var memo1 = ""
//        var memo2 = ""
//        var memo3 = ""
        
//        weak var wordView1: UITextView!
//        weak var wordView2: UITextView!
//        weak var wordView3: UITextView!
        print("test1")
        if !isStreaming {
            // update state
            microphoneButton.setTitle("会話終了", for: .normal)
            isStreaming = true
            print("test2")
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.interimResults = true
            
            // define error function
            let failure = { (error: Error) in print(error) }
            
            // start recognizing microphone audio
            speechToText.recognizeMicrophone(settings: settings, model: "ja-JP_BroadbandModel", failure: failure) {
                results in
                print("test3")
                //会話文挿入
                self.textView.text = results.bestTranscript
//                print(self.memo1)
                self.wordView1.text = self.memo1
                self.wordView2.text = self.memo2
                self.wordView3.text = self.memo3
                //if(translate == true)
                //translateButton 押したときよう
                self.honbun = results.bestTranscript
                //会話文全部(stringのurlエンコードをutf-8に変更)
                let conver = results.bestTranscript
                let converUTF8 = conver.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
                //http通信
                let url: NSURL = NSURL(string: "http://52.199.175.14:8080/exchangejk/"+converUTF8!)!
                //たぶん何もしてない
                let body: NSMutableDictionary = NSMutableDictionary()
                body.setValue("value", forKey: "key")
                
                do {
                    //送信
                    print("test4")
                    try self.request.post(url: url as URL , body: body, completionHandler: { data, response, error in
                        // code
//                        print(String(describing: type(of: data)))
                        let str = String(data: data!, encoding: .utf8)!
                        print(str)
                        print("test5")
                        do {
                            print("test6")
                            let demo = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) // JSONパース。optionsは型推論可
                            let top = demo as! NSDictionary // トップレベルが配列
                                print(top["status"] as! String) //200
                                print(top["message"] as! String) // 本文
                            let find_phrase = top["find_phrase"] as! NSDictionary
                            for (key, value) in find_phrase {
                                print(key)
                                self.keyTemp = key as! String
                                print(value)
                                self.valueTemp = value as! String
                            }
//                            }
                        } catch {
                            print(error) // パースに失敗したときにエラーを表示
                        }
                        // 単語，意味更新
                        if(self.key1 != self.keyTemp){
                            self.key3 = self.key2
                            self.key2 = self.key1
                            self.key1 = self.keyTemp
                            self.value3 = self.value2
                            self.value2 = self.value1
                            self.value1 = self.valueTemp
                            
                            //countに応じてwordViewを表示&更新
                            self.memo1 = self.key1 + ":" + self.value1
                            self.memo2 = self.key2 + ":" + self.value2
                            self.memo3 = self.key3 + ":" + self.value3
                        }
                        
                    })
                    
                } catch {
                    print("error")
                }
            }
        } else {
            // update state
            microphoneButton.setTitle("会話開始", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToText.stopRecognizeMicrophone()
        }
//        return (memo1, memo2, memo3)
    }
    
    
    /**
     This function demonstrates how to use the more advanced
     `SpeechToTextSession` class to transcribe microphone audio.
     */
    public func streamMicrophoneAdvanced() {
        if !isStreaming {
            
            // update state
            microphoneButton.setTitle("Stop Microphone", for: .normal)
            isStreaming = true
            
            // define callbacks//
            speechToTextSession.onConnect = { print("connected") }
            speechToTextSession.onDisconnect = { print("disconnected") }
            speechToTextSession.onError = { error in print(error) }
            speechToTextSession.onPowerData = { decibels in print(decibels) }
            speechToTextSession.onMicrophoneData = { data in print("received data") }
            speechToTextSession.onResults = { results in self.textView.text = results.bestTranscript }
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.interimResults = true
            
            // start recognizing microphone audio
            speechToTextSession.connect()
            speechToTextSession.startRequest(settings: settings)
            speechToTextSession.startMicrophone()
        } else {
            // update state
            microphoneButton.setTitle("Start Microphone", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToTextSession.stopMicrophone()
            speechToTextSession.stopRequest()
            speechToTextSession.disconnect()
        }
    }
    
    var count: Int = 1
    var onJK = false
    //translateButtonを押した時のイベント
    //グローバルに原文と標準語を切り替える用のboolを用意
    //イベントにpostする部分を実装し返った
    @IBAction func translateButtonTouchDown(_ sender: Any) {
        if (onJK == false) {
            onJK = true
        }else{
            onJK = false
        }
        //会話文全部(stringのurlエンコードをutf-8に変更)
        let converUTF8 = honbun.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
            let url: NSURL = NSURL(string: "http://52.199.175.14:8080/exchangejk/"+converUTF8!)!
         if(onJK == true){
            let url: NSURL = NSURL(string: "http://52.199.175.14:8080/reverse_exchangejk/"+converUTF8!)!
        }
        //たぶん何もしてない
        let body: NSMutableDictionary = NSMutableDictionary()
        body.setValue("value", forKey: "key")
        
        do {
            //送信
            try self.request.post(url: url as URL , body: body, completionHandler: { data, response, error in
                // code
                
                let str = String(data: data!, encoding: .utf8)!
                print(str)
                do {
                    let demo = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) // JSONパース。optionsは型推論可
                    let top = demo as! NSDictionary // トップレベルが配列
                    print(top["status"] as! String) //200
                    print(top["message"] as! String) // 本文
                    self.honyakugo = top["message"] as! String
                    //                            }
                } catch {
                    print(error) // パースに失敗したときにエラーを表示
                }
            })
        } catch {
            print("error")
        }
       
        //インクリメント
        count+=1;
//        return(wordView1,wordView2,wordView3)
    }
}
