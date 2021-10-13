import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    ArtLogger.artLogger().info("app ****** 开始配置")
    ArtLogger.artLogger().info("app ----- 配置数据库")
    
    app.databases.use(.postgres(hostname: "127.0.0.1", port: 5432, username: "xxx", password: "***",database: "dbName"), as: .psql, isDefault: true)
    ArtLogger.artLogger().info("app ----- 注册数据库迁移")
    app.migrations.add(CreateDemouser(), to: .psql)
//    app.migrations.add(UpdateDemouser_V3(), to: .psql)
    /**
     xcode 配置启动命令 迁移数据库
     edit scheme -> run -> arguments passed on lauch
     migrate 迁移
     migrate --revert 恢复
     */
    
    ArtLogger.artLogger().info("app ----- 配置生命周期")
    app.lifecycle.use(AppLifecycleHandler())
    
    ArtLogger.artLogger().info("app ----- 配置路由")
    try routes(app)
    try demoRoutes(app)
    
    ArtLogger.artLogger().info("app ----- 运行环境")
    //访问当前环境
    switch app.environment {
    //可以配置不同环境下的数据库
    case .development:
        ArtLogger.artLogger().info("app ----- 开发环境")
    case .production:
        ArtLogger.artLogger().info("app ----- 正式环境")
    case .testing:
        ArtLogger.artLogger().info("app ----- 测试环境")
    default: break
        
    }
    ArtLogger.artLogger().info("app ---- 配置默认server")
    
    //配置主机名 默认127.0.0.1
    app.http.server.configuration.hostname = "127.0.0.1"
    //配置端口号
    app.http.server.configuration.port = 8083
    //处理队列的最大长度 默认256
    app.http.server.configuration.backlog = 128
    //复用地址
    app.http.server.configuration.reuseAddress = false
    //TCP无延迟
    app.http.server.configuration.tcpNoDelay = true
    //响应压缩 使用 gzip 控制 HTTP 响应压缩
    app.http.server.configuration.responseCompression = .enabled
    //请求解压缩 使用 gzip 控制 HTTP 请求解压缩
    app.http.server.configuration.requestDecompression = .enabled
    //通道 启用对 HTTP 请求和响应流水线的支持
    app.http.server.configuration.supportPipelining = true
    //支持版本 控制服务器将使用哪些HTTP版本。默认情况下，启用TLS时，Vapor将同时支持HTTP/1和HTTP/2。禁用TLS时，仅支持HTTP/1
    app.http.server.configuration.supportVersions = [.one]
    //名称
    app.http.server.configuration.serverName = "artserver"
    //TLS
    //手动启动
    try app.server.start()
    //请求关闭
    app.server.shutdown()
    
    
    
    ArtLogger.artLogger().info("自定义日志", metadata: nil)
    ArtLogger.artLogger().info("app ****** 配置完成")
}


/**
 端口冲突解决方案
 1.找到被占用的指定端口号所对应的进程
 sudo lsof -i:(port)
 2.关闭这个进程
 sudo kill (PID)
 */
