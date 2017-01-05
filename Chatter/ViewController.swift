//
//  ViewController.swift
//  Chatter
//
//  Created by Henry Boswell on 6/25/16.
//  Copyright © 2016 Henry Boswell. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    
    var model:CommunicationModel = CommunicationModel.sharedCommunicationModel
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var translateString = ""
    var translatedString = ""
    
    
    
    var fileName = "audioFile.m4a"
    
    @IBAction func playSound(sender: AnyObject) {
        playAudioSound()
        model.useHODClient()
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        recordingSession = AVAudioSession.sharedInstance()
        model.viewController = self
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func recordAction(sender: AnyObject) {
        recordTapped()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var recordButton: UIButton!
    func startRecording() {
        
        
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: getFileURL(), settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", forState: .Normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        return paths[0]
        
    }
    
    func getFileURL() -> NSURL{
        let path  = (getCacheDirectory() as NSString).stringByAppendingPathComponent(fileName)
        
        let filePath = NSURL(fileURLWithPath: path)
        
        return filePath
    }
    
    class func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", forState: .Normal)
        } else {
            recordButton.setTitle("Tap to Record", forState: .Normal)
            // recording failed :(
        }
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    
    
    func playAudioSound(){
        
        
        do {
            self.audioPlayer =  try AVAudioPlayer(contentsOfURL: getFileURL())
            self.audioPlayer.play()
            
            
            
            
        } catch {
            print("Error")
        }
        
        
    }
    
        

    @IBAction func buttonPressed(sender: AnyObject) {
        
        model.postDataToURL2()
    }
    
    
    
    

}



