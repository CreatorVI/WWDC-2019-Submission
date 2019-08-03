//
//  DefendYourDreamViewController.swift
//  Book_Sources
//
//  Created by Yu Wang on 2019/3/17.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport
import AVFoundation

public enum PhysicsTypes:Int{
    case weapon = 0
    case mosquito = 1
    case room = 2
    case alertRange = 3
    case non = 100
}


@available(iOS 11.0, *)
public class DefendYourDreamViewController: UIViewController, ARSCNViewDelegate, PlaygroundLiveViewSafeAreaContainer, SCNPhysicsContactDelegate {
    
    var sceneView = ARSCNView()
    
    public var weaponType = WeaponType.swatter
    
    public var mosquitoIntelligenceLevel = MosquitoIntelligenceLevel.stupid
    
    public var numberOfMosquitos = 1
    
    var mosquitoModelNode:SCNNode!
    
    var mosquitoNodes = [MosquitoNode](){
        didSet{
            DispatchQueue.main.async {
                self.fixedBlurLabel.label?.text = "Mosquitos Left: \(self.mosquitoNodes.count)"
            }
            if mosquitoNodes.count == 0{
                DispatchQueue.main.async {
                    transtitionView(self.fixedBlurLabel, withDuration: 2, upWard: true)
                }
                if let currentFrame = sceneView.session.currentFrame{
                    let scale = winSCNText.scale
                    winSCNText.isHidden = false
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.5
                    winSCNText.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
                    winSCNText.scale = scale
                }
                PlaygroundPage.current.assessmentStatus = .pass(message: "You have saved your night! \n Although the mosquitos are annoying, please try the different weapons and intelligence modes (You won't be able to use a laser gun in real life when being annoyed by real mosquitos, so try it now!)")
            }
        }
    }
    
    var noticeLabel:NoticePaddingLabel = {
        let label = NoticePaddingLabel()
        label.layer.cornerRadius = 8
        return label
    }()
    
    var middleNoticeLabel:UILabel = {
        let lable = UILabel()
        lable.font = UIFont.init(name: "Futura", size: 30)
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.textAlignment = .center
        lable.numberOfLines = 0
        lable.preferredMaxLayoutWidth = 300
        lable.adjustsFontForContentSizeCategory = true
        lable.textColor = UIColor.orange
        lable.sizeToFit()
        return lable
    }()
    
    var winSCNText = SCNNode()
    
    var fixedBlurLabel = BluredShadowView(title: "Mosquitos Left: 0")
    
    var bat = SCNNode()
    
