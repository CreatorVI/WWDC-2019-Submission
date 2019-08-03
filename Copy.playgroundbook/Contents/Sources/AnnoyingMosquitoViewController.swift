//
//  AnnoyingMosquitoViewController.swift
//  Book_Sources
//
//  Created by Yu Wang on 2019/3/17.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

@available(iOS 11.0, *)
public class AnnoyingFlyViewController: UIViewController, ARSCNViewDelegate, PlaygroundLiveViewSafeAreaContainer {
    
    var passed:Bool = false{
        didSet{
            if passed{
                PlaygroundPage.current.assessmentStatus = .pass(message: "Quite annoying right? This is the very feeling when you can't catch a mosquito but it keeps annoying you. Go to the [**Next Page**](@next) to catch it")
            }
        }
    }
    
    
    var sceneView = ARSCNView()
    
    var staticSoundSourceNode = SCNNode()
    
    var audioSource:SCNAudioSource!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        playSound(name: "",volume: 0)
        setUpSceneView()
        setUpAudio()
        
    }
    
    var player: AVAudioPlayer?
    
    func playSound(name:String,volume:Float = 0.05) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.numberOfLoops = 1
            player.play()
            player.volume = volume
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.staticSoundSourceNode.position = SCNVector3(0.5, 0.1, 0)
            self.sceneView.scene.rootNode.addChildNode(self.staticSoundSourceNode)
            self.playSound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+15) {
            self.passed = true
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func setUpSceneView(){
        self.view = sceneView
        
        sceneView.clipsToBounds = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
            ])
        
        sceneView.delegate = self
        
        sceneView.scene = SCNScene()
    }
    
    private func setUpAudio() {
        audioSource = SCNAudioSource(fileNamed: "mosquito-01-sound-effect.wav")!
        audioSource.volume = 0.5
        audioSource.isPositional = true
        audioSource.shouldStream = false
        
        audioSource.loops = true
        audioSource.load()
    }
    
    private func playSound() {
        staticSoundSourceNode.removeAllAudioPlayers()
        staticSoundSourceNode.addAudioPlayer(SCNAudioPlayer(source: audioSource))
    }
}

