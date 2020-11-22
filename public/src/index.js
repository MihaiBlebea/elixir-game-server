// const Phaser = requrie('phaser')
// const Intro = require('./Intro')
// const Level = require('./Level')
// const Bridge = require('./bridge')
import Phaser from 'phaser'
import Bridge from './bridge'
import IntroScene from './IntroScene'
import GameScene from './GameScene'


let bridge = new Bridge()
// bridge.setupSocket()

// setTimeout(()=> bridge.submit({
//     type: 'game_create',
//     message: 'please create a game'
// }), 1500)

let sharedConfig = {
    bridge: bridge
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

bridge.setupSocket((event)=> {
    // console.log('THis is the event', event)
    if (event.type === 'game_joined') {
        // console.log(event)
        game.scene.remove('intro-scene')
        game.scene.start('game-scene', event)
        // console.log(game)
    }
})
