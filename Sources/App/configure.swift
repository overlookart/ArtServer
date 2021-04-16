import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)
}


/**
 端口冲突解决方案
 1.找到被占用的指定端口号所对应的进程
 sudo lsof -i:(port)
 2.关闭这个进程
 sudo kill (PID)
 */
