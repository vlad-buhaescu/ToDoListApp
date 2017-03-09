import Vapor
import VaporSQLite
import HTTP

let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

let controller = TaskViewController()
controller.addRoutes(drop: drop)

//drop.resource("Tasks", controller)

drop.run()
