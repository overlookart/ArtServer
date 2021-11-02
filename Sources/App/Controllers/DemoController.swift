//
//  File.swift
//  
//
//  Created by xzh on 2021/5/16.
//

import Foundation
import Vapor
import Fluent
struct DemoController: RouteCollection {
    let routeName: PathComponent = "demoroutes"
    let app_on: PathComponent = "app_on"
    let app_method: PathComponent = "app_method"
    let http_method: PathComponent = "http_method"
    let routes_path: PathComponent = "routes_path"
    let app_grouped: PathComponent = "app_grouped"
    let app_routes: PathComponent = "app_routes"
    let req_redirect: PathComponent = "req_redirect"
    let req_content: PathComponent = "req_content"
    let req_client: PathComponent = "req_client"
    let database_query: PathComponent = "database_query"
    let database_create: PathComponent = "database_create"
    let database_update: PathComponent = "database_update"
    let database_delete: PathComponent = "database_delete"
    func boot(routes: RoutesBuilder) throws {
        let demoRoute = routes.grouped(routeName)
        demoRoute.get(use: overview(req:))
        demoRoute.get(app_on, use: appOn(req:))
        demoRoute.get(app_method, use: appMethod(req:))
        demoRoute.get(http_method, use: httpMethod(req:))
        demoRoute.get(routes_path, use: routesPath(req:))
        demoRoute.get(app_grouped, use: appGrouped(req:))
        demoRoute.get(app_routes, use: appRoutes(req:))
        demoRoute.get(req_redirect, use: reqRedirect(req:))
        demoRoute.get(req_redirect, "overview", use: redirect(req:))
        demoRoute.get(req_client, ":http_method", use: reqClient(req:))
        demoRoute.get(req_content, use: reqContent(req:))
        
        demoRoute.get(req_content, "user", use: user(req:))
        demoRoute.post(req_content, "user", use: user(req:))
        //创建用户
        demoRoute.get(req_content, database_create, "user", use: createUser(req:))
        demoRoute.post(req_content, database_create, "user", use: createUser(req:))
        //查询用户
        demoRoute.get(req_content, database_query, "user", use: queryUser(req:))
        //更新用户
        demoRoute.post(req_content, database_update, "user", use: updateUser(req:))
        //删除用户
        demoRoute.post(req_content, database_delete, "user", use: deleteUser(req:))
    }
    
