# ARTargetShooter

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)]()

ARTargetShooter is an Augmented Reality shooting game built using Apple's ARKit + Scenekit frameworks. This project is an exercise for me to learn about the new iOS 11 updates and Swift. 

Floating targets orbit around the player and gradually move closer until they collide with the player and therefore ending the game. Players can shoot at the targets to destory them by aiming the crosshair and tapping on the screen. When a target is destroyed, another one spawns shortly after. In the event a target spawns outside the current view of the player, location indicators flash on the bottom of the screen to guide the player towards the location of the target.

* General Gameplay:

Gameplay Demo              |
:-------------------------:|
![gameplay2](https://github.com/brentinator0/ARTargetShooter/blob/master/gameplay2.gif)  |  

* Location Indicators:  A location indicator tells the player to turn to the right when the target moves out of view

Location Indicators        |
:-------------------------:|
![locationIndicator](https://github.com/brentinator0/ARTargetShooter/blob/master/locationIndicator.gif)  |

* Dodging Targets: The player demonstrates how to evade the target by moving around

Dodging Targets       |
:-------------------------:|
![dodge](https://github.com/brentinator0/ARTargetShooter/blob/master/dodgingTargets.gif)  |

* Game Over: The target collides with the player

Game Over              |
:-------------------------:|
![gameOver](https://github.com/brentinator0/ARTargetShooter/blob/master/gameOver.gif)  |  

## Requirements

* Xcode 9 Beta 3+
* An iOS 11 Beta 3+ device with an A9 chip or better (iPhone 6s or better)

## Usage

* Clone and run the project. 

```bash
$ git clone https://github.com/brentinator0/ARTargetShooter.git
```

* Tap to shoot the targets! Walk or run around to evade them!

## Contribute

* If you **find any bugs** or want to **request new features**, please open an issue!
* If you want to **make your own modifications**, please submit a pull request!

Additionally, I'm very open to any constructive criticism, especially when it comes to Swift best practices! The purpose of this project is to help me learn, so any advice is welcome :)

## Thanks

ARTargetShooter was inspired by raywenderlich.com's ['Geometry Fighter'](https://www.raywenderlich.com/128668/scene-kit-tutorial-with-swift-part-1) series and the [ARShooter](https://github.com/farice/ARShooter) project.

## License

[The MIT License (MIT)](https://github.com/brentinator0/ARTargetShooter/blob/master/LICENSE)
