//
//  ViewDelegate.swift
//  ExampleAppForVonageSDk
//
//  Created by Mehboob Alam on 06.06.24.
//


import AVFoundation
import SwiftUI
import UIKit
import CallKit
import VonageClientSDKVoice
import Combine

enum CallCancelType {
    case hangup, reject
}

class ViewDelegate: NSObject, ObservableObject {
    @Published var fileSize: String = "0"
    @Published var showCallAlert = false
//    private var callUUID: UUID?  // for call kit
    private(set) var audioFileUrl: URL!
    private var audioRecorder: AVAudioRecorder!
    private(set) var player: AVAudioPlayer?
    private(set) var callController: CXCallController!
    
    let client: VGVoiceClient
    var cancelType: CallCancelType?
//    var callProvider: CXProvider
    var callID = ""
    let recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    override init() {
        let config = VGClientInitConfig(
            //disableInternalLogger: true,
            //            customLoggers: [customLogger],
            loggingLevel: VGLoggingLevel.error, region: .US,
            rtcStatsTelemetry: false
        );
        
        config.enableWebsocketInvites = true
        VGVoiceClient.isUsingCallKit = false // should be true if using call kit
        client = VGVoiceClient(config)
//        callProvider = .init(configuration: .init())
        super.init()
        client.delegate = self
//        callProvider.setDelegate(self, queue: .main)
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                if allowed {
                    print("Recording allowed")
                } else {
                    print("Recording is not allowed")
                }
            }
        } catch {
            print("Recording permission failed!!")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(Int.random(in: 0..<1000)).m4a")// generating file path with any random number
        audioFileUrl = audioFilename
        print("Recording url: ", audioFilename)
        let settings = [
            AVSampleRateKey: 12000,
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            audioRecorder.delegate = self
            DispatchQueue.main.async {
                self.audioRecorder.prepareToRecord()
                self.audioRecorder.isMeteringEnabled = true
                self.audioRecorder.record()
                print("System time when recording started: ", Date())
                print("File Size during recording: \(self.fileSize)")
            }
        } catch {
            fileSize = ("failed to record")
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        if !success {
            print("failed to record")
        }
        guard let url = self.audioFileUrl else { return }
        self.audioRecorder?.stop()
        print("System time when recording finished: ", Date())
        Task.detached {
            let size = await (try? AVURLAsset(url: url).load(.duration).seconds.description) ?? ""
            DispatchQueue.main.async {
                self.fileSize = size
            }
            print("Recording finished with file size", size)
        }
        self.audioRecorder = nil
        
    }
    
    func call() {
        //        Start call via call kit else comment new few[callkit call registration lines]
        //        let uuid = UUID()
        //        let handle = CXHandle(type: .generic, value: "serverCall")
        //        callUUID = uuid
        //        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        //        let transaction = CXTransaction(action: startCallAction)
        //        self.callController = CXCallController(queue: .main)
        //        callController.request(transaction) { error in
        //            print("Callkit returned with: ", error ?? "Success")
        //        }
        //        if not using callkit
        client.serverCall { error, callId in
            self.callID = callId ?? ""
            print("Server call  request is returned with: ", error ?? "Success")
        }
    }
    
    func hangup() {
        client.hangup(callID) { error in
            print("Call hangup with: ", error ?? "Success")
        }
    }
    
    func createSession() {
        client.createSession("eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJNYXggTlBFIEFwcCIsImlhdCI6MTcxODc4Mzc2MywibmJmIjoxNzE4NzgzNzYzLCJleHAiOjE3MjM5Njc3OTMsImp0aSI6IjE3MTg3ODM3OTMyNDYiLCJhcHBsaWNhdGlvbl9pZCI6IjRmZWQzZDdhLTNmNjUtNDM2ZC04N2RkLTc3NTEzOTRhYTQzMyIsImFjbCI6eyJwYXRocyI6eyIvKi91c2Vycy8qKiI6e30sIi8qL2NvbnZlcnNhdGlvbnMvKioiOnt9LCIvKi9zZXNzaW9ucy8qKiI6e30sIi8qL2RldmljZXMvKioiOnt9LCIvKi9pbWFnZS8qKiI6e30sIi8qL21lZGlhLyoqIjp7fSwiLyovYXBwbGljYXRpb25zLyoqIjp7fSwiLyovcHVzaC8qKiI6e30sIi8qL2tub2NraW5nLyoqIjp7fSwiLyovY2FsbHMvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJhbGFtIn0.WdK3iMMYHQB2hbQWaKSIVdJxcqEW0HBpg7uJoX7CbVS1M9yR92YkUIDbWFaJLwZGQovd8a7-39Sb2eoy2i6a7R7Md6z9MU0UMc-8wiqizhk1mYNo75qtxJFgJHJnQqiAZ7jJswgEM1bvG1lKBdPlZ3VBqqmcMRHUp2OHpZSgJ5byHvghM7i8CenuYZlJrUFD0QEeYZ7OPxm5gmyjD8BqAVY_L-vuk5HAj6_AkGTzYTOUUK2WdQynYZVGh0sXgHVNqXkQB8OVH7itmo_LrvALfuWp8kBvuQ9ET0XwKJDFYL5XzCqrx_89QOxq3AZ9oOHly9trb1YRpItWo-uiaWoR0w", callback: { error,sid  in
            print(error?.localizedDescription ?? "session created: \(sid ?? "no id")")
        })
    }
    
    func play() {
        player?.play()
    }
    
    func answer() {
        client.answer(callID) { error in
            if error == nil {
                self.startRecording()
            }
        }
    }
    
    func reject() {
        client.reject(callID) { error in
            print("Call reject, ", error ?? "with success")
        }
    }
}

