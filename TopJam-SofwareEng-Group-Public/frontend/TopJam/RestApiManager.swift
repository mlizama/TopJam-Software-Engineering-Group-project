//
//  RestApiManager.swift
//  TopJam
//
//  Created by Matt Messa on 10/6/15.
//  Copyright © 2015 TopJam. All rights reserved.
//

import Foundation

class RestApiManager: NSObject
{
    static let sharedInstance = RestApiManager()
    
    func makeHTTPPostRequest(APIurl: String, queryItems: Dictionary<String, String>, postCompleted : (succeeded: Bool, returnedJSON: JSON) -> ()) -> Void
    {
        var dataToReturn: JSON = nil
        
        let request = NSMutableURLRequest(URL: NSURL(string: APIurl)!)
        //print(queryItems)
        
        // Set the method to POST
        request.HTTPMethod = "POST"
        
        // Set the POST body for the request
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(queryItems, options: [])
        // Set the Application type to json
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error in
            //print(data)
            //print(response)
            dataToReturn = JSON(data: data!)
           // print(dataToReturn)
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(error != nil) {
                print(error!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, returnedJSON: nil)
            }
            else {
                //print("Success:")
                //print(dataToReturn)
                postCompleted(succeeded: true, returnedJSON: dataToReturn)
                return
            }
        })
        task.resume() //tell the secession to run the task in new thread
        session.finishTasksAndInvalidate()
    }
}