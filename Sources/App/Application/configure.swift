import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.logger.info("app ****** 开始配置")
    app.logger.info("app ----- 配置数据库")
    
    app.databases.use(.postgres(hostname: "127.0.0.1", port: 5432, username: "xzh", password: "123456",database: "mydb"), as: .psql, isDefault: true)
    app.logger.info("app ----- 注册数据库迁移")
    app.migrations.add(CreateDemouser(), to: .psql)
    app.migrations.add(UpdateDemouser_V3(), to: .psql)
    /**
     xcode 配置启动命令 迁移数据库
     edit scheme -> run -> arguments passed on lauch
     migrate 迁移
     migrate --revert 恢复
     */
    
    app.logger.info("app ----- 配置生命周期")
    app.lifecycle.use(AppLifecycleHandler())
    
    app.logger.info("app ----- 配置路由")
    try routes(app)
    try demoRoutes(app)
    
    app.logger.info("app ----- 运行环境")
    //访问当前环境
    switch app.environment {
    //可以配置不同环境下的数据库
    case .development:
        app.logger.info("app ----- 开发环境")
    case .production:
        app.logger.info("app ----- 正式环境")
    case .testing:
        app.logger.info("app ----- 测试环境")
    default: break
        
    }
    ArtLogger.artLogger().warning("自定义日志", metadata: nil)
    app.logger.info("app ****** 配置完成")
}


/**
 端口冲突解决方案
 1.找到被占用的指定端口号所对应的进程
 sudo lsof -i:(port)
 2.关闭这个进程
 sudo kill (PID)
 */
