//
//  CommunicationModel.swift
//  Chatter
//
//  Created by Henry Boswell on 6/25/16.
//  Copyright © 2016 Henry Boswell. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation

class CommunicationModel: HODClientDelegate {
    
    
    static let sharedCommunicationModel = CommunicationModel()
    
    var hodClient:HODClient = HODClient(apiKey: "200af0c2-82e7-4db6-8410-f0eaca81bc73")
    var hodParser:HODResponseParser = HODResponseParser()
    
    var translateString = ""
    var translatedString = ""
    
    var viewController:ViewController!
    
    
    var fileName = "audioFile.m4a"
  
    
    init(){
        
        
        hodClient.delegate = self
    }
    
    
    func parseString(stuff:String){
        
        
        let fullNameArr = stuff.characters.split{$0 == "\""}.map(String.init)
        
        fullNameArr[0] // First
        fullNameArr[1] // Last
        
        
        print("results aquired")
        print(fullNameArr[9])
        
        // textOut.text = fullNameArr[9]
        
        translateString = fullNameArr[9]
        
        postDataToURL()
        
    }

    
    func postDataToURL() {
        
        let fullNameArr = translateString.characters.split{$0 == " "}.map(String.init)
        
        var preppedString = ""
        //https://www.googleapis.com/language/translate/v2?key=AIzaSyB1pdosNDl5ia7PZMEXg5MCWa84m1gA6rU&q=love&source=en&target=fr
        for unit in fullNameArr {
            preppedString = preppedString + unit + "%20"
        }
        
        
        let url = NSURL(string: "https://www.googleapis.com/language/translate/v2?key=AIzaSyB1pdosNDl5ia7PZMEXg5MCWa84m1gA6rU&q=" + preppedString + "&source=en&target=fr")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if let forginStuff = String(data: data!, encoding: NSUTF8StringEncoding){
                var json = String(htmlEncodedString: forginStuff)
                
                var mid = json as! [String:AnyObject]
                
                //var ringer = mid["Items"] as! [[String:String]]
                print(mid)

               
                // self.performSelectorOnMainThread("parseForginString:", withObject: forginStuff, waitUntilDone: false)
                
            }
            // self.parseForginString(forginStuff!)
        }
        
        task.resume()
        
    }
    
    func postDataToURL2() {
        
        let fullNameArr = translateString.characters.split{$0 == " "}.map(String.init)
        
        var preppedString = ""
        //https://www.googleapis.com/language/translate/v2?key=AIzaSyB1pdosNDl5ia7PZMEXg5MCWa84m1gA6rU&q=love&source=en&target=fr
        for unit in fullNameArr {
            preppedString = preppedString + unit + "%20"
        }
        
        
        let url = NSURL(string: "https://www.googleapis.com/language/translate/v2?key=AIzaSyB1pdosNDl5ia7PZMEXg5MCWa84m1gA6rU&q=" + preppedString + "&source=en&target=fr")

        let t = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            if error != nil {
                print("error=\(error)")
                return
            }
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                var mid = json as! [String:AnyObject]
                var ringer = mid["data"] as! [String:AnyObject]
                var done = mid["translations"] as! [String]
                print(mid)
                print(ringer)
            }catch{
                print("error")
            }
        }
        t.resume()
    
        
    }
    
    
    
    
    
    
    
    
    func useHODClient() {
        //var hodApp = hodClient.HODApps
        
        var params =  Dictionary<String,AnyObject>()
        
        
        //str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(5), end: str.endIndex))
        params["file"] = (viewController.getCacheDirectory() as NSString).stringByAppendingPathComponent(fileName)
        print(viewController.getFileURL())
        // params["mode"] = "document_photo"
        print("1")
        
        hodClient.PostRequest(&params, hodApp:"recognizespeech", requestMode:HODClient.REQ_MODE.ASYNC);
        //print(params)
    }
    
    // implement delegated functions
    /**************************************************************************************
     * An async request will result in a response with a jobID. We parse the response to get
     * the jobID and send a request for the actual content identified by the jobID.
     **************************************************************************************/
    func requestCompletedWithJobID(response:String){
        print(response)
        let jobID:String? = hodParser.ParseJobID(response)
        if jobID != nil {
            hodClient.GetJobStatus(jobID!)
            print("here")
        }
    }
    func requestCompletedWithContent(var response:String){
        if let resp = (hodParser.ParseSpeechRecognitionResponse(&response)) {
            var result = "Scanned text:\n"
            
            /*
             print(resp)
             
             for item in resp {
             let i  = item as! OCRDocumentResponse.TextBlock
             result += "Text: " + i.text + "\n"
             result += "Top/Left: " + String(format: "%d/%d", i.top, i.left) + "\n"
             result += "------\n"
             }
             */
            
            //let myJsonDict : [String:AnyObject] = response
            
            parseString(response)
            // print or consume result
        } else {
            let errors = hodParser.GetLastError()
            var errorMsg = ""
            for error in errors {
                let err = error as! HODErrorObject
                errorMsg =  String(format: "Error code: %d\n", err.error)
                errorMsg += String(format: "Error reason: %@\n", err.reason)
                errorMsg += String(format: "Error detail: %@\n", err.detail)
                errorMsg += String(format: "JobID: %@\n", err.jobID)
                print(errorMsg)
                if err.error == HODErrorCode.QUEUED { // queues
                    // sleep for a few seconds then check the job status again
                    hodClient.GetJobResult(err.jobID)
                    
                    break
                } else if err.error == HODErrorCode.IN_PROGRESS { // in progress
                    // sleep for for a while then check the job status again
                    hodClient.GetJobResult(err.jobID)
                    break
                }
            }
        }
    }
    func onErrorOccurred(errorMessage:String){
        print(errorMessage)
    }
    
    
    
    
    
    
}


extension String {
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        var attributedString:NSAttributedString!
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        }catch{
            print("error")
        }
        self.init(attributedString.string)
        
    }
}