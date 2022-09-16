import App
import Vapor

/**
 Environment 运行环境
 通常，使用Environment.detect() 在main.swift中设置应用程序的环境。
 detect方法使用进程的命令行参数并自动解析--env标志。
 您可以通过初始化自定义环境结构来覆盖此行为
 要定义自定义环境名称，请扩展环境 如 staging
 */
//let e = Environment.staging
var env = try Environment.detect()
//获取环境变量
var foo = Environment.get("FOO")
//查询环境变量
foo = Environment.process.FOO


/**
 系统日志
 */
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)

defer { app.shutdown() }

try configure(app)

app.routes.defaultMaxBodySize = "500kb"

app.routes.caseInsensitive = false
// 启动应用程序
try app.run()

