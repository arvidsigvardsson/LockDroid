//
//  Network.swift
//  LockDroid
//
//  Created by Arvid Sigvardsson on 2016-04-27.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import Foundation

struct RfidItem {
    let id: String
    var accessGranted: Bool
    var cardName: String?
}


struct LogItem {
    let name: String
    let date: String
    let time: String
    let didOpen: Bool
}

enum Result<T> {
    case Success(T)
    case Failure(NSError)
}

func makeAdminGetRequest(callback: ([RfidItem]?)->()) {
    print("Försöker hämta adminlista")
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let username = defaults.valueForKey("username") as! String
    let password = defaults.valueForKey("password") as! String
    
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://lockdroid.se/admin")
    
    let request = NSMutableURLRequest(URL: url!)
    let passStr = "\(username):\(password)"
    let passData = passStr.dataUsingEncoding(NSUTF8StringEncoding)
    let authValue = "Basic \(passData!.base64EncodedStringWithOptions([]))"
    request.setValue(authValue, forHTTPHeaderField: "Authorization")
    
    //    let task = session.dataTaskWithURL(url!) {
    let task = session.dataTaskWithRequest(request) {
        data, response, error in
        print("Nu har svar på admin get kommit in")
        let str = String(data: data!, encoding: NSUTF8StringEncoding)
        print(response)
        print(str!)
        if let data = data {
            if let infoMap = decodeJsonRfid(data) {
                let infoArray = makeInfoArray(infoMap)
                callback(infoArray)
            } else {
                callback(nil)
            }
        } else {
            callback(nil)
        }
        //        callback(infoArray)
        //        callback(decodeJsonRfid(data!))
        //        callback(JsonRfid(rfidMap: ["nyckel":true], idNameMap: ["en till nyckel":"och ett värde"]))
    }
    task.resume()
}

func makeAdminPostRequest(array: [RfidItem]) {
    print("Påbörjar adming")
    var rfidMap: [String:Bool] = [:]
    var idNameMap: [String:String] = [:]
    
    for item in array {
        rfidMap[item.id] = item.accessGranted
        if let name = item.cardName {
            idNameMap[item.id] = name
        }
    }
    let postMap = RFIDInfo(rfidMap: rfidMap, idNameMap: idNameMap)
    let jsonString = encodeJson(postMap)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let username = defaults.valueForKey("username") as! String
    let password = defaults.valueForKey("password") as! String
    
    let url = NSURL(string: "https://lockdroid.se/admin")
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url!)
    
    let passStr = "\(username):\(password)"
    let passData = passStr.dataUsingEncoding(NSUTF8StringEncoding)
    let authValue = "Basic \(passData!.base64EncodedStringWithOptions([]))"
    request.setValue(authValue, forHTTPHeaderField: "Authorization")
    
    request.HTTPMethod = "POST"
    request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    let task = session.dataTaskWithRequest(request) { (data, response, error) in
        
    }
    task.resume()
}

func makeLoginRequest(username: String, password: String, callback:(Int?, String?, NSError?) -> ()) {
    print("Försöker göra loginrequest")
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://lockdroid.se/login")
    let request = NSMutableURLRequest(URL: url!)
    let passStr = "\(username):\(password)"
    let passData = passStr.dataUsingEncoding(NSUTF8StringEncoding)
    let authValue = "Basic \(passData!.base64EncodedStringWithOptions([]))"
    
    request.setValue(authValue, forHTTPHeaderField: "Authorization")
    
    let task = session.dataTaskWithRequest(request) {
        data, response, error in
        var str: String?
        var statusCode: Int?
        if let data = data {
            str = String(data: data, encoding: NSUTF8StringEncoding)
        }
        
        if let response = response {
            statusCode = (response as! NSHTTPURLResponse).statusCode
        }
        //        let str = String(data: data!, encoding: NSUTF8StringEncoding)
        //        print(response!)
        //        print(str!)
        callback(statusCode, str, error)
    }
    task.resume()
}

func makeOpenLockRequest() {
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://lockdroid.se/client?message=open")
    let request = NSMutableURLRequest(URL: url!)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let username = defaults.valueForKey("username") as! String
    let password = defaults.valueForKey("password") as! String
    
    let passStr = "\(username):\(password)"
    
    let passData = passStr.dataUsingEncoding(NSUTF8StringEncoding)
    let authValue = "Basic \(passData!.base64EncodedStringWithOptions([]))"
    request.setValue(authValue, forHTTPHeaderField: "Authorization")
    
    let task = session.dataTaskWithRequest(request)
    task.resume()
}

