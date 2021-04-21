import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
app.routes.defaultMaxBodySize = "500kb"
app.routes.caseInsensitive = false
try app.run()

