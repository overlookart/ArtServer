import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(.postgres(hostname: "localhost", username: "vapor", password: "vapor"), as: .psql)
    //app 的生命周期
    app.lifecycle.use(AppLifecycleHandler())
    // register routes
    try routes(app)
    try demoRoutes(app)
    
    switch app.environment {
    case .development:
        print("开发环境")
    case .production:
        print("正式环境")
    case .testing:
        print("测试环境")
    default: break
        
    }
}


/**
 端口冲突解决方案
 1.找到被占用的指定端口号所对应的进程
 sudo lsof -i:(port)
 2.关闭这个进程
 sudo kill (PID)
 */