struct RFIDInfo {
    let rfidMap: Dictionary<String, Bool>
    let idNameMap: Dictionary<String, String>
}

func decodeJsonRfid(data: NSData) -> RFIDInfo? {
    do {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        if let rfidMap = json["rfidMap"] as? Dictionary<String, Bool>,
            idNameMap = json["idNameMap"] as? Dictionary<String, String> {
            return RFIDInfo(rfidMap: rfidMap, idNameMap: idNameMap)
        }
    } catch {
        print("json error")
    }
    return nil
}

func makeInfoArray(map: RFIDInfo) -> [RfidItem] {
    var array: [RfidItem] = []
    for (key, value) in map.rfidMap {
        array.append(RfidItem(id: key, accessGranted: value, cardName: map.idNameMap[key]))
    }
    return array
}



func encodeJson(map: RFIDInfo) -> String {
    do {
        let rfidData = try NSJSONSerialization.dataWithJSONObject(map.rfidMap as NSDictionary, options: NSJSONWritingOptions.init(rawValue: 0))
        let nameData = try NSJSONSerialization.dataWithJSONObject(map.idNameMap, options: NSJSONWritingOptions.init(rawValue: 0))
        let str = "{\"rfidMap\":\(String(data: rfidData, encoding: NSUTF8StringEncoding)!),\"idNameMap\":\(String(data: nameData, encoding: NSUTF8StringEncoding)!)}"
        print(str)
        return str
    } catch {
        print("Något fel med jsonencoding")
        assert(false)
    }
}

func makeLongPollRequest() {
    print("Startar long polling")
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://lockdroid.se/iospush")
    let request = NSMutableURLRequest(URL: url!)
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let username = defaults.valueForKey("username") as! String
    let password = defaults.valueForKey("password") as! String
    
    let passStr = "\(username):\(password)"
    let passData = passStr.dataUsingEncoding(NSUTF8StringEncoding)
    let authValue = "Basic \(passData!.base64EncodedStringWithOptions([]))"
    
    request.setValue(authValue, forHTTPHeaderField: "Authorization")
    
    let task = session.dataTaskWithRequest(request) {
        data, response, error in
        print("long poll har returnerat")
        if let response = response {
            if (response as! NSHTTPURLResponse).statusCode == 200 {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:
                    "Change to card id data on server", object: nil))
            }
        }
        
        // startar om
        makeLongPollRequest()
        
        //        var str: String?
        //        var statusCode: Int?
        //        if let data = data {
        //            str = String(data: data, encoding: NSUTF8StringEncoding)
        //        }
        //
        //        if let response = response {
        //            statusCode = (response as! NSHTTPURLResponse).statusCode
        //        }
        //        //        let str = String(data: data!, encoding: NSUTF8StringEncoding)
        //        //        print(response!)
        //        //        print(str!)
    }
    task.resume()
}

func makeLogGetRequest(callback: (Result<[LogItem]>)->()) {
    print("Försöker hämta loglista")
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let username = defaults.valueForKey("username") as! String
    let password = defaults.valueForKey("password") as! String
    
    let session = NSURLSession.sharedSession()
    let url = NSURL(string: "https://lockdroid.se/log?")
    
    let request = NSMutableURLRequest(URL: url!)
    let passStr = "\(username):\(password)"
    let passData = passStr.dataUsingEncoding(NSUTF8StringEncoding)
    let authValue = "Basic \(passData!.base64EncodedStringWithOptions([]))"
    request.setValue(authValue, forHTTPHeaderField: "Authorization")
    
    //    let task = session.dataTaskWithURL(url!) {
    let task = session.dataTaskWithRequest(request) {
        data, response, error in
        print("Nu har svar på admin get kommit in")
        if error == nil {
            let str = String(data: data!, encoding: NSUTF8StringEncoding)
            callback(.Success(formatLog(str!)))
        } else {
            callback(.Failure(error!))
        }
    }
    task.resume()
}

func formatLog(str: String) -> [LogItem] {
    let arr = str.componentsSeparatedByString("\n")
    var retArr: [LogItem] = []
    for s in arr {
        if s != "" {
            let line = s.componentsSeparatedByString(",")
            let didOpen = line[3] == "Succeeded"
            retArr.append(LogItem(name: line[0], date: line[1], time: line[2], didOpen: didOpen))
        }
    }
    return retArr
}