// MARK: Vonage delegates
extension ViewDelegate: VGVoiceClientDelegate {
    func voiceClient(_ client: VGVoiceClient, didReceiveInviteForCall callId: VGCallId, from caller: String, with type: VGVoiceChannelType) {
        callID = callId
        // reporting a call, via call kit
        //        cancelType = .reject
        //        let update = CXCallUpdate()
        //        update.localizedCallerName = caller
        //        let uuid = UUID(uuidString: callId)!
        //        callProvider.reportNewIncomingCall(with: uuid, update: update) { error in
        //            print(error?.localizedDescription ?? "Call reported")
        //            if error == nil {
        //                self.callUUID = uuid
        //            }
        //        }
        DispatchQueue.main.async {
            self.showCallAlert = true
        }
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveLegStatusUpdateForCall callId: VGCallId, withLegId legId: String, andStatus status: VGLegStatus) {
        //        guard self.cid == callId, cid != legId else {
        //            return
        //        }
        if status == .answered {
            self.startRecording()
            print("legid:", legId, callId)
        } else if status == .unknown {
            self.finishRecording(success: true)
        }
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveHangupForCall callId: VGCallId, withQuality callQuality: VGRTCQuality, reason: VGHangupReason) {
        //        guard self.cid == callId else {
        //            return
        //        }
        
        self.finishRecording(success: true)
//        guard let uuid = callUUID else {
//            return
//        }
//        let endCallTransaction = CXEndCallAction(call: uuid)
//        self.cancelType = .none
//        callController.request(.init(action: endCallTransaction)) { error in
//            print("Call Ended with: ", error ?? "success")
//        }
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveInviteCancelForCall callId: VGCallId, with reason: VGVoiceInviteCancelReason) {
        print("Call Invite cancelled with: ", reason)
        self.finishRecording(success: true)
    }
    
    func client(_ client: VGBaseClient, didReceiveSessionErrorWith reason: VGSessionErrorReason) {
        print("Session failed with error: ", reason)
    }
}


// MARK: Audio delegates
extension ViewDelegate: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: (any Error)?) {
        print("error in \(#function)", error ?? "no error");
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        print("Interruption in \(#function)");
    }
    
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        print(" End Interruption in \(#function)", flags);
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
        DispatchQueue.main.async {
            self.player = nil
            do {
                self.player = try AVAudioPlayer(contentsOf: self.audioFileUrl)
            } catch {
                print("[Player] error", error)
            }
        }
    }
}