    func overview(req: Request) throws -> String  {
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
                        -----------------------------------
                        调用外部资源... 请访问 /\(routeName)/\(req_client)/get
                        """
        return overview
    }
    
    func appOn(req: Request) throws -> String {
        return """
                app.on get 请求方式说明
                method 为 http 方法
                path 为路由路径
                use 为请求闭包
                app.on(method: HTTPMethod, path: PathComponent..., use: (Request) throws -> ResponseEncodable)
                """
    }
    
    func appMethod(req: Request) throws -> String {
        return """
                app.method get app请求方式说明
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
    
    func httpMethod(req: Request) throws -> String {
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
    
    func routesPath(req: Request) throws -> String {
        return """
                路由路径说明
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
    
    func appGrouped(req: Request) throws -> String {
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
    
    func appRoutes(req: Request) throws -> String {
        var routeStr = "服务器的所有路由："
        for route in req.application.routes.all {
            routeStr += "\n\(route)"
        }
        return routeStr
    }
    
    func reqRedirect(req: Request) throws -> Response {
        return req.redirect(to: "\(req_redirect)/overview")
    }
    
    func redirect(req: Request) throws -> String {
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
    
    func reqClient(req: Request) throws -> String {
        print(req.parameters)
        guard let http_method = req.parameters.get("http_method") else {
            return "无法获取调用外部资源的http方法"
        }
        //日志
        req.logger.info("开始调用外部资源")
        if http_method == "get" {
            _ = req.client.get("https://httpbin.org/status/200").map { (response) -> (String) in
                print("Get 调用外部资源",response)
                return "b"
            }
        } else if http_method == "post" {
            let eventLoopFuture: EventLoopFuture = req.client.post("https://httpbin.org/status/200") {req in
                // 将查询参数加入请求的 URL
                try req.query.encode(["q" : "test"])
                // 将 JSON 添加到请求体
                try req.content.encode(["hello": "world"])
            }.map { (response) -> (String) in
                print("Post 调用外部资源",response)
                return "c"
            }
            
            eventLoopFuture.whenComplete { (result) in
                switch result {
                case .success(let str):
                    print("请求外部资源成功：", str)
                case .failure(let err):
                    print("请求外部资源失败：", err)
                }
                
            }
        } else if http_method == "get_json" {
            
            req.client.get("https://httpbin.org/json").flatMapThrowing { response -> tJson in
                print("开始解析数据",response)
                let json = try response.content.decode(tJson.self)
                print("解析完数据",json)
                return json
            }.map { (content) -> (tJson) in
                return content
            }
        }
        
        return "a"
    }
    
    /// 请求参数文档说明
    /// - Parameter req: 请求体
    /// - Returns: 文档文案
    func reqContent(req: Request) -> String {
        return """
         基于 Vapor 的 content API，你可以轻松地对 HTTP 消息中的可编码结构进行编码/解码。
         默认使用JSON编码，并支持URL-Encoded Form和Multipart。
         content API 可以灵活配置，允许你为某些 HTTP 请求类型添加、修改或替换编码策略。

        解码一个 Http 请求参数，我们首先要创建一个与预期结构想匹配的 Codable 数据类型。
        数据类型遵循 Content 协议，将同时支持 Codable 协议规则，符合 Content API 的其他程序代码
        ----------------------------------------
        get  请求参数...      /\(req_content)/user?name=&age=&email=
        post 请求参数...      /\(req_content)/user  {name=?,age=?,email=?}
        
        get  创建用户...      /\(req_content)/\(database_create)/user?name=&age=&email=
        post 创建用户...      /\(req_content)/\(database_create)/user  {name=?,age=?,email=?}
        database 查询用户...     /\(req_content)/\(database_query)/user
        database 更新用户...  /\(req_content)/\(database_update)/user /*根据用户名更新用户信息 post*/
        database 删除用户...  /\(req_content)/\(database_delete)/user /*根据用户名删除用户信息 post*/
        """
    }
    
    func user(req: Request) throws -> DemoUser {
        /**
         1.判断请求方式
         2.请求参数验证
         3.解码参数，生成数据模型
         */
        if req.method == .POST {
            try DemoUser.validate(content: req)
            let user = try req.content.decode(DemoUser.self)
            return user
        }else{
            try DemoUser.validate(query: req)
            let user = try req.query.decode(DemoUser.self)
            return user
        }
    }
    
    /// 创建用户
    /// - Parameter req: 请求体
    /// - Returns: <#description#>
    func createUser(req: Request) throws -> EventLoopFuture<demouser> {
        var dbuser: demouser
        if req.method == .POST {
            dbuser = try req.content.decode(demouser.self)
        }else{
            dbuser = try req.query.decode(demouser.self)
        }
        let d = dbuser.create(on: req.db).map { () -> (demouser) in
            dbuser
        }
        d.whenFailure { (err) in
            req.logger.debug("\(err)")
        }
        d.whenSuccess { demouser in
            req.logger.debug("\(demouser)")
        }
        return d
    }
    
    /// 查询用户
    /// - Parameter req: 请求体
    /// - Returns: <#description#>
    func queryUser(req: Request) throws -> EventLoopFuture<[demouser]> {
        /**
         Fluent 的query API 允许您从数据库中create、read、update和delete模型
         它支持过滤results、joins、chunking、aggregates等
         */
        
        /**
         查询构建器(Query builders)
         查询构建器绑定到单个模型类型，可以使用静态查询方法创建
         它们也可以通过将模型类型传递给数据库对象上的查询方法来创建
         */
        //创建查询构建器
        let queryBuilder = demouser.query(on: req.db)
        
        /**
         All
         all() 方法返回一个模型数组
         all 方法还支持仅从结果集中获取单个字段
         */
        _ = queryBuilder.all(\.$name)
        
        /**
         First
         first() 方法返回一个单一的、可选的模型
         如果查询产生多个模型，则只返回第一个
         如果查询没有结果，则返回 nil
         此方法可以与 unwrap(or:) 结合使用以返回非可选模型或抛出错误
         */
        _ = queryBuilder.first()
        
        /**
         过滤器(Filter)
         filter 方法允许过滤结果集中包含的模型。 此方法有多个重载
         */
        
        /**
         值过滤(Value Filter)
         接受带有值的运算符表达式 ==, !=, >=, >, <, <=
         这些运算符表达式接受左侧的字段键路径和右侧的值
         提供的值必须与字段的预期值类型匹配并绑定到结果查询
         */
        _ = queryBuilder.filter(\.$age == 24).first()
        
        /**
         字段过滤(Field Filter)
         支持比较两个字段
         字段过滤器支持与值过滤器相同的运算符
         */
//        queryBuilder.filter(\.$createdAt == \.$updatedAt)
        
        /**
         子级过滤器(Subset Filter)
         支持检查一个字段的值是否存在于给定的一组值中
         提供的值集可以是任何 Swift 集合，其元素类型与字段的值类型匹配
         ~~ 集合中存在该值 !~ 集合中不存在该值
         */
        _ = queryBuilder.filter(\.$name ~~ ["abc", "xxx"]).all()
        
        /**
         包含过滤器(Contains Filter)
         支持检查字符串字段的值是否包含给定的子字符串
         ~~包含子串 !~ 不包含子串 =~ 前缀匹配 !=~ 不匹配前缀 ~= 后缀匹配 !~= 不后缀匹配
         */
        _ = queryBuilder.filter(\.$name =~ "x").all()
        
        /**
         Group
         默认情况下，添加到查询的所有过滤器都需要匹配。
         查询构建器支持创建一组过滤器，其中只有一个过滤器必须匹配
         group 方法支持按 and 或 or 逻辑组合过滤器 这些组可以无限嵌套
         顶级过滤器可以被认为是在一个 and 组中
         */
        queryBuilder.group(.or){ group in
            group.filter(\.$name == "xxx").filter(\.$name == "aa")
        }
        
        /**
         Aggregate
         查询构建器支持多种方法来对一组值执行计算，例如计数或平均
         除了 count 之外的所有aggregate方法都需要传递一个字段的关键路径。
         count结果数 sum结果值的总和 average结果值的平均值 min最小结果 max最大结果值
         除了 count 之外的所有Aggregate方法都返回字段的值类型作为结果。 count 总是返回一个整数
         */
        _ = queryBuilder.min(\.$name)
        
        /**
         Chunk
         查询构建器支持将结果集作为单独的块返回
         这有助于您在处理大型数据库读取时控制内存使用
         根据结果的总数，提供的闭包将被调用零次或多次
         返回的每个项目都是一个 Result 其中包含模型或返回的尝试解码数据库条目的错误
         */
        _ = queryBuilder.chunk(max: 64) { result in
            
        }
        
        /**
         Field
         默认情况下，模型的所有字段都将通过查询从数据库中读取
         您可以选择使用 field 方法仅选择模型字段的子集
         查询期间未选择的任何模型字段都将处于未初始化状态
         尝试直接访问未初始化的字段将导致致命错误
         要检查模型的字段值是否已设置，请使用 value 属性
         ```
         if let name = demouser.$name.value {
             // Name was fetched.
         } else {
             // Name was not fetched.
             // Accessing `planet.name` will fail.
         }
         ```
         */
        _ = queryBuilder.field(\.$name).field(\.$id).all()
        
        /**
         Unique
         查询构建器的Unique方法仅导致返回不同的结果（无重复）
         unique 在使用 all 获取单个字段时特别有用
         但是，您也可以使用字段方法选择多个字段
         由于模型标识符始终是唯一的，因此在使用 unique 时应避免选择它们
         */
        _ = queryBuilder.unique().all(\.$name)
        
        /**
         Range
         查询构建器的range方法允许您使用 Swift range选择结果的子集
         range值是从零开始的无符号整数
         */
        _ = queryBuilder.range(..<5)
        
        /**
         Join
         查询构建器的 join 方法允许您在结果集中包含另一个模型的字段
         可以将多个模型加入您的查询
         ```
         // Fetches all planets with a star named Sun.
         Planet.query(on: database)
             .join(Star.self, on: \Planet.$star.$id == \Star.$id)
             .filter(Star.self, \.$name == "Sun")
             .all()
         ```
         on 参数接受两个字段之间的相等表达式
         其中一个字段必须已存在于当前结果集中
         另一个字段必须存在于要连接的模型上
         这些字段必须具有相同的值类型
         
         大多数查询构建器方法，如过滤器和排序，都支持连接模型
         如果方法支持连接模型，它将接受连接模型类型作为第一个参数
         ```
         .sort(Star.self, \.$name)
         ```
         使用连接的查询仍将返回基本模型的数组。 要访问联接模型，请使用joined方法。
         let star = try planet.joined(Star.self)
         */
        
        
        let users =  demouser.query(on: req.db).all()
        return users
    }
    
    /// 更新用户
    /// - Parameter req: 请求体
    /// - Returns: <#description#>
    func updateUser(req: Request) throws -> EventLoopFuture<demouser>{
        /**
         查询构建器支持使用 update 方法一次更新多个模型
         update 支持 set、filter 和 range 方法
         */
        var newuser: demouser
        newuser = try req.content.decode(demouser.self)
        let queryBuilder = demouser.query(on: req.db)
        return queryBuilder.filter(\.$name == newuser.name).set(\.$age, to: newuser.age).set(\.$email, to: newuser.email).update().map { () -> (demouser) in
            newuser
        }
    }
    
    func deleteUser(req: Request) throws -> EventLoopFuture<demouser> {
        /**
         查询构建器支持使用 delete 方法一次删除多个模型
         delete 支持过滤方法
         */
        var deleteuser: demouser
        deleteuser = try req.content.decode(demouser.self)
        let queryBuilder = demouser.query(on: req.db)
        return queryBuilder.filter(\.$name == deleteuser.name).delete().map{() -> demouser in
            deleteuser
        }
    }
    /**
     Paginate 分页
     Fluent 的查询 API 支持使用 paginate 方法自动对结果进行分页
     ```
     // Example of request-based pagination.
     app.get("planets") { req in
         try await Planet.query(on: req.db).paginate(for: req)
     }
     ```
     paginate(for:) 方法将使用请求 URI 中可用的 page 和 per 参数来返回所需的结果集
     metadata中包含有关当前页面和结果总数的元数据
     上述请求将产生如下结构的响应
     ```
     {
         "items": [...],
         "metadata": {
             "page": 2,
             "per": 5,
             "total": 8
         }
     }
     ```
     页码从 1 开始。您也可以进行手动页面请求
     // Example of manual pagination.
     .paginate(PageRequest(page: 1, per: 2))
     */
}
