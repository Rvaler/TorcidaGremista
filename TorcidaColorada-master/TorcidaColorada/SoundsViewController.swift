//
//  SoundsViewController.swift
//  TorcidaColorada
//
//  Created by Moisés Pio on 8/22/15.
//  Copyright © 2015 Moisés Pio. All rights reserved.
//

import UIKit
import AVFoundation

class SoundsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var musicSelected = AVAudioPlayer()
    var controller = UIDocumentInteractionController()
    var sounds : [SoundManager] = []
    var userIdSend : String?
    var isPlay : Int?
    var userControl : UserManager?
    
    var sendMessage: Bool = false

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView();
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 160.0

        self.userControl = UserManager.currentUser()!
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }

    func tableView(tableView: UITableView, numberOfSectionsInTableView section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("soundCell") as! SoundsTableViewCell
        
        let soundControl = sounds[indexPath.row]
        cell.audioName.text = soundControl.name
        
        if(isPlay == indexPath.row) {
            cell.cellBackground.hidden = false
            cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 244/255, alpha: 1)
            cell.buttonPlayAndPause.setImage(UIImage(named: "Pause"), forState: UIControlState.Normal)
            cell.buttonSubmit.setImage(UIImage(named: "SendActive"), forState: UIControlState.Normal)
        } else {
            cell.cellBackground.hidden = true
            cell.backgroundColor = UIColor.whiteColor()
            cell.buttonSubmit.setImage(UIImage(named: "Send"), forState: UIControlState.Normal)
            cell.buttonPlayAndPause.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)
        }
            
            cell.buttonSubmit2.tag = indexPath.row

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        playAndPause(indexPath.row)
    }

    func updateTableView() {
        self.tableView.reloadData()
    }

    func loadData() {
        let soundControl = SoundManager()
        
        soundControl.getSounds { (allSounds, error) -> () in
            self.sounds = allSounds
            self.activityIndicator.stopAnimating()
            self.updateTableView()
        }
    }

    @IBAction func playAndPause(sender: AnyObject) {
        let button = sender as! UIButton
        let view = button.superview!
        let cell = view.superview as! SoundsTableViewCell
        
        cell.buttonPlayAndPause.setImage(UIImage(named: "Pause"), forState: UIControlState.Normal)
        
        let indexPath = self.tableView.indexPathForCell(cell)
        
        playAndPause(indexPath!.row)
    }
    
    @IBAction func sendPush(sender: AnyObject) {
//        let button = sender as! UIButton
//        let view = button.superview!
//        let cell = view.superview as! SoundsTableViewCell
//        let indexPath = self.tableView.indexPathForCell(cell)
        
        let messageControl = Messages()

        messageControl.sound = sounds[sender.tag]
        messageControl.user = UserManager.currentUser()
        messageControl.userTo = UserManager(withoutDataWithObjectId: userIdSend)

        messageControl.sendMessage { (success, error) -> () in
            if success {
            }
        }

        sendPush(sender.tag)
    }

    @IBAction func share(sender: UIButton) {
//        let button = sender as UIButton
//        let view = button.superview!
//        let cell = view.superview as! SoundsTableViewCell
//        let indexPath = self.tableView.indexPathForCell(cell)
//        
//        if let soundControl = sounds[indexPath!.row] as? SoundManager {
//            
//            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "whatsapp://app")!) {
//                //            var path = NSBundle.mainBundle().pathForResource(soundControl.mp3?.url!, ofType: "mp3")
//                controller = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: soundControl.mp3!.url!))
//                
//                controller.UTI = "net.whatsapp.audio"
//                controller.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
//            } else {
//                let alert = UIAlertView (title: "Ops !", message: "É preciso ter o WhatsApp instalado para compartilhar o som", delegate: self, cancelButtonTitle: "OK")
//                
//                alert.show()
//            }
//        }
    }
    
    func playAndPause(path: Int!) {
        let soundControl = sounds[path]
            if(self.isPlay == path) {
                musicSelected.stop()
                self.isPlay = nil
            } else {
                musicSelected = self.setupAudioPlayerWithFile(soundControl.fileName!, type:"caf")
                
                musicSelected.delegate = self
                musicSelected.play()
                self.isPlay = path
            }
            
            self.updateTableView()

    }

    func sendPush(path: Int!) {
        let soundControl = sounds[path]
            
            PushManager.sendPush(self.userControl!.name! + ": " + soundControl.name!, sound: soundControl.fileName!, userId: userIdSend!)
            self.sendMessage = true

            self.performSegueWithIdentifier("backPush", sender: nil)
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        var _: NSError?
        var audioPlayer:AVAudioPlayer?

        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
        } catch _ {
            print("Error executing videoDevice")
        }
//
        
//        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)

        return audioPlayer!
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "backPush") {
            let rVC : FriendsViewController = segue.destinationViewController as! FriendsViewController

            rVC.sendMessage = self.sendMessage
        }
    }
}
extension SoundsViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlay = nil
        self.updateTableView()
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("\(error!.localizedDescription)")
    }
    
}