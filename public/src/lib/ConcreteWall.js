const Entity = require('./Entity')

class ConcreteWall extends Entity
{
    constructor() {
        super()

        this.canBeDestroyed = false
        this.isDestroyed    = false
        this.color          = '#b3b3b3'
        this.texture        = 'concrete-wall'
    }
}

module.exports = ConcreteWall