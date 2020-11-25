import Phaser from 'phaser'

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
        this.load.html('intro-form', './assets/intro-form.html')
    }

    create()
    {
        this.handleSocketConnection()

        // scene title
        this.add.text(this.canvasWidth / 2, 200, 'Join or create a new game', { color: 'white', fontFamily: 'Arial', fontSize: '32px '}).setOrigin(0.5)

        // scene form html
        let element = this.add.dom(400, 600).createFromCache('intro-form')

        element.addListener('click')

        element.on('click', (event)=> {

            if (event.target.name === 'createGameButton') {
                
                this.game.bridge.submit({ type: 'game_create', players_count: 2 })
                
            } else if (event.target.name === 'joinGameButton') {

                let gameId = document.getElementById('game-code').value
                let username = document.getElementById('player-username').value
                if (gameId === '' || username === '') {
                    return
                }

                this.game.bridge.submit({ type: 'game_join', game_id: gameId })
            }
        })
    }

    update()
    {
        // this.player.anims.play('hero', true)
    }

    handleSocketConnection()
    {
        console.log(this.game)
        this.game.bridge.connect().then((conn)=> {
            conn.onmessage = (e)=> {
                
                let data = JSON.parse(e.data)

                if (data.type === 'game_created') {
                    // this.game.scene.remove('intro-scene')
                    // this.game.scene.start('game-scene', data)
                    document.getElementById('game-code').value = data.game_id
                }

                if (data.type === 'game_joined') {
                    // this.game.scene.remove('intro-scene')
                    // this.game.scene.start('game-scene', data)
                    if (data.hasOwnProperty('board') === true) {
                        this.game.scene.remove('intro-scene')
                        this.game.scene.start('game-scene', data)
                    } else {

                        document.getElementById('game-lobby').innerHTML = "Waiting for player..."
                    }
                }
            }

            // conn.send(JSON.stringify({type: 'game_join'}))
        }).catch((e)=> {
            console.log(e)
        })
    }
}