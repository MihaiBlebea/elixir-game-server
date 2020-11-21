class Menu extends Phaser.Scene
{
    constructor()
    {
        super({key: "menu"})
    }

    preload()
    {
        // this.load.image('player', './assets/Male/Male 01-1.png')
    }

    create()
    {
        this.add.text(0, 0, "MENU", {font: '40px Impact'})

        this.input.keyboard.on("keyup", (event)=> {
            if (event.key == "p") {
                this.scene.start("level")
            }
        })
    }
}

module.exports = Menu