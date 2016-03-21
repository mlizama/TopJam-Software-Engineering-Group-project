//
//  LobbyLinker.swift
//  ConnectedColors
//
//  Created by Moises Lizama on 10/12/15.
//  Copyright (c) 2015 Moises Lizama. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class LobbyLinker : NSObject {
    
    //Constant for service type
    //Identifies the service
    private let ColorServiceType = "top-jam-multi-p"
    private let serviceBrowser : MCNearbyServiceBrowser
    var browser : MCBrowserViewController!


    //private var outputstream : NSOutputStream
    
    //Current device name will be peer ID
    private let myPeerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    var delegate : LobbyLinkerDelegate?

    
    func stop(){
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        /*do{
          outputstream = try session .startStreamWithName("music", toPeer: self.session.connectedPeers.first!)
            outputstream.open()
        }
        catch let error as NSError{
        
        }
        
        let test = "something to send as a stream"
        let encodedDataArray = [UInt8](test.utf8)
        outputstream.write(encodedDataArray, maxLength: encodedDataArray.count)
        */
    }
    
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
    }()

    
    
    func send(data : String) {
        NSLog("%@", "sendColor: \(data)")
        
       
        if session.connectedPeers.count > 0 {
            
            do {

            try self.session.sendData((data.dataUsingEncoding(NSUTF8StringEncoding))!, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
            }
        catch let error as NSError {
            //do some error checking!!!!
            }
            
        }
        
        
        }
    
    override init() {
        //instantiate our serviceAdvertiser
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)

        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        self.browser = MCBrowserViewController(serviceType:ColorServiceType,session:self.session)
        browser.delegate = self
    
    }
    
    
    
    
    deinit {
        //Stop advertising when object is destroyed
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()

    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}
extension LobbyLinker : MCNearbyServiceAdvertiserDelegate,
                                MCNearbyServiceBrowserDelegate,
                                MCSessionDelegate,
                                MCBrowserViewControllerDelegate{
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)    }
    
  
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        NSLog("%@", "lostPeer: \(peerID)")
    }
   
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError)
    {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))

    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        if(str == "host")
        {
            print("I am host")
        }
        else
        {
            print("not host")
        }
        
        //self.delegate?.colorChanged(self, colorString: str)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
        /*var buffer = [UInt8](count: 8, repeatedValue: 0)
        
        stream.open()
        
        if stream.hasBytesAvailable {
             var result :Int = stream.read(&buffer, maxLength: buffer.count)
        }

        var message = NSString(bytes: buffer, length: buffer.count, encoding: NSUTF8StringEncoding)


        NSLog("%@", "didReceiveStream: \(message)")*/

        NSLog("%@", "didReceiveStream: \(peerID)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController)
    {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        NSLog("%@", "should return")

    }

    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController)
    {
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        NSLog("%@", "should return")


    }

    
    
    
}



protocol LobbyLinkerDelegate {
    
    func connectedDevicesChanged(manager : LobbyLinker, connectedDevices: [String])
    func colorChanged(manager : LobbyLinker, colorString: String)

    
}


