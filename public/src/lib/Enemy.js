const Entity = require('./Entity')

class Enemy extends Entity
{
    constructor()
    {
        super()

        this.texture = 'enemy'
    }
}


module.exports = Enemy