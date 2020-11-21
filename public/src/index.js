const Level = require('./Level')
const Menu = require('./Menu')

let config = {
    type: Phaser.AUTO,
    width: 840,
    height: 840,
    backgroundColor: '#5c9f1d',
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
    scene: [Level, Menu]
}


let game = new Phaser.Game(config)
