import Phaser from 'phaser'
import axios from 'axios'

export default class IntroScene extends Phaser.Scene
{
    sharedConfig = null

    constructor(sharedConfig)
    {
        super({key: "intro-scene"})

        this.sharedConfig = sharedConfig
    }

    init()
    {  
        this.canvasWidth = this.game.config.width
        this.canvasHeigth = this.game.config.heigth
    }

    preload()
    {
        this.load.html('intro-form', './assets/intro-form.html');
        this.load.image('background', './assets/space.jpg')

        this.load.spritesheet('player', './assets/Male/Male 01-1.png', {frameWidth: 32, frameHeight: 32})
    }

    create()
    {
        console.log(this)
        this.player = this.physics.add.sprite(40 + 32 / 2, 40 + 32 / 2, 'player', 0).setDepth(2).setScale(3)
        this.anims.create({
            key: 'hero',
            frames: this.anims.generateFrameNumbers('player', {start: 0, end: 5}),
            repeatw: -1,
            frameRate: 4
        })

        this.add.image(0, 0, 'background').setScale(1.1, 1.1).setOrigin(0, 0)

        let text = this.add.text(this.canvasWidth / 2, 200, 'Join or create a new game', { color: 'white', fontFamily: 'Arial', fontSize: '32px '}).setOrigin(0.5)

        let element = this.add.dom(400, 600).createFromCache('intro-form')

        element.addListener('click');

        element.on('click', (event)=> {

            if (event.target.name === 'createGameButton') {
                
                axios.post('/game').then((result)=> {
                    event.view.document.getElementById('game-code').value = result.data.code
                }).catch((err)=> {
                    console.log(err)
                })
                
            } else if (event.target.name === 'joinGameButton') {

                let gameId = event.view.document.getElementById('game-code').value
                if (gameId === '') {
                    return
                }
                console.log('game id ', gameId)

                // Needs refactoring to use async / await 
                this.game.bridge.connect(gameId).then((conn)=> {
                    conn.onmessage = (e)=> {
                        // console.log('Message ', JSON.parse(e.data))
                        let data = JSON.parse(e.data)

                        if (data.type === 'game_joined') {
                            this.game.scene.remove('intro-scene')
                            this.game.scene.start('game-scene', data)
                        }
                    }

                    conn.send(JSON.stringify({type: 'game_join'}))
                }).catch((e)=> {
                    console.log(e)
                })
                // Needs refactoring to use async / await
            }
        })
    }

    update()
    {
        this.player.anims.play('hero', true)
    }
}