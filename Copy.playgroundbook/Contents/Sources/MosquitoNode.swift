//
//  MosquitoNode.swift
//  Book_Sources
//
//  Created by Yu Wang on 2019/3/18.
//

import SceneKit

@available(iOS 11.0, *)
public class MosquitoNode: SCNNode{
    
    public var isAlive = true
    
    public var rotationCount = 0
    
    public var timer = Timer()
    
    var mosquito = SCNNode()
    
    var audioSource:SCNAudioSource!
    
    var wing1 = SCNNode()
    var wing2 = SCNNode()
    var wing3 = SCNNode()
    var wing4 = SCNNode()
    
    public override init() {
        super.init()
    }
    
    public convenience init(mosquito:SCNNode){
        self.init()
        self.mosquito = mosquito
        setUp()
    }
    
    private func setUp(){
        addChildNode(mosquito)
        wing1 = mosquito.childNode(withName: "wing1", recursively: true)!
        wing2 = mosquito.childNode(withName: "wing2", recursively: true)!
        wing3 = mosquito.childNode(withName: "wing3", recursively: true)!
        wing4 = mosquito.childNode(withName: "wing4", recursively: true)!
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.02), options: nil))
        physicsBody?.categoryBitMask = PhysicsTypes.mosquito.rawValue
        physicsBody?.contactTestBitMask = PhysicsTypes.weapon.rawValue | PhysicsTypes.room.rawValue | PhysicsTypes.alertRange.rawValue
        physicsBody?.collisionBitMask = PhysicsTypes.non.rawValue
        
        physicsBody?.isAffectedByGravity = false
        startFlapping()
        runAction(turnRandomly(duration: 1))
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            self.normalFly()
        }
        
        setUpAudio()
    }
    
    public func randomizePosition(){
        position = randomVector3InStandardBox(position: SCNVector3.zero)
    }
    
    public func forwardFly(duration:Float,direction:SCNVector3) -> SCNAction{
        return SCNAction.move(by: direction*Float.random(in: 0.4...1), duration: TimeInterval(duration))
    }
    
    public func turnRandomly(duration:Float = 1) -> SCNAction{
        if eulerAngles.x > Float.pi/4{
            return SCNAction.rotateBy(x: CGFloat.random(in: -CGFloat.pi/3...(-CGFloat.pi/4)), y: CGFloat.random(in: -CGFloat.pi/2...CGFloat.pi/2), z: 0, duration: TimeInterval(duration))
        }else if eulerAngles.x < -Float.pi/4{
            return SCNAction.rotateBy(x: CGFloat.random(in: CGFloat.pi/4...(CGFloat.pi/3)), y: CGFloat.random(in: -CGFloat.pi/2...CGFloat.pi/2), z: 0, duration: TimeInterval(duration))
        }else{
            return SCNAction.rotateBy(x: CGFloat.random(in: -CGFloat.pi/12...CGFloat.pi/12), y: CGFloat.random(in: -CGFloat.pi/2...CGFloat.pi/2), z: 0, duration: TimeInterval(duration))
        }
    }
    
    public func turn(to:SCNVector3){
        look(at: to)
    }
    
    public static func turn(angle:SCNVector3) -> SCNAction{
        return SCNAction.rotateBy(x: CGFloat(angle.x), y: CGFloat(angle.y), z: CGFloat(angle.z), duration: 1)
    }
    
    public func normalFly(){
        removeAllActions()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    public var timeElapsed = 5
    
    public var shouldContact = true
    
    @objc func updateTimer(){
        if isAlive{
            if timeElapsed>=5{
                if position.x > 1 || position.x < -1 || position.y > 0.6 || position.y < -0.6 || position.z > 1 || position.z < -1{
                    removeAllActions()
                    timer.invalidate()
                    turn(to: SCNVector3.zero)
                    runAction(SCNAction.move(to: SCNVector3.zero, duration: 3))
                    shouldContact = false
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) { [unowned self] in
                        self.shouldContact = true
                        self.normalFly()
                        self.timeElapsed = 5
                    }
                    return
                }
                if shouldContact{
                    removeAllActions()
                    let flyTime = Float.random(in: 3...4)
                    let turnTime = 5-flyTime
                    runAction(SCNAction.repeatForever(SCNAction.sequence([forwardFly(duration: flyTime, direction: worldFront),SCNAction.group([SCNAction.move(by: SCNVector3(CGFloat.random(in: -0.3...0.3), CGFloat.random(in: -0.3...0.3), CGFloat.random(in: -0.3...0.3)), duration: TimeInterval(turnTime)),turnRandomly(duration: turnTime)])])))
                    timeElapsed = 0
                }
            }
            timeElapsed += 1
            rotationCount = 0
        }
    }
    //SCNVector3(worldFront.x, worldFront.y, worldFront.z)
    func startFlapping(){
        let animationFor12 = SCNAction.repeatForever(SCNAction.sequence([SCNAction.rotateBy(x: 0, y: 0, z: 90, duration: 0.2),SCNAction.rotateBy(x: 0, y: 0, z: -90, duration: 0.2)]))
        let animationFor34 = SCNAction.repeatForever(SCNAction.sequence([SCNAction.rotateBy(x: 0, y: 0, z: -90, duration: 0.2),SCNAction.rotateBy(x: 0, y: 0, z: 90, duration: 0.2)]))
        wing1.runAction(animationFor12)
        wing2.runAction(animationFor12)
        wing3.runAction(animationFor34)
        wing4.runAction(animationFor34)
    }
    
    func stopFlapping(){
        wing1.removeAllActions()
        wing2.removeAllActions()
        wing3.removeAllActions()
        wing4.removeAllActions()
    }
    
    private func setUpAudio() {
        audioSource = SCNAudioSource(fileNamed: "mosquito-01-sound-effect.wav")!
        audioSource.isPositional = true
        audioSource.shouldStream = false
        audioSource.volume = 0.5
        
        audioSource.loops = true
        audioSource.load()
        let delay = 1500+Int.random(in: 0...2000)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            self.playSound()
        }
    }
    
    private func playSound() {
        presentation.removeAllAudioPlayers()
        presentation.addAudioPlayer(SCNAudioPlayer(source: audioSource))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        presentation.removeAllAudioPlayers()
        removeAllActions()
    }
}
