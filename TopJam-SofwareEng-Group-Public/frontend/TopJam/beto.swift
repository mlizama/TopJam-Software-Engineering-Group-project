//
//  beto.swift
//  Final_test_beto
//
//  Created by Moises Lizama on 11/13/15.
//  Copyright © 2015 Beto Hernandez. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation

class Music : NSObject {
    
    var myMusicPlayer: MPMusicPlayerController!  //my musicPlayer
    var mediaPicker: MPMediaPickerController!  // Media Picker view
    var mediaCollection: MPMediaItemCollection!
    let mylobby = PersistentLobby()
    var top = 0.0
    
    
    
    override init()
    {
        //NSLog("lobby name - %s", mylobby.lobbyName())
        
        

        
        super.init()

        
        self.mediaPicker = MPMediaPickerController(mediaTypes: .AnyAudio)
        myMusicPlayer = MPMusicPlayerController() //instantiate Media player
        
       
        self.mediaPicker.delegate = self
        self.mediaPicker.allowsPickingMultipleItems = true
        self.mediaPicker.showsCloudItems = true

        self.mediaPicker.prompt = "Pick a song please..."
    
        
    }
    deinit
    {
    
    }
    
    func check()
    {
            myMusicPlayer.stop()
    }
    
    func getTitles()
    {
        if((mediaCollection) != nil)
        {
            var items =  mediaCollection.items  // contains songs selected
            var set = Set<MPMediaItem>(items)
            items = Array(set)
            
            // var params = [String: String]()   // dictionary to store titles and artists
            let urlToCall = "http://52.27.209.129/add_songs.php"  // new
            
            // var params = ["title": , "artist": ] as Dictionary<String, String>
            
            
            
            for music in items   // grabs titles and artists from songs chosen
            {
                let params = ["title": music.title!,"artist": music.artist!, "album": music.albumTitle! ,"votes": "0" ,"lobby": global_lobby] as Dictionary<String, String>
                // params[music.title!] = music.artist
                
                
                
                
                MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){(succeeded: Bool, returnedJSON: JSON) -> () in
                    if(succeeded == false) {
                        print("error")
                        let alert = UIAlertView()
                        alert.title = "Please try again"
                        alert.message = "There was an error signing up"
                        alert.addButtonWithTitle("Okay!")
                        alert.show()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            NSLog("Error")
                        })
                        
                        //     print("\(title) \t \(artist)")
                        // }}
                    }
                    else
                    {
                        NSLog(music.title!)
                        // music_array.insert(music.title!, atIndex:music_array.count)
                    }
                }}
        }
        
        self.mediaCollection = nil

    }
    
        

  /*     for (title,artist) in params  // prints everything in my dictionary
       {
        
        MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){ (succeeded: Bool, returnedJSON: JSON) -> () in
            if(succeeded == false) {
                print("error")
                let alert = UIAlertView()
                alert.title = "Please try again"
                alert.message = "There was an error signing up"
                alert.addButtonWithTitle("Okay!")
                alert.show()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSLog("Error")
                })
           print("\(title) \t \(artist)")
            }}}
        
      
    
        
       // print(items[0].title)
       // print(items[0].artist)
        } */
    
    func stop()
    {
        if((self.myMusicPlayer) != nil)
        {
            self.myMusicPlayer.stop()
        }
    }
    
    func next()
    {
        if((self.myMusicPlayer) != nil)
        {
            self.myMusicPlayer.skipToNextItem()
        }
    }
    
    func prev()
    {
        if((self.myMusicPlayer) != nil)
        {
            self.myMusicPlayer.skipToPreviousItem()
        }
    }
    
    func  display(song : String) -> Bool//(var album_art: UIImageView)
    {
        
        var songsArray = [MPMediaItem]()
    
        
        let query = MPMediaQuery.songsQuery()
        //query.groupingType = MPMediaGrouping.Title
        songsArray = query.items!
        
        
        for music in songsArray
        {
            //  print("$$$$$$$$$$$$$$$")
            //  print(music.title!)
            //print("$$$$$$$$$$$$$$$")
            if( song == music.title)
            {
                
                myMusicPlayer.setQueueWithQuery(query)
                myMusicPlayer.nowPlayingItem = music
                self.myMusicPlayer.play()
                let top1 = music.valueForProperty(MPMediaItemPropertyPlaybackDuration)
                top = (top1?.doubleValue)!
                 var timer = NSTimer.scheduledTimerWithTimeInterval((top1?.doubleValue)!, target: self, selector: "check", userInfo: nil, repeats: true)
                return true
                break
            }
            
            
        }
        return false
    }
    
    func find(song: String) -> MPMediaItem?
    {
    
        var songsArray = [MPMediaItem]()
        
        
        let query = MPMediaQuery.songsQuery()
        //query.groupingType = MPMediaGrouping.Title
        songsArray = query.items!
        
        
        for music in songsArray
        {
           
            if( song == music.title)
            {
            
                return music
                            }
            }
        
        return nil
    
    }
    
}


extension Music : MPMediaPickerControllerDelegate{
    
    func mediaPicker(mediaPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection){
            
            
            self.mediaCollection = mediaItemCollection
            
            self.myMusicPlayer.setQueueWithItemCollection(mediaItemCollection)
            
            // play items that you chose
            /*if(am_host)
            {
                self.myMusicPlayer.play()
            }*/
            
            self.getTitles()
            
            //set the artwork on new song
      //      nowPlayingItemImageView.image = myMusicPlayer!.nowPlayingItem!.artwork?.imageWithSize(nowPlayingItemImageView.bounds.size)
            
            //set the label on new song
            //nowPlayingItemLabel.text = myMusicPlayer!.nowPlayingItem!.title
            
            /* Finally dismiss the media picker controller */
            mediaPicker.dismissViewControllerAnimated(true, completion: nil)  // not sure
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        print("Media Picker was cancelled")
        mediaPicker.dismissViewControllerAnimated(true, completion: nil) //dismisses the MediaPicker 


    }
    
    
}



