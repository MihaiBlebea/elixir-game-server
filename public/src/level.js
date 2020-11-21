const Board = require('./lib/Board')
const Player = require('./lib/Player')

class Level extends Phaser.Scene
{
    _board = null

    _enemies = []

    constructor()
    {
        super({key: "level"})
    }

    init()
    {
        this._board = new Board(this.game.config.height / 40)
        // this._board.addEntity(new Player())

        // this._board.addEntity(new Enemy(), )
        // this._board.addEntity(new Enemy())
        // this._board.addEntity(new Enemy())
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
        // this.cameras.main.setBackgroundColor('#5c9f1d')

        this.player = this.physics.add.sprite(40 + 32 / 2, 40 + 32 / 2, 'player', 0)
        // this.bomb = this.physics.add.sprite(40 + 32 / 2, 40 + 32 / 2, 'bomb', 1)
        
        this.renderLevel()

        // this.physics.add.collider(this.player, this.enemy, (event) => {
        //     console.log('colided')
        // }, null, this)

        this.physics.add.collider(this.player, this.walls, (event) => {
            // console.log('colided with wall')
            this.player.anims.pause()
            this.player.setVelocityY(0)
            this.player.setVelocityX(0)
        }, null, this)


		this.player.setCollideWorldBounds({ collides: true })

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

        this.key_D = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.D)
        this.key_A = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.A)
        this.key_S = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.S)
        this.key_W = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.W)
        this.key_space = this.input.keyboard.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE)

        this.input.keyboard.on("keyup", (event)=> {
            if (event.key == "p") {
                this.scene.start("menu")
            }
        })
    }

    update(delta)
    {
        this.movePlayer()
    }

    movePlayer() 
    {
        const speed = 80

        if (this.key_A.isDown) {
            this.player.setVelocityX(-speed)
            this.player.anims.play('left', true)
        } else if (this.key_D.isDown) {
            this.player.setVelocityX(speed)
            this.player.anims.play('right', true)
        } else if (this.key_W.isDown) {
            this.player.setVelocityY(-speed)
            this.player.anims.play('up', true)
        } else if (this.key_S.isDown) {
            this.player.setVelocityY(speed)
            this.player.anims.play('down', true)
        } else if (this.key_space.isDown) {
            // this.player.setVelocityY(speed)
            // this.player.anims.play('down', true) 
            console.log("bomb deployed")
            
            
            this.bomb.anims.play('bomb')
        } else {
            this.player.anims.pause()
            this.player.setVelocityY(0)
            this.player.setVelocityX(0)
        }
    }

    renderLevel()
    {
        this.walls = this.physics.add.staticGroup()
        
        let boxSize = this._board.getBoxSize()

        for (let x = 0; x < this._board.getBoardSize(); x++) {
            for (let y = 0; y < this._board.getBoardSize(); y++) {
                let box = this._board.getBoxAt(x, y)

                if (!box.isEmpty()) {
                    // this.walls.create(x * boxSize + boxSize / 2, y * boxSize + boxSize / 2, box.getTopEntity().texture)
                    // if (box.getTopEntity().texture === 'enemy') {
                    //     this._enemies.push(
                    //         this.physics.add.sprite(x * boxSize + boxSize / 2, y * boxSize + boxSize / 2, 'enemy', 0)
                    //     )

                    //     this._enemies.map((enemy)=> {
                    //         let moves = [ [100, 0], [0, 100], [-100, 0], [0, -100] ]
                    //         let index = 0
                            
                    //         enemy.setVelocityY(moves[index][0])
                    //         enemy.setVelocityX(moves[index][1])

                    //         this.physics.add.collider(enemy, this.walls, (event) => {
                    //             index++
                    //             if (index > moves.length - 1) {
                    //                 index = 0 
                    //             }

                    //             enemy.setVelocityY(moves[index][0])
                    //             enemy.setVelocityX(moves[index][1])
                    //         }, null, this)
                    //     })

                    // } else {
                    //     this.walls.create(x * boxSize + boxSize / 2, y * boxSize + boxSize / 2, box.getTopEntity().texture)
                    // }
                }
            }
        }
    }

    // createEnemies()
    // {
    //     for (let i = 0; i < 5; i++) {
    //         let box = this._board.getRandomEmptyBox()
            
    //         this.enemy = this.physics.add.sprite(
    //             box.x + this._board.getBoxSize() / 2, 
    //             box.y + this._board.getBoxSize() / 2, 
    //             'enemy', 
    //             0
    //         )
    //     }
    // }
}

module.exports = Level