    var alertRange = SCNNode()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        playSound(name: "",volume: 0)
        if let scene = SCNScene(named: "mosquitoCartoon.scn"){
            mosquitoModelNode = scene.rootNode.childNode(withName: "mosquito", recursively: false)!
        }
        setUpSceneView()
        setUpAndAddNoticeLabel()
        setUpAndAddFixedBlurLabel()
        if numberOfMosquitos > 4 {
            showNoticeAndFade(notice: "Too Many Mosquitos May Affect Performance")
            if weaponType == .laserGun{
                DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                    self.showNoticeAndFade(notice: "Tap To Shoot")
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        self.animateMiddleText("Move Around To Find Mosquitos")
                    }
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                    self.showNoticeAndFade(notice: "Use Your iPad As A Swatter")
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        self.animateMiddleText("Move Around To Find Mosquitos")
                    }
                }
            }
        }else{
            if weaponType == .laserGun{
                showNoticeAndFade(notice: "Tap To Shoot")
            }else{
                showNoticeAndFade(notice: "Use Your iPad As A Swatter")
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                self.animateMiddleText("Move Around To Find Mosquitos")
            }
        }
        setUPMiddleLabel()
        setUpWinText()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    var lastContactedNode = SCNNode()
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //MARK: mosquito killed by weapon
        if contact.nodeA.name == "mosquito" && contact.nodeB.name == "weapon"{
            killMosquito(node: contact.nodeA)
            playSound(name: "electricShot", volume: 0.1)
        }else if contact.nodeB.name == "mosquito" && contact.nodeA.name == "weapon"{
            killMosquito(node: contact.nodeB)
            playSound(name: "electricShot", volume: 0.1)
        }
        if contact.nodeA.name == "mosquito" && contact.nodeB.name == "laser"{
            killMosquito(node: contact.nodeA)
        }else if contact.nodeB.name == "mosquito" && contact.nodeA.name == "laser"{
            killMosquito(node: contact.nodeB)
        }
        if lastContactedNode === contact.nodeA || lastContactedNode === contact.nodeB{
            return
        }else{
            if contact.nodeA.name == "mosquito" && walls.contains(contact.nodeB){
                collideWithWalls(node: contact.nodeA)
                lastContactedNode = contact.nodeB
            }else if contact.nodeB.name == "mosquito" && walls.contains(contact.nodeA){
                collideWithWalls(node: contact.nodeB)
                lastContactedNode = contact.nodeA
            }
            if contact.nodeA.name == "mosquito" && contact.nodeB === ceiling{
                collideWithCeiling(node: contact.nodeA)
                lastContactedNode = contact.nodeB
            }else if contact.nodeB.name == "mosquito" && contact.nodeA === ceiling{
                collideWithCeiling(node: contact.nodeB)
                lastContactedNode = contact.nodeA
            }
            if contact.nodeA.name == "mosquito" && contact.nodeB === floor{
                collideWithFloor(node: contact.nodeA)
                lastContactedNode = contact.nodeB
            }else if contact.nodeB.name == "mosquito" && contact.nodeA === floor{
                collideWithFloor(node: contact.nodeB)
                lastContactedNode = contact.nodeA
            }
        }
        if contact.nodeA.name == "mosquito" && contact.nodeB.name == "alert range"{
            alertMosquito(node: contact.nodeA)
        }else if contact.nodeB.name == "mosquito" && contact.nodeA.name == "alert range"{
            alertMosquito(node: contact.nodeB)
        }
    }
    
    private func alertMosquito(node:SCNNode){
        if let node = node as? MosquitoNode{
            node.removeAllActions()
            node.timer.invalidate()
            let toDirection = node.worldPosition*Float(4) - bat.worldPosition*Float(3)
            node.turn(to: toDirection)
            node.runAction(node.forwardFly(duration: 0.4, direction: toDirection))
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                node.normalFly()
                node.timeElapsed = 5
            }
        }
    }
    
    private func collideWithWalls(node:SCNNode){
        if let node = node as? MosquitoNode, node.shouldContact{
            if node.rotationCount>3{
                node.removeAllActions()
                node.timer.invalidate()
                node.physicsBody?.contactTestBitMask = 100
                node.physicsBody?.collisionBitMask = 100
                node.runAction(SCNAction.move(to: sceneView.scene.rootNode.worldPosition, duration: 3))
                DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                    node.physicsBody?.contactTestBitMask = PhysicsTypes.weapon.rawValue | PhysicsTypes.room.rawValue | PhysicsTypes.alertRange.rawValue
                    node.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
                    node.normalFly()
                    node.timeElapsed = 5
                }
                return
            }
            node.removeAllActions()
            node.timer.invalidate()
            node.rotationCount += 1
            node.runAction(MosquitoNode.turn(angle: SCNVector3(0, Float.pi*0.6, 0)))
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                node.normalFly()
                node.timeElapsed = 5
            }
        }
    }
    
    private func collideWithFloor(node:SCNNode){
        if let node = node as? MosquitoNode, node.shouldContact{
            if node.rotationCount>3{
                node.removeAllActions()
                node.timer.invalidate()
                node.physicsBody?.contactTestBitMask = 100
                node.physicsBody?.collisionBitMask = 100
                node.runAction(SCNAction.move(to: sceneView.scene.rootNode.worldPosition, duration: 3))
                DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                    node.physicsBody?.contactTestBitMask = PhysicsTypes.weapon.rawValue | PhysicsTypes.room.rawValue | PhysicsTypes.alertRange.rawValue
                    node.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
                    node.normalFly()
                    node.timeElapsed = 5
                }
                return
            }
            node.removeAllActions()
            node.rotationCount += 1
            node.timer.invalidate()
            node.runAction(MosquitoNode.turn(angle: SCNVector3(Float.pi/2, 0, 0)))
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                node.normalFly()
                node.timeElapsed = 5
            }
        }
    }
    
    private func collideWithCeiling(node:SCNNode){
        if let node = node as? MosquitoNode, node.shouldContact{
            if node.rotationCount>3{
                node.removeAllActions()
                node.timer.invalidate()
                node.physicsBody?.contactTestBitMask = 100
                node.physicsBody?.collisionBitMask = 100
                node.runAction(SCNAction.move(to: sceneView.scene.rootNode.worldPosition, duration: 3))
                DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                    node.physicsBody?.contactTestBitMask = PhysicsTypes.weapon.rawValue | PhysicsTypes.room.rawValue | PhysicsTypes.alertRange.rawValue
                    node.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
                    node.normalFly()
                    node.timeElapsed = 5
                }
                return
            }
            node.removeAllActions()
            node.rotationCount += 1
            node.timer.invalidate()
            node.runAction(MosquitoNode.turn(angle: SCNVector3(-Float.pi/2, 0, 0)))
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                node.normalFly()
                node.timeElapsed = 5
            }
        }
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
    
    private func killMosquito(node:SCNNode){
        if let node = node as? MosquitoNode, mosquitoNodes.contains(node){
            node.timer.invalidate()
            node.presentation.removeAllAudioPlayers()
            node.removeAllActions()
            node.name = "dead mosquito"
            node.isAlive = false
            node.physicsBody?.isAffectedByGravity = true
            node.stopFlapping()
            node.runAction(SCNAction.sequence([SCNAction.wait(duration: 1),SCNAction.fadeOut(duration: 2)]))
            DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                node.physicsBody = nil
                node.isHidden = true
                node.enumerateChildNodes({ (node, _) in
                    node.isHidden = true
                })
            }
            mosquitoNodes.removeAll { (nodeIn) -> Bool in
                nodeIn === node
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate {
                self.updateLighing(lightEstimate.ambientIntensity / 100)
            } else {
                self.updateLighing(25)
            }
        }
        if let currentFrame = sceneView.session.currentFrame{
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.01
            bat.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
            if mosquitoIntelligenceLevel == .intelligent{
                alertRange.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor{
            let planeNode = setUpSurroundingDetection(anchor: anchor)
            node.addChildNode(planeNode)
        }
    }
    
    func setUpSurroundingDetection(anchor:ARPlaneAnchor)->SCNNode{
        var planeNode = SCNNode()
        //transform setting
        planeNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        planeNode.eulerAngles = SCNVector3(Float.pi/2, 0, 0)
        planeNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        //physics collision
        planeNode.name = "floor"
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)), options: nil))
        planeNode.physicsBody?.categoryBitMask = PhysicsTypes.room.rawValue
        planeNode.physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
        planeNode.physicsBody?.collisionBitMask = PhysicsTypes.mosquito.rawValue
        planeNode.physicsBody?.isAffectedByGravity = false
        //MARK: occlusion
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        maskMaterial.colorBufferWriteMask = []
        
        // occlude (render) from both sides please
        maskMaterial.isDoubleSided = true
        //assign material
        planeNode.geometry?.firstMaterial? = maskMaterial
        planeNode.categoryBitMask = 0
        return planeNode
    }
    
    private func setUpWinText(){
        if let scene = SCNScene(named: "room.scn"){
            winSCNText = scene.rootNode.childNode(withName: "winText", recursively: false)!
            winSCNText.position = SCNVector3.zero
            sceneView.scene.rootNode.addChildNode(winSCNText)
            winSCNText.isHidden = true
        }
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
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -4, 0)
        sceneView.autoenablesDefaultLighting = true
