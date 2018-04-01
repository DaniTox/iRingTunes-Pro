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
    
    var asd : EditorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let vc = MPMediaPickerController(mediaTypes: .anyAudio)
//        vc.allowsPickingMultipleItems = false
//        vc.delegate = self
//        present(vc, animated: true)
        
        
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
        
        
        
        
        let button = UIButton()
        button.addTarget(self, action: #selector(animate), for: .touchUpInside)
        button.backgroundColor = .green
        view.addSubview(button)
        button.frame = CGRect(x: 0, y: 500, width: 100, height: 100)
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
        case .large:
            bottomCon.isActive = false
            bottomCon = asd.bottomAnchor.constraint(equalTo: asd.songDurationContainer.bottomAnchor, constant: 10)
            bottomCon.isActive = true
            self.asd.state = .closed
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        
    }

}

extension TestVC : MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        dismiss(animated: true)
        
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


