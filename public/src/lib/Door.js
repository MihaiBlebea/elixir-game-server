const Entity = require('./Entity')

class Door extends Entity
{
    constructor() {
        super()
        
        this.canBeDestroyed = false
        this.isDestroyed    = false
        this.color          = 'blue'
        this.texture        = 'door'
    }
}

module.exports = Door