//        sceneView.debugOptions = [.showWorldOrigin,.showPhysicsShapes]
        generateMosquitos()
        if weaponType == .swatter{
            setUpBat()
        }else{
            setUpGesture()
        }
        setUpRoom()
        if mosquitoIntelligenceLevel == .intelligent{
            setUpAlertRange()
        }
    }
    
    var ceiling = SCNNode()
    var floor = SCNNode()
    var walls = [SCNNode]()
    
    
    private func setUpRoom(){
        if let scene = SCNScene(named: "room.scn"){
            let room = scene.rootNode.childNode(withName: "room", recursively: false)!
            ceiling = room.childNode(withName: "ceiling", recursively: false)!
            floor = room.childNode(withName: "floor", recursively: false)!
            for i in 1...4{
                walls.append(room.childNode(withName: "wall\(i)", recursively: false)!)
            }
        }
        ceiling.name = "ceiling"
        ceiling.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: ceiling, options: nil))
        ceiling.physicsBody?.categoryBitMask = PhysicsTypes.room.rawValue
        ceiling.physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
        ceiling.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
        ceiling.physicsBody?.isAffectedByGravity = false
//        room.position = SCNVector3(x: 0, y: 0, z: 0)
        sceneView.scene.rootNode.addChildNode(ceiling)
        
        floor.name = "floor"
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: floor, options: nil))
        floor.physicsBody?.categoryBitMask = PhysicsTypes.room.rawValue
        floor.physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
        floor.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
        floor.physicsBody?.isAffectedByGravity = false
        //        room.position = SCNVector3(x: 0, y: 0, z: 0)
        sceneView.scene.rootNode.addChildNode(floor)
        
        for i in 0..<walls.count{
            walls[i].name = "wall\(i)"
            walls[i].physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: walls[i], options: nil))
            walls[i].physicsBody?.categoryBitMask = PhysicsTypes.room.rawValue
            walls[i].physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
            walls[i].physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
            walls[i].physicsBody?.isAffectedByGravity = false
            //        room.position = SCNVector3(x: 0, y: 0, z: 0)
            sceneView.scene.rootNode.addChildNode(walls[i])
        }
        
    }
    
    private func setUpGesture(){
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shoot)))
    }
    
    @objc func shoot(){
        playSound(name: "laserShot")
        guard let point = sceneView.pointOfView else {
            return
        }
        let transform = point.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation/10
        
        let laser = getLaser()
        laser.position = position
        laser.look(at: location+orientation*2, up: SCNNode.localUp, localFront: laser.worldUp)
        laser.runAction(SCNAction.sequence([SCNAction.move(by: orientation*2, duration: 0.5),SCNAction.fadeOut(duration: 0.2),SCNAction.removeFromParentNode()]))
        sceneView.scene.rootNode.addChildNode(laser)
    }
    
    
    private func getLaser() -> SCNNode{
        let laserModel = SCNNode(geometry: SCNCylinder(radius: 0.001, height: 0.3))
        laserModel.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        laserModel.geometry?.firstMaterial?.emission.contents = UIColor.red.withAlphaComponent(0.4)
        laserModel.name = "laser"
        laserModel.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNCylinder(radius: 0.001, height: 0.3), options: nil))
        laserModel.physicsBody?.categoryBitMask = PhysicsTypes.weapon.rawValue
        laserModel.physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
        laserModel.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
        laserModel.physicsBody?.isAffectedByGravity = false
        return laserModel
    }
        
    
    private func setUpBat(){
        bat = SCNNode(geometry: SCNPlane(width: 0.3, height: 0.2))
        bat.name = "weapon"
        bat.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0)
        bat.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNPlane(width: 0.3, height: 0.2), options: nil))
        bat.physicsBody?.categoryBitMask = PhysicsTypes.weapon.rawValue
        bat.physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
        bat.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
        bat.physicsBody?.isAffectedByGravity = false
        sceneView.scene.rootNode.addChildNode(bat)
    }
    
    private func setUpAlertRange(){
        alertRange = SCNNode(geometry: SCNSphere(radius: 0.3))
        alertRange.name = "alert range"
        alertRange.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0)
        alertRange.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.3), options: nil))
        alertRange.physicsBody?.categoryBitMask = PhysicsTypes.alertRange.rawValue
        alertRange.physicsBody?.contactTestBitMask = PhysicsTypes.mosquito.rawValue
        alertRange.physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
        alertRange.physicsBody?.isAffectedByGravity = false
        sceneView.scene.rootNode.addChildNode(alertRange)
    }
    
    private func generateMosquitos(){
        for _ in 0..<numberOfMosquitos{
            mosquitoNodes.append(MosquitoNode(mosquito: mosquitoModelNode.clone()))
            mosquitoNodes.last!.name = "mosquito"
            mosquitoNodes.last!.randomizePosition()
            mosquitoNodes.last!.localRotate(by: SCNQuaternion(Double.random(in: -0.1...0.1), Double.random(in: -1...1), 0, Double.pi))
            sceneView.scene.rootNode.addChildNode(self.mosquitoNodes.last!)
        }
    }
    
    private func setUpAndAddNoticeLabel(){
        view.addSubview(noticeLabel)
        noticeLabel.preferredMaxLayoutWidth = 300
        noticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noticeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -160).isActive = true
        noticeLabel.isHidden = true
    }
    
    private func setUPMiddleLabel(){
        view.addSubview(middleNoticeLabel)
        NSLayoutConstraint.activate([
            middleNoticeLabel.centerXAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.centerXAnchor),
            middleNoticeLabel.centerYAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.centerYAnchor)
            ]
        )
        middleNoticeLabel.alpha = 0
    }
    
    private func setUpAndAddFixedBlurLabel(){
        view.addSubview(fixedBlurLabel)
        NSLayoutConstraint.activate([
            fixedBlurLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            fixedBlurLabel.widthAnchor.constraint(equalToConstant: 180),
            fixedBlurLabel.heightAnchor.constraint(equalToConstant: 60),
            fixedBlurLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ]
        )
    }
    
    private func updateLighing(_ intensity:CGFloat){
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    func showNoticeAndFade(notice:String){
        DispatchQueue.main.async {
            self.noticeLabel.isHidden = false
            self.noticeLabel.text = notice
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            UIView.animate(withDuration: 1, animations: {
                self.noticeLabel.isHidden = true
            })
        }
    }
    
    func animateMiddleText(_ text:String){
        middleNoticeLabel.text = text
        self.sceneView.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.middleNoticeLabel.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 3, delay: 3, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.middleNoticeLabel.alpha = 0
                }, completion: nil)
            })
        }
    }
    
}

public enum WeaponType {
    case swatter
    case laserGun
}

public enum MosquitoIntelligenceLevel {
    case stupid
    case intelligent
}
