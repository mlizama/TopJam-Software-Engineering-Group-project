//
//  ViewController.swift
//  Choose_music_final
//
//  Created by Humberto Hernandez on 11/13/15.
//  Copyright © 2015 Beto Hernandez. All rights reserved.
//

import UIKit
import MediaPlayer
import MultipeerConnectivity

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , TDSessionDelegate{
    
    var beto = Music()
    var refreshControl = UIRefreshControl()
    var session = TDSession(peerDisplayName : "HOST")
    var outputStreamer : TDAudioOutputStreamer?
    var inputStream : TDAudioInputStreamer?

    
    
    @IBOutlet var musicTable: UITableView!
    
    
    
    @IBAction func choose_button(sender: AnyObject) {
        
        presentViewController(beto.mediaPicker, animated: true, completion: nil)
        
//song_art.image = beto.myMusicPlayer!.nowPlayingItem!.artwork?.imageWithSize(song_art.bounds.size)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return music_array.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = music_array[indexPath.row]
        cell.backgroundColor = UIColor.blackColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //this is where voting code happens
        var name = tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text!
        print(name)
        print(global_lobby)
        
        let urlToCall = "http://52.27.209.129/send_votes.php"
        let params = ["title": name, "lobby_name": global_lobby] as Dictionary<String, String>
        
        
        MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){(succeeded: Bool, returnedJSON: JSON) -> () in
            if(succeeded == false) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSLog("Error")
                })
                
                print("vote failed")
            }
            else {
                
                print("vote success")
                
            }
        
        }
    }
   
    func room_data ()
    {
//        if music_array.count != 0
//        {
//            current_song = music_array[0]
//        }
        let urlToCall = "http://52.27.209.129/room_data.php"
        let params = ["lobby_name": global_lobby] as Dictionary<String, String>
        
        MyRestAPI.sharedInstance.makeHTTPPostRequest(urlToCall, queryItems: params){(succeeded: Bool, returnedJSON: JSON) -> () in
            if(succeeded == false) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSLog("Error")
                })
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var size = returnedJSON.count
//                    print("----------------------------------------------")
                 
                    var new_array = [String]()
                   
                    if(returnedJSON != nil)
                    {
                    while (size > 0)
                        {
                            size -= 1
                            var stuff = (returnedJSON[size])["title"]
                            new_array.append(stuff.string!)

                        }
                        music_array = new_array
                        
                        }
                    //print("----------------------------------------------")
                    
                     //tell refresh control it can stop showing up now
                    if self.refreshControl.refreshing
                    {
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.musicTable.reloadData()
//                    if music_array.count != 0
//                    {
//                        if music_array[0] != current_song
//                            {
//                                self.beto.display()
//                        }
//                        current_song = music_array[0]
//                    }
                    
                })
            }
    }
        
        

        self.musicTable.reloadData()
    }
    @IBAction func reloadData(sender: AnyObject) {
        //song_art.image = beto.myMusicPlayer!.nowPlayingItem!.artwork?.imageWithSize(song_art.bounds.size)
        room_data()
    }
    
    @IBAction func stop_song(sender: AnyObject) {
        beto.stop()
    }
    
    
    @IBAction func next_button(sender: AnyObject) {
        beto.next()
    }

    
    @IBAction func invite(sender: AnyObject) {
        presentViewController(session.browserViewControllerForSeriviceType("topjam"),  animated: true, completion: nil)
    }
    
    
    @IBAction func prev_button(sender: AnyObject) {
        beto.prev()
    }
    
    func refresh(sender:AnyObject) {
        room_data()
        self.musicTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session.delegate = self
        
        session.startAdvertisingForServiceType("topjam", discoveryInfo: nil)

        
        var timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "update", userInfo: nil, repeats: true)

        
        self.musicTable.dataSource = self
        self.musicTable.delegate = self
        self.musicTable.registerClass(UITableViewCell.self, forCellReuseIdentifier:  "cell")
        
        // set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.musicTable.addSubview(refreshControl)
        
        room_data()
        self.musicTable.backgroundColor = UIColor.blackColor()

        // Do any additional setup after loading the view, typically from a nib
        
    }
    
    @IBAction func Start(sender: AnyObject)  {
        if(music_array.count != 0)
        {
            let song = music_array[0]
            
            if(!beto.display(song))
            {
            //ask for song
                session.sendData(NSKeyedArchiver.archivedDataWithRootObject(song))
                
            }
            
        }
        
    }
    
    func session(session: TDSession!, didReceiveAudioStream stream: NSInputStream!) {
        
        if(am_host)
        {
        
            self.inputStream = TDAudioInputStreamer(inputStream: stream)
            self.inputStream?.start()
        
        }
        
    }
    
    func session(session: TDSession!, didReceiveData data: NSData!) {
        
        let song = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        
        var ssong =  song as! String
        
        music_array.append(ssong)
        
        if(beto.find(ssong) != nil)
        {
            var peers = session.connectedPeers()
            
            if (peers.count > 0) {
                
                let result = self.beto.find(song as! String)
                
                if(result != nil)
                {
                
                   let result2 = result! as MPMediaItem
                   let url = result2.valueForProperty(MPMediaItemPropertyAssetURL)
                    
                self.outputStreamer = TDAudioOutputStreamer(outputStream : self.session.outputStreamForPeer(peers[0] as! MCPeerID) )
                    
                    self.outputStreamer!.streamAudioFromURL(url as! NSURL)
                
                    self.outputStreamer?.start()
                }
                
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(){
        print("refreshed ui table")
        //myLinker.send("host")
        room_data()
        self.musicTable.reloadData()

    }


}

