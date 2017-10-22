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
    @IBOutlet weak var textView: UITextView!
    
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
//                print(results)
//                let typeS = String(describing: type(of: results))
//                print(typeS)
                self.textView.text = results.bestTranscript
                //会話文全部
                let conver = results.bestTranscript
                let converUTF8 = conver.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                print(converUTF8)

//                test
//                let result = String(data: conver, encoding: String.Encoding.utf8)!
                
                let url: NSURL = NSURL(string: "http://52.199.175.14:8080/connecttest/"+converUTF8!)!
                let body: NSMutableDictionary = NSMutableDictionary()
                body.setValue("value", forKey: "key")
                
                do {
                    try self.request.post(url: url as URL , body: body, completionHandler: { data, response, error in
                        // code
                    })
                } catch {
                    
                    print("error")
                }
//                print(self.textView.text)
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
            
            // define callbacks
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
}
