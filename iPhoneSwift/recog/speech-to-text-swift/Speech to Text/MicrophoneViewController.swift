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

    //    nsurlsession
    let request: Request = Request()
//    let urlString = "http://52.199.175.14:8080/"
//    let config = URLSessionConfiguration.default
//    let session = URLSession.shared
//    var req = URLRequest(url: URL(string: "http://52.199.175.14:8080/connecttest/")!)
//    var req = URL(String: "http://52.199.175.14:8080/")
    
    
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
        streamMicrophoneBasic()
    }
    
    /**
     This function demonstrates how to use the basic
     `SpeechToText` class to transcribe microphone audio.
     */
    public func streamMicrophoneBasic() {
        if !isStreaming {
            
            // update state
            microphoneButton.setTitle("会話終了", for: .normal)
            isStreaming = true
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.interimResults = true
            
            // define error function
            let failure = { (error: Error) in print(error) }
            
            // start recognizing microphone audio
            speechToText.recognizeMicrophone(settings: settings, model: "ja-JP_BroadbandModel", failure: failure) {
                results in
                //会話文挿入
                self.textView.text = results.bestTranscript
                //if(translate == true)
                //会話文全部(stringのurlエンコードをutf-8に変更)
                let conver = results.bestTranscript
                let converUTF8 = conver.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                
//                let url: NSURL = NSURL(string: "http://52.199.175.14:8080/exchangejk/"+converUTF8!)!

                print(converUTF8!)
                
                //http通信
                let url: NSURL = NSURL(string: "http://52.199.175.14:8080/connecttest/"+converUTF8!)!
                //たぶん何もしてない
                let body: NSMutableDictionary = NSMutableDictionary()
                body.setValue("value", forKey: "key")
                
                do {
                    //送信
                    try self.request.post(url: url as URL , body: body, completionHandler: { data, response, error in
                        // code
                        print("data:")
                        print(data) 
                        print("\n")

//                        print(String(describing: type(of: data)))
//                        print("result:")
//                        var result = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
//                        print(result)
//                        print(String(describing: type(of: result)))
//                        print("\n")
                        
                        let str = String(data: data!, encoding: .utf8)!
                        print(str)
                        do {
                            let demo = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) // JSONパース。optionsは型推論可(".allowFragmets"等)
                            let top = demo as! NSDictionary // トップレベルが配列
//                            for roop in top {
//                                let next = roop as! NSDictionary
                                print(top["status"] as! String) // 1, 2 が表示
                            
//                                let content = next!["content"] as! NSDictionary
                                print(top["message"] as! String) // 25, 20 が表示
                            let find_phrase = top["find_phrase"] as! NSDictionary
                            for (key, value) in find_phrase {
                                print(key)
                                print(value)
                            }
//                            }
                        } catch {
                            print(error) // パースに失敗したときにエラーを表示
                        }
                        
                    })
                    
                } catch {
                    print("error")
                }
                //print(self.textView.text)
            }
        } else {
            // update state
            microphoneButton.setTitle("会話開始", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToText.stopRecognizeMicrophone()
        }
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
    //translateButtonを押した時のイベント
    //グローバルに原文と標準語を切り替える用のboolを用意
    //イベントにpostする部分を実装し返った
    @IBAction func translateButtonTouchDown(_ sender: Any) {
        //countを表示
        textView.text = "\(count)回押したな";
        
        //countに応じてwordViewを表示&更新
        if(count>=1) {wordView1.isHidden = false;}
        if(count>=2) {wordView2.isHidden = false;}
        if(count>=3) {wordView3.isHidden = false;}
        wordView1.text = "\(count)";
        wordView2.text = "\(count - 1)";
        wordView3.text = "\(count - 2)";
        
        //インクリメント
        count+=1;
    }
}
