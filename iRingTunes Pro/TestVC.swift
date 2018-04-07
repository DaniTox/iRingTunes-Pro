//
//  TestVC.swift
//  iRingTunes Pro
//
//  Created by Dani Tox on 28/01/18.
//  Copyright © 2018 Dani Tox. All rights reserved.
//

import UIKit
import MediaPlayer

class TestVC: UIViewController {

    var player : AVAudioPlayer?
    var exporter : RTExporter?
    
    var bottomCon : NSLayoutConstraint!
    
    var expandViewButton : UIButton!
    var asd : EditorView!
    var temp : EditorPlayerView!
    
    var rtplayer : RTPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = MPMediaPickerController(mediaTypes: .anyAudio)
        vc.allowsPickingMultipleItems = false
        vc.delegate = self
        present(vc, animated: true)
        
        
        asd = EditorView()
        asd.layer.masksToBounds = true
        asd.layer.cornerRadius = 10
        view.addSubview(asd)
        asd.translatesAutoresizingMaskIntoConstraints = false
        asd.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        asd.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        asd.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        bottomCon = asd.bottomAnchor.constraint(equalTo: asd.songDurationContainer.bottomAnchor, constant: 10)
        bottomCon.isActive = true
        
        asd.delegate = self
        asd.songName = "Test musica da VC"
        
        expandViewButton = UIButton()
        expandViewButton.addTarget(self, action: #selector(animate), for: .touchUpInside)
        expandViewButton.backgroundColor = asd.backgroundColor
        expandViewButton.layer.cornerRadius = 5
        expandViewButton.layer.masksToBounds = true
        expandViewButton.setTitle("↓", for: .normal)
        view.addSubview(expandViewButton)
        expandViewButton.translatesAutoresizingMaskIntoConstraints = false
        expandViewButton.topAnchor.constraint(equalTo: asd.bottomAnchor, constant: -5).isActive = true
        expandViewButton.centerXAnchor.constraint(equalTo: asd.centerXAnchor).isActive = true
        expandViewButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        expandViewButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        temp = EditorPlayerView()
        temp.backgroundColor = .blue
        temp.layer.cornerRadius = 10
        temp.delegate = self
        view.addSubview(temp)
        temp.anchor(top: expandViewButton.bottomAnchor,
                    leading: view.leadingAnchor,
                    bottom: nil,
                    trailing: view.trailingAnchor,
                    padding: .init(top: 10, left: 20, bottom: 0, right: 20),
                    size: .init(width: 0, height: 120))
        
        
        
        
        
        
//        button.frame = CGRect(x: 0, y: 500, width: 100, height: 100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @objc func animate() {
        
        switch asd.state {
        case .closed:
            bottomCon.isActive = false
            bottomCon = asd.bottomAnchor.constraint(equalTo: asd.fadeView.bottomAnchor, constant: 10)
            bottomCon.isActive = true
            self.asd.state = .large
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            expandViewButton.setTitle("↑", for: .normal)
        case .large:
            bottomCon.isActive = false
            bottomCon = asd.bottomAnchor.constraint(equalTo: asd.songDurationContainer.bottomAnchor, constant: 10)
            bottomCon.isActive = true
            self.asd.state = .closed
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            expandViewButton.setTitle("↓", for: .normal)
        }
        
        
    }

}

extension TestVC : MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true)
        
        let musicTmp = mediaItemCollection.items.first
        guard let url2 = musicTmp?.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else { return }
        
        rtplayer = RTPlayer(songURL: url2)
        rtplayer.actionToRepeat = { (playerCurrentValue) in
            if let playerValue = playerCurrentValue {
                self.temp.setCurrentSongTime(playerValue)
            }
        }
        rtplayer.completionStart = { [weak self] in
            self?.temp?.changeMusicStateButton?.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        rtplayer.completionPause = { [weak self] in
            self?.temp?.changeMusicStateButton?.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
        
        rtplayer.prepare { (code) in
            print("TestVC.mediaPickerDidPick...().player.prepare() ha ritornato il codice: \(code)")
        }
        
        rtplayer.setRingtoneTime(start: 0, duration: 40)
        
        rtplayer.play(startingAt: 0) { (code) in
            print("TestVC.mediaPickerDidPick...().player.play() ha ritornato il codice: \(code)")
        }
        
        let fullSongDuration = rtplayer.getSongDuration()
        
        temp.fullSongDuration = fullSongDuration
        asd.songMaxDuration = fullSongDuration
        
        
        
        return
        
        //OTTENGO LA MUSICA DALLA LIBRERIA
        let music = mediaItemCollection.items.first
        
        //OTTENGO L'URL DELLA MUSICA
        guard
            let url = music?.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
        else {
            print("TestVC: music.value() == nil")
            return
        }
        
        //OTTENGO DEI VALORI DI PROVA
        let start = CMTime(seconds: 10, preferredTimescale: 1)
        let duration = CMTime(seconds: 30, preferredTimescale: 1)
        let range = CMTimeRange(start: start, duration: duration)
        
        //LI SETTO NELLA CLASSE SONGATTRIBUTES
        let attributes = SongAttributes(songName: music!.title!, timeRange: range, startFade: nil, durationFade: nil)
        exporter = RTExporter(initialSong: url, fadeIn: false, songAttributes: attributes)
        
        //MI SETTO COME DELGATE
        exporter?.delegate = self
        
        //PREPARO L'EXPORTER
        exporter?.prepare()
        
        //ESPORTO
        exporter?.export()
        
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true)
    }
}


extension TestVC : ExporterDelegate {
    func exportDidFinish(withCode code: Int, andMsg msg: String?) {
        switch code {
        case 0:
            print("SUCCESSO NELL'EXPORT")
            print("Avvio la musica esportata...")
            guard let url = exporter?.exportPath else { print("Errore getting url player"); return}
            
            player = try? AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            
            
        case 1:
            print("ERRORE NELL'EXPORT")
            print(msg!)
        default:
            print("ricevuto un errore")
        }
    }
    
    
}

extension TestVC : EditorViewDelegate {
    func sliderDidMoveAt(_ value: Float, sliderType: EditorViewSliderType, view: UIView) {
        let senderView = view as? EditorView
        let durationOpt = senderView?.currentSongDurationValue
        
        switch sliderType {
        case .fadeDuration:
            print("Lo slider del fade è stato messo su: \(Int(value))s")
            
            
            
            
        case .songDuration:
            if let playerStartRingtone = rtplayer.startRingtone {
                rtplayer.setRingtoneTime(start: playerStartRingtone, duration: Int(value))
            }

            
        case .songStart:
            if let duration = durationOpt {
                rtplayer.setRingtoneTime(start: Double(value), duration: Int(duration))
            }
            rtplayer.setCurrentTime(Double(value))
        }
    }
    
    func switchWasTouched(_ sender: UISwitch, switchType: EditorViewSwitchType) {
        switch switchType {
        case .fade:
            print("Lo switch del fade è stato messo su: \(sender.isOn ? "Acceso" : "Spento")")
        }
    }
    
    
}


extension TestVC : EditorPlayerViewDelegate {
    func musicStateDidChange() {
        if rtplayer.isPlaying() {
            rtplayer.pause()
        } else {
            rtplayer.resume()
        }
    }
    
    
    func reloadStateSent() {
        let startTime = Double(self.asd.currentSongStartTime)
        rtplayer.setCurrentTime(startTime)
    }
    
}


