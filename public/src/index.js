import Phaser from 'phaser'
import Bridge from './bridge'
import IntroScene from './IntroScene'
import GameScene from './GameScene'


// let bridge = new Bridge()

let sharedConfig = {
    // bridge: bridge
}

let config = {
    type: Phaser.AUTO,
    width: 840,
    height: 840,
    backgroundColor: '#5c9f1d',
    parent: "foo",
    dom: {
        createContainer: true
    },
    physics: {
        default: 'arcade',
        arcade: {
            gravity: {
                x: 0,
                y: 0,
            },
            debug: true,
            debugShowBody: true,
            debugShowStaticBody: true,
        }
    },
    scene: [
        new IntroScene(sharedConfig),
        new GameScene(sharedConfig)
    ]
}

let game = new Phaser.Game(config)

game.bridge = new Bridge()
