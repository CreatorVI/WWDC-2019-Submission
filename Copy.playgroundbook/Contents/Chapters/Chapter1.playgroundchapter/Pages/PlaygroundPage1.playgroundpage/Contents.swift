
/*:
 
 # Fight The Mosquitos
 **First** , try finding the mosquito by following the sound (Unfortunately, just like in real life, you can't easily find a mosquito simply by identifying the sound source. Thus I made the mosquitos red so you can easily spot them :)
 
 **After you have spotted it** , move your iPad (move quickly if you choose intelligent mosquito mode) towards the mosquito (imagine that your iPad is an electronic mosquito swatter) to kill it.
 
 Cool! Isn't it?
 
 ## After that
 Now, upgrade your "weapon." You can choose to use the laser gun.
 
 You can also choose the number of mosquitos in your room.
 
 ## Recommendation
 
 ● Do try intelligence mode with swatter 😎
 
 
 ## Help
 
 **If you can't find the mosquito:**
 
 Be patient, look around and it must be somewhere around you.
 
 **If you can't kill the mosquito:**
 
 1. using mosquito swatter: You have to really speed your device up (in intelligent mode) just like you do before killing a mosquito with an electronic mosquito swatter and you have to collide with it.
 
 #### Wrong Way (Too Slow)
 
 ![Wrong Way (Too Slow)](wrongWay.mov "Wrong Way (Too Slow)")
 
 #### Right Way (Faaast!)
 
 ![Right Way (Faaast!)](rightWay.mov "Right Way (Faaast!)")
 
 2. using laser gun: the laser is very thin so you have to be a professional shooter (which takes practice)
 
 **If the game becomes suddenly over (very rare):**
 
 You are lucky that the mosquito flied directly to your electronic mosquito swatter and died 😂
 
  */


/*:
**Your weapon**
 */
var weapon = WeaponType.swatter
 

/*:
 **Total number of mosquitos in your room (3 recommended)**
 
 **!!!!! DON'T SET IT OVER 10 !!!!!**
 
 */
var numberOfMosquitosInRoom = 1

/*:
 **The difficulty for you to get down a mosquito:**
 
 ● stupid: mosquitos fly around without noticing you
 
 ● intelligent: mosquitos speed up and fly away when you are close to them
 */
var mosquitoIntelligenceLevel = MosquitoIntelligenceLevel.stupid




/*:
 
 ## Attributes:
 
 **mosquito sound:**
 
 Link: "http://www.soundgator.com/audios/111/mosquito-01-sound-effect"
 
 License: "http://www.soundgator.com/userlicense.php"
 
 
 **Laser sound:**
 
 "https://freesound.org/people/Halleck/sounds/19487/"
 
 **electric shot sound:**
 
 "https://freesound.org/people/peepholecircus/sounds/169989/"
 
 **Under Creative Commons Lisense:**
 
 "https://creativecommons.org/publicdomain/zero/1.0/"
 
 
 **Mosquito Model:**
 
 "http://www.cadnav.com/3d-models/model-44320.html"
 
 **Logo Image:**
 
 "http://www.cadnav.com/3d-models/model-44320.html"
 
 */

//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = DefendYourDreamViewController()

viewController.weaponType = weapon
viewController.numberOfMosquitos = numberOfMosquitosInRoom
viewController.mosquitoIntelligenceLevel = mosquitoIntelligenceLevel

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
