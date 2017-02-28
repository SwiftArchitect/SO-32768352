//
//  ViewController.swift
//  SO-32768352
//
//  Copyright © 2017 Xavier Schott
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import AVFoundation

extension ViewController: AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = players.index(of: player) {
            players.remove(at: index)
        }
    }
}

class ViewController: UIViewController {

    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!

    var players:[AVAudioPlayer] = [AVAudioPlayer]()

    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                          AVNumberOfChannelsKey : NSNumber(value: Int32(1)),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]

    override func viewDidLoad() {
        super.viewDidLoad()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: soundUrl()!,
                                                settings: recordSettings)
            audioRecorder.prepareToRecord()
        } catch {}
    }

    func soundUrl() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let documentDirectory = urls.first {
            return documentDirectory.appendingPathComponent("SO-32768352.m4a")
        }
        return nil
    }

    @IBAction func doRecordAction(_ sender: AnyObject) {
        doStopAction(sender)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {}
    }

    @IBAction func doPlayAction(_ sender: UIBarButtonItem) {
        doStopAction(sender)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
            audioPlayer.play()
        } catch {}
    }

    @IBAction func doPlayMultipleAction(_ sender: UIBarButtonItem) {
        performSelector(inBackground: #selector(ViewController.playInBackground(_:)), with: sender)
    }

    func playInBackground(_ sender: AnyObject) {
        do {
            var audioPlayer:AVAudioPlayer!
            try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
            audioPlayer.delegate = self
            players.append(audioPlayer)
            audioPlayer.play()
        } catch {}
    }

    @IBAction func doStopAction(_ sender: AnyObject) {
        if let audioRecorder = audioRecorder {
            audioRecorder.stop()
        }
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
        }
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(false)
        } catch {}
    }
}

