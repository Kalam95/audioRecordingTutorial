//
//  CallKit.swift
//  ExampleAppForVonageSDk
//
//  Created by Mehboob Alam on 14.06.24.
//

import CallKit
import UserNotifications
import Combine
import VonageClientSDKVoice
import UIKit
import PushKit

extension ViewDelegate: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        provider.setDelegate(self, queue: nil)
//        self.callProvider = provider
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard !callID.isEmpty else {
            action.fail()
            return
        }
        self.client.answer(callID) { error in
            self.cancelType = .hangup
            print("Answered with: ", error ?? "Success")
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Starting server call ....")
        self.cancelType = .hangup
        client.serverCall(["callee":"alam", "callType": "app"]) { error, callID in
            if let callID = callID {
                self.callID = callID
            }
            print("Server call responsed with: ", error ?? "no error", " CallId: \(callID ?? "null")" )
        }
        action.fulfill()
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard !callID.isEmpty else {
            action.fail()
            return
        }
        switch cancelType {
        case .reject:
            client.reject(callID) { error in
                self.cancelType = .none
                print("Error in reject: ", error ?? "no error")
                
            }
        case .hangup:
            client.hangup(callID) { error in
                self.cancelType = .none
                print("Error in Hangup: ", error ?? "no error")
            }
        case .none:
            print("unknown hangup")
            
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        VGVoiceClient.enableAudio(audioSession)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        VGVoiceClient.disableAudio(audioSession)
    }
}

