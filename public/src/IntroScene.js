import Phaser from 'phaser'

export default class IntroScene extends Phaser.Scene
{
    sharedConfig = null

    title = null

    playerId = null

    gameId = null

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
        this.title = this.add.text(this.canvasWidth / 2, 200, 'Join or create a new game', { color: 'white', fontFamily: 'Arial', fontSize: '32px '}).setOrigin(0.5)
        
        // scene form html
        let element = this.add.dom(400, 600).createFromCache('intro-form')

        element.addListener('click')

        element.on('click', (event)=> {

            if (event.target.name === 'createGameButton') {
                
                this.game.bridge.createGame('game_1', 1)
                
            } else if (event.target.name === 'joinGameButton') {

                let gameId = document.getElementById('game-code').value
                let username = document.getElementById('player-username').value
                if (gameId === '' || username === '') {
                    return
                }

                this.game.bridge.joinGame(gameId, username)
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
                    console.log(data)
                    document.getElementById('game-code').value = data.game_id
                }

                if (data.type === 'game_joined') {
                    console.log(data)
                    this.handleChangeTitle(`Players to join ${ data.spaces_left } - Waiting for other players to join...`)
                    this.gameId = data.game_id
                    this.playerId = data.player_id
                }

                if (data.type === 'game_starting') {
                    this.handleChangeTitle(`Game starting in ${ data.time_left }...`)
                }

                if (data.type === 'game_started') {
                    this.handleStartGameScene()
                }
            }
        }).catch((e)=> {
            console.log(e)
        })
    }

    handleStartGameScene(data)
    {
        this.game.scene.remove('intro-scene')
        this.game.scene.start('game-scene', { gameId: this.gameId, playerId: this.playerId })
    }

    handleChangeTitle(text)
    {
        this.title.text = text
    }
}