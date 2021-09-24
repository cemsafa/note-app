//
//  AudioVC.swift
//  Note_CRRKTerm2_iOS
//
//  Created by Cem Safa on 2021-09-24.
//

import UIKit
import AVFoundation

class AudioVC: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var recPlayBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var path: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecorder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private methods
    
    private func getCacheDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as [String]
        return paths[0]
    }
    
    private func getFileUrl(from path: String?) -> URL {
        let filePath = URL(fileURLWithPath: path!)
        return filePath
    }
    
    private func setupRecorder() {
        let recordSettings : [String : AnyObject] =
                [AVFormatIDKey : NSNumber(value: kAudioFormatAppleLossless as UInt32),
                 AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as NSNumber,
                 AVEncoderBitRateKey : 320000 as NSNumber,
                 AVNumberOfChannelsKey : 2 as NSNumber,
                 AVSampleRateKey : 44100.0 as NSNumber]
            do {
                try recorder = AVAudioRecorder(url: getFileUrl(from: path), settings: recordSettings as [String : AnyObject])
            } catch {
                print("Something's went wrong while setting up the audio")
            }

            recorder.delegate = self
            recorder.prepareToRecord()
    }
    
    private func preparePlayer() {
        do {
            try player = AVAudioPlayer(contentsOf: getFileUrl(from: path))
        } catch {
            print(error.localizedDescription)
        }
        player.delegate = self
        player.prepareToPlay()
    }
    
    // MARK: - IBAction

    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recPlayBtnPressed(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(named: "recordBtn")) {
            recorder.record()
            sender.setImage(UIImage(named: "stopBtn8"), for: .normal)
        } else {
            recorder.stop()
            sender.setImage(UIImage(named: "recordBtn"), for: .normal)
        }
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(systemName: "play.fill")) {
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            preparePlayer()
            player.play()
            progressBar.progress = Float(player.currentTime)
        } else if ((sender.imageView?.image == UIImage(systemName: "stop.fill")) || (player.currentTime == player.duration)) {
            player.stop()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
    }
}
