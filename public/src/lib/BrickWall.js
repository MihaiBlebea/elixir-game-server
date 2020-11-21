const Entity = require('./Entity')

class BrickWall extends Entity
{
    img = null

    constructor() 
    {
        super()

        this.canBeDestroyed = true
        this.isDestroyed    = false
        this.color          = 'red'
        this.texture        = 'brick-wall'
    }
}

module.exports = BrickWall