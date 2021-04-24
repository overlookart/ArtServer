import Fluent
import Vapor
/**
 路由
 路由是为传入请求找到合适的请求处理程序的过程。Vapor 路由的核心是基于 RoutingKit 的高性能三节点路由器。
 
 *** 数据流(Body Streaming)
 使用on方法注册路由时，可以指定如何处理请求正文。 默认情况下，请求主体在调用处理程序之前被收集到内存中。 这很有用，因为即使您的应用程序异步读取传入的请求，它也允许请求内容解码是同步的。
 默认情况下，Vapor将流主体的大小限制为16KB。 您可以使用app.routes进行配置。
 ```
 //将流媒体主体收集限制增加到500kb
 app.routes.defaultMaxBodySize = "500kb"
 ```
 如果正在收集的流媒体主体超出了配置的限制，则会引发413有效载荷过大错误。
 要为单个路由配置请求正文收集策略，请使用body参数。
 ```
 //在调用此路由之前，先收集流媒体主体（最大1mb）。
 app.on(.POST, "listings", body: .collect(maxSize: "1mb")) { req in
     // Handle request.
 }
 ```
 如果传递了maxSize进行收集，它将覆盖该路由的应用程序默认值。 要使用应用程序的默认值，请省略maxSize参数。
 
 对于较大的请求（例如文件上传），将请求主体收集在缓冲区中可能会占用系统内存。 为了防止收集请求主体，请使用流策略。
 ```
 //请求正文不会被收集到缓冲区中
 app.on(.POST, "upload", body: .stream) { req in
     ...
 }
 ```
 当请求主体流式传输时，req.body.data将为nil。 您必须使用req.body.drain来处理每个发送到路由的块。
 
 
 
 由 Catchall(**) 匹配的 URI 的值将以 [String] 的形式存储在 req.parameters 中。 你可以使用 req.parameters.getCatchall 访问这些组件。
 // responds to GET /hello/foo
 // responds to GET /hello/foo/bar
 // ...
 app.get("hello", "**") { req -> String in
     let name = req.parameters.getCatchall().joined(separator: " ")
     return "Hello, \(name)!"
 }
 使用 on 方法注册路由时，你可以指定如何处理请求主体。默认情况下，请求主体在调用处理程序之前被收集到内存中。 这是有效的，因为它允许请求内容解码同步。 但是，对于上传文件等大型请求，这可能会占用你的系统内存。
 
 要更改请求正文的处理方式，请在注册路由时使用 body 参数。有两种方法：
 collect: 内存中处理请求体
 stream: 使用 stream 数据流
 app.on(.POST, "file-upload", body: .stream) { req in
     ...
 }
 
 *** 不区分大小写的路由
 路由的默认行为是区分大小写和保留大小写的。 出于路由目的，可以以不区分大小写和不区分大小写的方式交替处理常量路径组件。 要启用此行为，请在应用程序启动之前进行配置：
 ```
 app.routes.caseInsensitive = true
 ```
 原始请求未做任何更改； 路由处理程序将接收未经修改的请求路径组件.
 
 *** 查看路由(Viewing Routes)
 Vapor还附带有路由命令，该命令以ASCII格式的表格打印所有可用的路由。
 ```
 $ swift run Run routes (如何使用？)
 ```
 
 *** 元数据(Metadata)
 所有路线注册方法都返回创建的路线。 这使您可以将元数据添加到路由的userInfo字典中。 有一些默认方法可用，例如添加描述。
 ```
 app.get("hello", ":name") { req in
     ...
 }.description("says hello")
 ```
 
 *** 中间件(Middleware)
 除了为路径组件添加前缀之外，您还可以将中间件添加到路由组。
 ```
 app.get("fast-thing") { req in
     ...
 }
 app.group(RateLimitMiddleware(requestsPerMinute: 5)) { rateLimited in
     rateLimited.get("slow-thing") { req in
         ...
     }
 }
 ```
 这对于使用不同的身份验证中间件保护路由的子集特别有用。
 ```
 app.post("login") { ... }
 let auth = app.grouped(AuthMiddleware())
 auth.get("dashboard") { ... }
 auth.get("logout") { ... }
 ```
 
 */
func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }
    app.get { (req) in
        return """
                  It works!
                  查看 demo 请访问 /demoroutes
                  查询端口是否被占用：lsof -i:(port)
                  kill 一个进程：sudo kill (PID)
"""
    }
    
    app.post("artcontent") { req -> HTTPResponseStatus in
        let artcontent = try req.content.decode(ArtContent.self)
        print("Post请求中的Content")
        print(artcontent)
        return HTTPStatus.ok
    }
    
    app.get("artcontent", ":name") { (req) -> HTTPResponseStatus in
        let artcontent = try req.query.decode(ArtContent.self)
        print("get请求中的Content")
        print(artcontent)
        return HTTPStatus.ok
    }
    
    //get请求:/user/register?name=xzh&age=23&email=bse@22.com&phone=123
    app.get("user","register") { (req) -> ArtUser in
        //查询解码数据
        let user = try req.query.decode(ArtUser.self)
        //验证参数
        try ArtUser.validate(query: req)
        return user
    }
    
    //post请求/user/register body:视为content
    app.post("user","register") { (req) -> ArtUser in
        //通过Content解码Post请求参数
        let user = try req.content.decode(ArtUser.self)
        //验证参数
        try ArtUser.validate(content: req)
        return user
    }
    
    print("已注册的全部路由---",app.routes.all)
}
