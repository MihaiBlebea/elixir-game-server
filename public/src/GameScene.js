import Phaser from 'phaser'
import MoveTo from 'phaser3-rex-plugins/plugins/moveto.js'

export default class GameScene extends Phaser.Scene
{

    players = []

    constructor()
    {
        super({key: "game-scene"})
    }

    init({ board, game_id })
    {
        console.log(board)
        this.board = board
        this.gameId = game_id
    }

    preload()
    {
        this.load.spritesheet('player', './assets/Male/Male 01-1.png', {frameWidth: 32, frameHeight: 32})
        this.load.spritesheet('enemy', './assets/Soldier/Soldier 03-4.png', {frameWidth: 32, frameHeight: 32})
        this.load.spritesheet('brick-wall', './assets/brick.png', {frameWidth: 40, frameHeight: 40})
        this.load.spritesheet('concrete-wall', './assets/concrete.png', {frameWidth: 40, frameHeight: 40})
        this.load.spritesheet('bomb', './assets/bomb.png', {frameWidth: 40, frameHeight: 40})
    }

    create()
    {
        // this.player = this.physics.add.sprite(40 + 32 / 2, 40 + 32 / 2, 'player', 0)
        // this.bomb = this.physics.add.sprite(40 + 32 / 2, 40 + 32 / 2, 'bomb', 1)

        this.game.bridge.connection.onmessage = (e)=> {
            console.log(e)
            let data = JSON.parse(e.data)
            if (data.type === 'game_moved') {
                this.players.forEach((player)=> {
                    if (player.x === data.x && player.y === data.y) {
                        // console.log(data)

                        let moveTo = new MoveTo(player.player, {
                            speed: 400,
                            rotateToTarget: false
                        })
                        // let moveTo = scene.plugins.get('rexMoveTo').add(player.player, {
                        //     speed: 400,
                        //     rotateToTarget: false
                        // })

                        if (data.hasOwnProperty('move_x')) {
                            moveTo.moveTo((data.x + data.move_x) * 40, data.y * 40)
                            player.x = data.x + data.move_x
                        }

                        if (data.hasOwnProperty('move_y')) {
                            moveTo.moveTo(data.x * 40, (data.y + data.move_y) * 40)
                            player.y = data.y + data.move_y
                        }
                    }
                })
            }
        }

        this.buildBoard()
        

        // this.physics.add.collider(this.player, this.enemy, (event) => {
        //     console.log('colided')
        // }, null, this)

        // this.physics.add.collider(this.player, this.walls, (event) => {
        //     // console.log('colided with wall')
        //     this.player.anims.pause()
        //     this.player.setVelocityY(0)
        //     this.player.setVelocityX(0)
        // }, null, this)


		// this.player.setCollideWorldBounds({ collides: true })

        this.anims.create({
            key: 'left',
            frames: this.anims.generateFrameNumbers('player', {start: 3, end: 5}),
            repeatw: -1,
            frameRate: 10
        })

        this.anims.create({
            key: 'right',
            frames: this.anims.generateFrameNumbers('player', {start: 6, end: 8}),
            repeat: -1,
            frameRate: 10
        })

        this.anims.create({
            key: 'up',
            frames: this.anims.generateFrameNumbers('player', {start: 9, end: 11}),
            repeat: -1,
            frameRate: 10
        })

        this.anims.create({
            key: 'down',
            frames: this.anims.generateFrameNumbers('player', {start: 0, end: 2}),
            repeat: -1,
            frameRate: 10
        })

        this.anims.create({
            key: 'bomb',
            frames: this.anims.generateFrameNumbers('bomb', {start: 3, end: 5}),
            repeatw: -1,
            frameRate: 5
        })

        // this.key_D = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.D)
        // this.key_A = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.A)
        // this.key_S = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.S)
        // this.key_W = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.W)
        // this.key_space = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE)

        // this.input.keyboard.on("keyup", (event)=> {
        //     if (event.key == "p") {
        //         this.scene.start("menu")
        //     }
        // })

        this.input.keyboard.on("keyup", (event)=> {
            if (event.key === "a") {
                this.game.bridge.submit({
                    type: "game_move",
                    x: this.players[0].x,
                    y: this.players[0].y,
                    move_x: -1,
                    game_id: this.gameId
                })
            }

            if (event.key === "d") {
                this.game.bridge.submit({
                    type: "game_move",
                    x: this.players[0].x,
                    y: this.players[0].y,
                    move_x: 1,
                    game_id: this.gameId
                })
            }

            if (event.key === "w") {
                this.game.bridge.submit({
                    type: "game_move",
                    x: this.players[0].x,
                    y: this.players[0].y,
                    move_y: -1,
                    game_id: this.gameId
                })
            }

            if (event.key === "s") {
                this.game.bridge.submit({
                    type: "game_move",
                    x: this.players[0].x,
                    y: this.players[0].y,
                    move_y: 1,
                    game_id: this.gameId
                })
            }
        })
    }

    update(delta)
    {
        // this.movePlayer()
    }

    // movePlayer() 
    // {
    //     const speed = 80

    //     if (this.key_A.isDown) {
    //         // this.player.setVelocityX(-speed)
    //         // this.player.anims.play('left', true)
    //         this.game.bridge.submit({
    //             type: "game_move",
    //             x: this.players[0].x,
    //             y: this.players[0].y,
    //             move_x: -1,
    //             game_id: this.gameId
    //         })
        
    //     } else if (this.key_D.isDown) {
    //         this.player.setVelocityX(speed)
    //         this.player.anims.play('right', true)
    //     } else if (this.key_W.isDown) {
    //         this.player.setVelocityY(-speed)
    //         this.player.anims.play('up', true)
    //     } else if (this.key_S.isDown) {
    //         this.player.setVelocityY(speed)
    //         this.player.anims.play('down', true)
    //     } else if (this.key_space.isDown) {
    //         // this.player.setVelocityY(speed)
    //         // this.player.anims.play('down', true) 
    //         console.log("bomb deployed")
            
            
    //         this.bomb.anims.play('bomb')
    //     } else {
    //         this.player.anims.pause()
    //         this.player.setVelocityY(0)
    //         this.player.setVelocityX(0)
    //     }
    // }

    buildBoard()
    {
        this.walls = this.physics.add.staticGroup()
        let boxSize = 40

        for (let x = 0; x < Object.keys(this.board).length; x++) {
            for (let y = 0; y < Object.keys(this.board).length; y++) {

                let entity = this.pickEntity(this.board[x][y].entities)
                if (entity !== null) {
                    switch (entity) {
                        case 'concrete_wall':
                            this.walls.create(x * boxSize + boxSize / 2, y * boxSize + boxSize / 2, 'concrete-wall')
                            break
                        case 'brick_wall':
                            this.walls.create(x * boxSize + boxSize / 2, y * boxSize + boxSize / 2, 'brick-wall')
                            break
                        case 'enemy':
                            this.walls.create(x * boxSize + boxSize / 2, y * boxSize + boxSize / 2, 'enemy')
                            break
                        case 'player':
                            let id = `player-${ x }-${ y }`
                            let player = this.physics.add.sprite(x * boxSize, y * boxSize, id, 0).setOrigin(0, 0)

                            this.players.push({
                                id: id,
                                player: player,
                                x: x,
                                y: y
                            })

                            console.log(this.players)
                            break
                    }
                }
            }
        }
    }

    pickEntity(entities)
    {
        return entities.length > 0 ? entities[0] : null
    }
}