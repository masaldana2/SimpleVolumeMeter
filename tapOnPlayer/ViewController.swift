//
//  ViewController.swift
//  tapOnPlayer
//
//  Created by Miguel  Saldana on 3/18/17.
//  Copyright © 2017 miguelDSP. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var volumeMeter: UIProgressView!
    
    var engine: AVAudioEngine!      //The Audio Engine
    var player: AVAudioPlayerNode!  //The Player of the audiofile
    var file = AVAudioFile()        //Where we're going to store the audio file
    var timer: Timer?               //Timer to update the meter
    var volumeFloat:Float = 0.0     //Where We're going to store the volume float

    override func viewDidLoad() {
        super.viewDidLoad()
        //init engine and player
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        
        //Look for the audiofile on the project
        let path = Bundle.main.path(forResource: "Electronic", ofType: "m4a")!
        let url = NSURL.fileURL(withPath: path)
        
        //create the AVAudioFile
        let file = try? AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        do {
            //Do it
            try file!.read(into: buffer)
        } catch _ {
        }
        
        
        engine.attach(player)

        engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        
        //installTap with a bufferSize of 1024 with the processingFormat of the current audioFile on bus 0
        engine.mainMixerNode.installTap(onBus:0, bufferSize: 1024, format: file?.processingFormat) {
            (buffer : AVAudioPCMBuffer!, time : AVAudioTime!) in
            
            let dataptrptr = buffer.floatChannelData!           //Get buffer of floats
            let dataptr = dataptrptr.pointee
            let datum = dataptr[Int(buffer.frameLength) - 1]    //Get a single float to read
            
            //store the float on the variable
            self.volumeFloat = fabs((datum))
            
            
            if fabs(datum) < 0.000001  {
                print("stopping")
                self.engine.stop()
                return
            }
            
         
        }

        
        //Loop the audio file for demo purposes
        player.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions.loops, completionHandler: nil)
        
        engine.prepare()
        do {
            try engine.start()
        } catch _ {
        }
        
        player.play()
        
        //start timer to update the meter
        timer = Timer.scheduledTimer(timeInterval: 0.1 , target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)

        //to remove tap
        //self.engine.mainMixerNode.removeTap(onBus: 0)

    }

     func updateMeter() {
        self.volumeMeter.setProgress(volumeFloat, animated: false)
        
        if volumeMeter.progress > 0.8{//turn red if the volume is LOUD
            volumeMeter.tintColor = UIColor.red
            
        }else{//else green
            volumeMeter.tintColor = UIColor.green
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

