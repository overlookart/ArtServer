//
//  File.swift
//  
//
//  Created by xzh on 2021/4/24.
//
import Vapor
import Foundation
func demoRoutes(_ app: Application) throws {
    let routeName: PathComponent = "demoroutes"
    let app_on: PathComponent = "app_on"
    let app_method: PathComponent = "app_method"
    let http_method: PathComponent = "http_method"
    let routes_path: PathComponent = "routes_path"
    let app_grouped: PathComponent = "app_grouped"
    let app_routes: PathComponent = "app_routes"
    let req_redirect: PathComponent = "req_redirect"
    let req_content: PathComponent = "req_content"
    //组路由
    let demoRoutes = app.grouped(routeName)
    demoRoutes.get { (req) -> String in
        let overview = """
                        Vapor 的两种路由方法
                        app.on(method:... 请访问 /\(routeName)/\(app_on)
                        app.method(...    请访问 /\(routeName)/\(app_method)
                        -----------------------------------
                        常见 HTTPMethod... 请访问 /\(routeName)/\(http_method)
                        -----------------------------------
                        请求路径：/pathName/pathName/... 请访问 /\(routeName)/\(routes_path)
                        -----------------------------------
                        组路由 Route Groups... 请访问 /\(routeName)/\(app_grouped)
                        -----------------------------------
                        查看路由... 请访问 /\(routeName)/\(app_routes)
                        -----------------------------------
                        重定向 Redirections... 请访问 /\(routeName)/\(req_redirect)
                        -----------------------------------
                        请求参数... 请访问 /\(routeName)/\(req_content)
                        """
        return overview
    }.description("Demo 目录")
    
    
    
    app.on(.GET, routeName, app_on) { req in
        return """
                这是一个以 app.on get 请求
                method 为 http 方法
                path 为路由路径
                use 为请求闭包
                app.on(method: HTTPMethod, path: PathComponent..., use: (Request) throws -> ResponseEncodable)

                """
    }
    
    app.get(routeName, app_method) { (req) -> String in
        return """
                这是一个以 app.method get 请求
                method 为 http 方法
                path 为路由路径
                use 为请求闭包 
                app.get(path: PathComponent..., use: (Request) throws -> ResponseEncodable)
                路由处理程序支持返回 ResponseEncodable 的任何内容。这包括 Content 和将来值为 ResponseEncodable 的 EventLoopFuture。
                你可以在 in 之前使用 -> T 来指定路线的返回类型。这在编译器无法确定返回类型的情况下很有用。
                app.get("foo") { req -> String in
                    return "bar"
                }
                """
    }
    
    
    demoRoutes.get(http_method) { (req) -> String in
        return """
                HTTP 方法
                请求的第一部分是 HTTP 方法。其中 GET 是最常见的 HTTP 方法，以下这些是经常会使用几种方法，这些 HTTP 方法通常与 CRUD 语义相关联
                Method    CURD
                GET       Read
                POST      Create
                PUT       Replace
                PATCH     Update
                DELETE    Delete
                """
    }
    
    demoRoutes.get(routes_path) { (req) -> String in
        return """
                路由路径
                在 HTTP 方法之后是请求的 URI。它由以 / 开头的路径和在 ? 之后的可选查询字符串组成。HTTP 方法和路径是 Vapor 用于路由请求的方法
                路由为给定的 HTTP 方法和 URI 路径指定请求处理程序。它还可以存储其他元数据
                可以使用多种 HTTP 方法帮助程序将路由直接注册到你的 Application
                注意：所有的路由路径必须遵守 PathComponent
                ------------------------------------
                (路径组件)PathComponent
                 每种路由注册方法都接受 PathComponent 的可变列表。此类型可以用字符串文字表示，并且有四种情况：
                 Constant (foo)    静态路径
                 Parameter (:foo)  参数路径
                 Anything (*)      任何路径
                 Catchall (**)     通配路径
                -------------------------------------
                 静态路径
                 这是静态路由组件。仅允许在此位置具有完全匹配的字符串的请求。
                 // responds to GET /foo/bar/baz
                 app.get("foo", "bar", "baz") { req in
                     ...
                 }
                ----------------------------------------
                 参数路径
                 这是一个动态路由组件。此位置的任何字符串都将被允许。参数路径组件以 : 前缀指定。: 后面的字符串将用作参数名称。你可以使用该名称稍后从请求中获取参数值。
                 // responds to GET /foo/bar/baz
                 // responds to GET /foo/qux/baz
                 // ...
                 app.get("foo", ":bar", "baz") { req in
                     ...
                 }
                
                 参数
                 使用参数路径组件（以 : 前缀）时，该位置的 URI 值将存储在 req.parameters 中。 你可以使用路径组件的名称来访问。
                 // responds to GET /hello/foo
                 // responds to GET /hello/bar
                 // ...
                 app.get("hello", ":name") { req -> String in
                     let name = req.parameters.get("name")!
                     return "Hello, \\(name)!"
                 }
                 提示
                 我们可以确定 req.parameters.get 在这里绝不会返回 nil ，因为我们的路径包含 :name。 但是，如果要访问中间件中的路由参数或由多个路由触发的代码中的路由参数，则需要处理 nil 的可能性。
                 req.parameters.get 还支持将参数自动转换为 LosslessStringConvertible 类型。
                 // responds to GET /number/42
                 // responds to GET /number/1337
                 // ...
                 app.get("number", ":x") { req -> String in
                     guard let int = req.parameters.get("x", as: Int.self) else {
                         throw Abort(.badRequest)
                     }
                     return "\\(int) is a great number"
                 }
                
                ----------------------------------------
                 任何路径
                 除了丢弃值之外，这与参数路径非常相似。此路径组件仅需指定为 * 。
                 // responds to GET /foo/bar/baz
                 // responds to GET /foo/qux/baz
                 // ...
                 app.get("foo", "*", "baz") { req in
                     ...
                 }
                -----------------------------------------
                 通配路径
                 这是与一个或多个组件匹配的动态路由组件，仅使用 ** 指定。请求中将允许匹配此位置或更高位置的任何字符串。
                 // responds to GET /foo/bar
                 // responds to GET /foo/bar/baz
                 // ...
                 app.get("foo", "**") { req in
                     ...
                 }

                """
    }
    
    demoRoutes.get(app_grouped) { (req) -> String in
        return """
             通过路由分组，您可以创建带有路径前缀或特定中间件的一组路由。 分组支持基于构建器和闭包的语法。
             所有分组方法均返回RouteBuilder，这意味着您可以将组与其他路由构建方法无限地混合，匹配和嵌套。
             
             *** 路径前缀(Path Prefix)
             路径前缀路由组使您可以在一个路由组之前添加一个或多个路径组件。
             ```
             let users = app.grouped("users")
             // GET /users
             users.get { req in
                 ...
             }
             // POST /users
             users.post { req in
                 ...
             }
             // GET /users/:id
             users.get(":id") { req in
                 let id = req.parameters.get("id")!
                 ...
             }
             ```
             您可以传递给诸如get或post之类的方法的任何路径组件都可以传递为分组的。 还有另一种基于闭包的语法。
             ```
             app.group("users") { users in
                 // GET /users
                 users.get { req in
                     ...
                 }
                 // POST /users
                 users.post { req in
                     ...
                 }
                 // GET /users/:id
                 users.get(":id") { req in
                     let id = req.parameters.get("id")!
                     ...
                 }
             }
             ```
             嵌套路径前缀路由组使您可以简洁地定义CRUD API。
             ```
             app.group("users") { users in
             // GET /users
             users.get { ... }
             // POST /users
             users.post { ... }

             users.group(":id") { user in
                 // GET /users/:id
                 user.get { ... }
                 // PATCH /users/:id
                 user.patch { ... }
                 // PUT /users/:id
                 user.put { ... }
             }
            }
            ```
            """
    }
    
    demoRoutes.get(app_routes) { (req) -> String in
        var routeStr = "服务器的所有路由："
        for route in app.routes.all {
            routeStr += "\n\(route)"
        }
        return routeStr
    }
    
    demoRoutes.get(req_redirect) { req in
        req.redirect(to: "\(req_redirect)/overview")
    }
    demoRoutes.get(req_redirect,"overview") { (req) -> String in
        return """
             ** 重定向(Redirections)
             重定向在许多情况下很有用，例如将旧位置转发到SEO的新位置，将未经身份验证的用户重定向到登录页面或保持与新版本API的向后兼容性。
             要重定向请求，请使用：
             ```
             req.redirect(to: "/some/new/path")
             ```
             您还可以指定重定向的类型，例如，永久重定向页面（以便正确更新您的SEO）使用：
             ```
             req.redirect(to: "/some/new/path", type: .permanent)
             ```
             不同的RedirectType是：
             .permanent-返回301永久重定向
             .normal-返回303，请参阅其他重定向。 这是Vapor的默认设置，它告诉客户端使用GET请求进行重定向。
             .temporary-返回307临时重定向。 这告诉客户端保留请求中使用的HTTP方法。
            """
    }
    
    demoRoutes.get(req_content) { (req) -> String in
        return """
         基于 Vapor 的 content API，你可以轻松地对 HTTP 消息中的可编码结构进行编码/解码。
         默认使用JSON编码，并支持URL-Encoded Form和Multipart。
         content API 可以灵活配置，允许你为某些 HTTP 请求类型添加、修改或替换编码策略。

        解码一个 Http 请求参数，我们首先要创建一个与预期结构想匹配的 Codable 数据类型。
        数据类型遵循 Content 协议，将同时支持 Codable 协议规则，符合 Content API 的其他程序代码
        ----------------------------------------
        get  请求参数...      /\(req_content)/user?name=&age=&email=
        post 请求参数...      /\(req_content)/user  {name=?,age=?,email=?}

        """
    }
    
    demoRoutes.get(req_content, "user") { (req) -> DemoUser in
        //验证参数 get query 验证
        try DemoUser.validate(query: req)
        //get 使用查询 解码参数
        let user = try req.query.decode(DemoUser.self)
        print(user)
        return user
    }
    
    demoRoutes.post(req_content, "user") { (req) -> DemoUser in
        //验证参数 post content 验证
        try DemoUser.validate(content: req)
        //post 使用content 解码参数
        let user = try req.content.decode(DemoUser.self)
        print(user)
        return user
    }
    
}
