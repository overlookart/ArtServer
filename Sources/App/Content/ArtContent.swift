//
//  File.swift
//  
//
//  Created by CaiGou on 2021/4/22.
//

import Foundation
import Vapor
/**
 内容(Content)
 Vapor的内容API允许您轻松地将可编码/解码可编码结构到/从HTTP消息。默认情况下，JSON编码与开箱即用支持URL编码表单和多部分一起使用。API也是可配置的，允许您添加、修改或替换某些HTTP内容类型的编码策略。
 
 概览(Overview)
 要了解Vapor的内容API是如何工作的，您应该首先了解一些关于HTTP消息的基本知识。看一下下面的示例请求。
 ```
 POST /greeting HTTP/1.1
 content-type: application/json
 content-length: 18

 {"hello": "world"}
 ```
 
 此请求表明它使用内容类型标头和application / json媒体类型包含JSON编码的数据。 如承诺的那样，一些JSON数据紧随正文中的标头之后。
 
 内容结构(Content Struct)
 解码此HTTP消息的第一步是创建一个与预期结构匹配的可编码类型。
 ```
 struct Greeting: Content {
     var hello: String
 }
 ```
 将类型与Content一致将自动增加对Codable的一致性，以及用于处理Content API的其他实用程序。
 一旦您拥有了内容结构，您可以使用req.content从传入的请求中解码它。
 ```
 app.post("greeting") { req in
     let greeting = try req.content.decode(Greeting.self)
     print(greeting.hello) // "world"
     return HTTPStatus.ok
 }
 ```
 解码方法使用请求的内容类型来找到合适的解码器。如果找不到解码器，或者请求中不包含内容类型标头，则会抛出415错误。
 这意味着此路由自动接受所有其他受支持的内容类型，例如网址编码的表单：
 ```
 POST /greeting HTTP/1.1
 content-type: application/x-www-form-urlencoded
 content-length: 11

 hello=world
 ```
 
 在文件上传的情况下，您的内容属性必须是类型Data
 ```
 struct Profile: Content {
     var name: String
     var email: String
     var image: Data
 }
 ```
 
 支持的媒体类型
 name                header value                          media type
 JSON                application/json                      .json
 Multipart           multipart/form-data                   .formData
 URL-Encoded Form    application/x-www-form-urlencoded     .urlEncodedForm
 Plaintext           text/plain                            .plainText
 HTML                text/html                             .html
 
 
 并非所有媒体类型都支持所有可编码功能。 例如，JSON不支持top-level fragments，而Plaintext不支持嵌套数据。
 
 查询(Query)
 Vapor的内容API支持处理URL查询字符串中的URL编码数据。
 
 解码(Decoding)
 要了解解码URL查询字符串的工作原理，请查看以下示例请求。
 ```
 GET /hello?name=Vapor HTTP/1.1
 content-length: 0
 ```
 就像处理HTTP消息主体内容的API一样，解析URL查询字符串的第一步是创建一个与预期结构匹配的结构。
 
 ```
 struct Hello: Content {
     var name: String?
 }
 ```
 
 请注意，name是可选的字符串，因为URL查询字符串应始终是可选的。 如果您需要一个参数，请改用route参数。
 现在，您已经为该路由的预期查询字符串提供了Content结构，可以对其进行解码。
 ```
 app.get("hello") { req -> String in
     let hello = try req.query.decode(Hello.self)
     return "Hello, \(hello.name ?? "Anonymous")"
 }
 ```
 根据上面提出的示例请求，这条路线将产生以下响应：
 ```
 HTTP/1.1 200 OK
 content-length: 12

 Hello, Vapor
 ```
 
 如果像下面的请求一样省略查询字符串，将使用“匿名”的名称。
 ```
 GET /hello HTTP/1.1
 content-length: 0
 ```
 
 单值(Single Value)
 除了解码为Content结构之外，Vapor还支持使用下标从查询字符串中获取单个值。
 ```
 let name: String? = req.query["name"]
 ```
 
 挂钩(Hooks)
 Vapor会自动对Content类型调用beforeDecode和afterDecode。 提供了默认的实现，它们什么也不做，但是您可以使用这些方法来运行自定义逻辑
 ```
 // Runs after this Content is decoded. `mutating` is only required for structs, not classes.
 mutating func afterDecode() throws {
     // Name may not be passed in, but if it is, then it can't be an empty string.
     self.name = self.name?.trimmingCharacters(in: .whitespacesAndNewlines)
     if let name = self.name, name.isEmpty {
         throw Abort(.badRequest, reason: "Name must not be empty.")
     }
 }

 // Runs before this Content is encoded. `mutating` is only required for structs, not classes.
 mutating func beforeEncode() throws {
     // Have to *always* pass a name back, and it can't be an empty string.
     guard
         let name = self.name?.trimmingCharacters(in: .whitespacesAndNewlines),
         !name.isEmpty
     else {
         throw Abort(.badRequest, reason: "Name must not be empty.")
     }
     self.name = name
 }
 ```
 覆盖默认值
 可以配置Vapor的内容API使用的默认编码器和解码器
 
 全球(Global)
 ContentConfiguration.global
 允许您更改默认使用的编码器和解码器。这对于改变整个应用程序解析和序列化数据的方式非常有用
 ```
 // create a new JSON encoder that uses unix-timestamp dates
 let encoder = JSONEncoder()
 encoder.dateEncodingStrategy = .secondsSince1970

 // override the global encoder used for the `.json` media type
 ContentConfiguration.global.use(encoder: encoder, for: .json)
 ```
 更改ContentConfiguration通常在configure.swift中完成。
 
 一次性(One-Off)
 对诸如req.content.decode之类的编码和解码方法的调用支持传入自定义编码器以供一次性使用。
 ```
 // create a new JSON decoder that uses unix-timestamp dates
 let decoder = JSONDecoder()
 decoder.dateDecodingStrategy = .secondsSince1970

 // decodes Hello struct using custom decoder
 let hello = try req.content.decode(Hello.self, using: decoder)
 ```
 
 定制编码器(Custom Coders)
 应用程序和第三方程序包可以通过创建自定义编码器来添加对Vapor默认不支持的媒体类型的支持。
 
 Content
 Vapor为能够处理HTTP消息主体内容的编码器指定了两种协议：ContentDecoder和ContentEncoder。
 ```
 public protocol ContentEncoder {
     func encode<E>(_ encodable: E, to body: inout ByteBuffer, headers: inout HTTPHeaders) throws
         where E: Encodable
 }

 public protocol ContentDecoder {
     func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPHeaders) throws -> D
         where D: Decodable
 }
 ```
 符合这些协议允许您的自定义编码器如上所述注册到ContentConfiguration。
 
 URL查询
 Vapor为能够处理URL查询字符串内容的编码器指定了两个协议：URLQueryDecoder和URLQueryEncoder
 ```
 public protocol URLQueryDecoder {
     func decode<D>(_ decodable: D.Type, from url: URI) throws -> D
         where D: Decodable
 }

 public protocol URLQueryEncoder {
     func encode<E>(_ encodable: E, to url: inout URI) throws
         where E: Encodable
 }
 ```
 符合这些协议允许您的自定义编码器注册到ContentConfiguration，以便使用use(urlEncoder:)和use(urlDecoder:)方法处理URL查询字符串。
 
 自定义 ResponseEncodable
 另一种方法涉及在您的类型上实现ResponseEncodable。 考虑一下这种简单的HTML包装器类型：
 ```
 struct HTML {
   let value: String
 }
 ```
 然后其ResponseEncodable实现将如下所示：
 ```
 extension HTML: ResponseEncodable {
   public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
     var headers = HTTPHeaders()
     headers.add(name: .contentType, value: "text/html")
     return request.eventLoop.makeSucceededFuture(.init(
       status: .ok, headers: headers, body: .init(string: value)
     ))
   }
 }
 ```
 
 请注意，这允许自定义Content-Type标头。 有关更多详细信息，请参见HTTPHeaders参考。
 然后，您可以在路由中使用HTML作为响应类型：
 ```
 app.get { _ in
   HTML(value: """
   <html>
     <body>
       <h1>Hello, World!</h1>
     </body>
   </html>
   """)
 }
 ```
 
 */



struct ArtContent: Content {
    var name: String
}







/**
 Client http 调用外部资源
 Vapor的客户端API允许您对外部资源进行HTTP调用。 它基于async-http-client构建，并与内容API集成。
 *Overview*
 您可以通过应用程序或通过请求在路由处理程序中访问默认客户端。
 ```
 app.client // Client
 app.get("test") { req in
     req.client // Client
 }
 ```
 应用程序的客户端对于在配置期间发出HTTP请求很有用。 如果要在路由处理程序中发出HTTP请求，请始终使用请求的客户端。
 
 Methods
 要发出GET请求，请将所需的URL传递给get便捷方法。
 ```
 req.client.get("https://httpbin.org/status/200").map { res in
     // Handle the response.
 }
 ```
 
 每个HTTP动词都有一些方法，例如get，post和delete。 客户端的响应将在将来返回，并包含HTTP状态，标头和正文。
 
 Content
 Vapor的内容API可用于处理客户请求和响应中的数据。 要将内容或查询参数编码为请求，请使用beforeSend闭包。
 ```
 req.client.post("https://httpbin.org/status/200") { req in
     // Encode query string to the request URL.
     try req.query.encode(["q": "test"])

     // Encode JSON to the request body.
     try req.content.encode(["hello": "world"])
 }.map { res in
     // Handle the response.
 }
 ```
 要从响应中解码内容，请在客户端的响应未来使用flatMapThrowing。
 ```
 req.client.get("https://httpbin.org/json").flatMapThrowing { res in
     try res.content.decode(MyJSONResponse.self)
 }.map { json in
     // Handle the json response.
 }
 ```
 
 配置
 您可以通过应用程序配置底层HTTP客户端。
 ```
 // Disable automatic redirect following.
 app.http.client.configuration.redirectConfiguration = .disallow
 ```
 请注意，在首次使用默认客户端之前，您必须配置它。
 */


/**
 验证(Validation)
 Vapor的验证API帮助您在使用Content API解码数据之前验证传入的请求。

 介绍
 Vapor对Swift的类型安全Codable协议的深度集成意味着与动态类型语言相比，您不需要担心数据验证。然而，您可能希望选择使用验证API进行显式验证，这仍然有几个原因。

 人类可读错误
 如果任何数据无效，使用Content API的解码结构将产生错误。然而，这些错误消息有时可能缺乏人类可读性。比如取下面的字符串支持枚举：
```
 enum Color: String, Codable {
     case red, blue, green
 }
 ```
 如果用户尝试将字符串“ purple”传递给Color类型的属性，则他们将收到类似于以下内容的错误：
 ```
 Cannot initialize Color from invalid String value purple for key favoriteColor
 ```
 虽然此错误在技术上是正确的，并成功保护端点免受无效值的影响，但它可以更好地告知用户错误以及哪些选项可用。通过使用验证API，您可以生成以下错误
 ```
 favoriteColor is not red, blue, or green
 ```
 此外，一旦遇到第一个错误，Codable将停止尝试解码类型。这意味着，即使请求中存在许多无效属性，用户也只会看到第一个错误。验证API将报告单个请求中的所有验证失败。
 
 具体验证
 Codable处理好类型验证，但有时您想要的更多。例如，验证字符串的内容或验证整数的大小。验证API具有用于帮助验证电子邮件、字符集、整数范围等数据的有效性。
 
 可验证的
 要验证请求，您将需要生成一个Validations集合。 这通常是通过使现有类型符合Validatable来完成的。
 让我们看一下如何向这个简单的POST / users端点添加验证。 本指南假定您已经熟悉Content API。
 ```
 enum Color: String, Codable {
     case red, blue, green
 }

 struct CreateUser: Content {
     var name: String
     var username: String
     var age: Int
     var email: String
     var favoriteColor: Color?
 }

 app.post("users") { req -> CreateUser in
     let user = try req.content.decode(CreateUser.self)
     // Do something with user.
     return user
 }
 ```
 
 添加验证
 第一步是使解码的类型（此处为CreateUser）保持一致。这可以在扩展中完成。
```
 extension CreateUser: Validatable {
     static func validations(_ validations: inout Validations) {
         // Validations go here.
     }
 }
 ```
 验证CreateUser时将调用静态方法validates（_ :)。 您要执行的所有验证都应添加到提供的Validation集合中。 让我们看一下添加一个简单的验证，以要求用户的电子邮件有效。
 ```
 validations.add("email", as: String.self, is: .email)
 ```
 第一个参数是值的预期键，在本例中为“电子邮件”。 这应与正在验证的类型上的属性名称匹配。 第二个参数as是期望的类型，在这种情况下为String。 该类型通常与属性的类型匹配，但并不总是匹配。 最后，可以在第三个参数is之后添加一个或多个验证器。 在这种情况下，我们将添加一个验证器，以检查该值是否为电子邮件地址。
 
 
 验证请求内容
 将类型符合Validatable之后，可以使用静态validate（content :)函数来验证请求内容。 在路由处理程序中的req.content.decode（CreateUser.self）之前添加以下行。
 ```
 try CreateUser.validate(content: req)
 ```
 现在，尝试发送包含无效电子邮件的以下请求：
```
 POST /users HTTP/1.1
 Content-Length: 67
 Content-Type: application/json

 {
     "age": 4,
     "email": "foo",
     "favoriteColor": "green",
     "name": "Foo",
     "username": "foo"
 }
 ```
 您应该看到返回的以下错误：
 email is not a valid email address
 
 验证请求查询
 符合Validatable的类型也具有validate（query :)，可用于验证请求的查询字符串。 将以下行添加到路由处理程序。
```
 try CreateUser.validate(query: req)
 req.query.decode(CreateUser.self)
```
 现在，尝试发送以下请求，其中包含查询字符串中的无效电子邮件
 GET /users?age=4&email=foo&favoriteColor=green&name=Foo&username=foo
 您应该看到返回的以下错误：
 ```
 email is not a valid email address
 ```
 
 整数验证
 现在让我们尝试添加年龄验证。
 ```
 validations.add("age", as: Int.self, is: .range(13...))
 ```
 年龄验证要求年龄大于等于13。如果您尝试了来自上面的相同请求，您现在应该会看到一个新错误：
 age is less than minimum of 13, email is not a valid email address
 
 
 字符串验证
 接下来添加名称的验证。
 ```
 validations.add("name", as: String.self, is: !.empty)
 validations.add("username", as: String.self, is: .count(3...) && .alphanumeric)
 ```
 名称验证使用！ 运算符以反转.empty验证。 这将要求该字符串不为空
 用户名验证使用&&组合了两个验证器。 这将要求该字符串的长度至少为3个字符，并且仅包含字母数字字符
 
 枚举验证
 最后，让我们看一下稍微高级的验证，以检查所提供的favoriteColor是否有效。
 ```
 validations.add(
     "favoriteColor", as: String.self,
     is: .in("red", "blue", "green"),
     required: false
 )
 ```
 由于无法从无效值解码Color，因此此验证将String作为基本类型。 它使用.in验证程序来验证该值是一个有效选项：红色，蓝色或绿色。 由于此值是可选的，因此required设置为false表示如果请求数据中缺少此密钥，则验证不会失败。

 请注意，虽然缺少键会通过收藏夹颜色验证，但是如果提供null则不会通过。 如果要支持null，请将验证类型更改为String？ 并使用.nil || （读作：“是nil或...”）
 
 ```
 validations.add(
     "favoriteColor", as: String?.self,
     is: .nil || .in("red", "blue", "green"),
     required: false
 )
 ```
 验证器
 验证                 描述
 .ascii              仅包含ASCII字符。
 .alphanumeric       仅包含字母数字字符。
 .characterSet(_:)   仅包含提供的CharacterSet中的字符
 .count(_:)          集合的计数在提供的范围内
 .email              包含一封有效的电子邮件。
 .empty              集合为空
 .in(_:)             Value is in supplied Collection.
 .nil                Value is null.
 .range(_:)          值在提供的范围内
 .url                包含一个有效的URL。
 
 验证器也可以结合起来，以使用运算符构建复杂的验证
 Operator    Position    Description
 !           prefix      反转验证器，需要相反的验证器
 &&          infix       结合两个验证器，需要两者
 ||          infix       组合两个验证器，需要一个
 */


struct ArtUser: Content {
    var name: String
    var age: String
    var email: String
    var phone: String
}
extension ArtUser: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("age", as: Int.self, is: .range(13...))
        validations.add("name", as: String.self, is: !.empty)
    }
}


/**
 异步(Async)
 您可能已经注意到Vapor中的某些API期望或返回通用的EventLoopFuture类型。 如果这是您第一次了解futures，那么一开始它们似乎有点令人困惑。 但请放心，本指南将向您展示如何利用其强大的API。

 Promises和futures是相关的但截然不同的类型。 Promises用于创建futures。 在大多数情况下，您将使用Vapor API返回的futures，而不必担心创建Promises。您可能已经注意到Vapor中的某些APIfutures或返回通用EventLoopFuture类型。 如果这是您第一次了解futures，那么一开始它们似乎有些混乱。 但是请放心，本指南将向您展示如何利用其强大的API。

 大多数时候，您将使用Vapor API返回的futures，而无需担心创建Promises。
 ```
 type             description              mutability
 EventLoopFuture  引用可能尚不可用的值         read-only
 EventLoopPromise 异步提供一些价值的futures    read/write
 ```
 futures是基于回调的异步API的替代方法。 可以通过简单的关闭无法实现的方式来链接和转换futures。
 
 转化(Transforming)
 就像Swift中的可选和数组一样，Future可以被映射和映射。 这些是您将对Future执行的最常见的操作。
 ```
 method             argument                    description
 map                (T) -> U                    将Future值映射到其他值。
 flatMapThrowing    (T) throws -> U             将Future值映射到其他值或错误。
 flatMap            (T) -> EventLoopFuture<U>   将Future值映射到不同的Future值。
 transform          U                           将Future映射到已经可用的值。
 ```
 如果在Optional <T>和Array <T>上查看map和flatMap的方法签名，您会发现它们与EventLoopFuture <T>上可用的方法非常相似
 
 映射(map)
 map方法使您可以将Future值转换为另一个值。 因为Future值可能尚不可用（可能是异步任务的结果），所以我们必须提供一个闭包以接受该值。
 ```
 /// Assume we get a future string back from some API
 let futureString: EventLoopFuture<String> = ...

 /// Map the future string to an integer
 let futureInt = futureString.map { string in
     print(string) // The actual String
     return Int(string) ?? 0
 }

 /// We now have a future integer
 print(futureInt) // EventLoopFuture<Int>
 ```
 

 flatMapThrowing
 flatMapThrowing方法使您可以将future值转换为另一个值或引发错误。
 因为抛出错误必须在内部创建一个新的Future，所以即使闭包不接受Future的返回值，此方法的前缀也为flatMap。
 ```
 /// Assume we get a future string back from some API
 let futureString: EventLoopFuture<String> = ...

 /// Map the future string to an integer
 let futureInt = futureString.flatMapThrowing { string in
     print(string) // The actual String
     // Convert the string to an integer or throw an error
     guard let int = Int(string) else {
         throw Abort(...)
     }
     return int
 }

 /// We now have a future integer
 print(futureInt) // EventLoopFuture<Int>
 ```
 
 flatMap
 flatMap方法允许您将future值转换为另一个future值。 因为它可以避免创建嵌套的future（例如EventLoopFuture <EventLoopFuture <T >>），所以它被称为“flat”map。 换句话说，它可以帮助您保持泛型不变。
 ```
 /// Assume we get a future string back from some API
 let futureString: EventLoopFuture<String> = ...

 /// Assume we have created an HTTP client
 let client: Client = ...

 /// flatMap the future string to a future response
 let futureResponse = futureString.flatMap { string in
     client.get(string) // EventLoopFuture<ClientResponse>
 }

 /// We now have a future response
 print(futureResponse) // EventLoopFuture<ClientResponse>
 ```
 如果我们在上面的示例中使用map，则最终将得到：EventLoopFuture <EventLoopFuture <ClientResponse >>
 
 要在flatMap内部调用throwing方法，请使用Swift的do / catch关键字并创建完整的Future
 ```
 /// Assume future string and client from previous example.
 let futureResponse = futureString.flatMap { string in
     let url: URL
     do {
         // Some synchronous throwing method.
         url = try convertToURL(string)
     } catch {
         // Use event loop to make pre-completed future.
         return eventLoop.makeFailedFuture(error)
     }
     return client.get(url) // EventLoopFuture<ClientResponse>
 }
 ```
 
 transform
 transform方法允许您修改future值，而忽略现有值。 这对于转换EventLoopFuture <Void>的结果特别有用，而future的实际值并不重要。
 EventLoopFuture <Void>，有时也称为信号，是一个future，其唯一目的是将某些异步操作的完成或失败通知您
 ```
 /// Assume we get a void future back from some API
 let userDidSave: EventLoopFuture<Void> = ...

 /// Transform the void future to an HTTP status
 let futureStatus = userDidSave.transform(to: HTTPStatus.ok)
 print(futureStatus) // EventLoopFuture<HTTPStatus>
 ```
 即使我们提供了一个已经可用的值来进行转换，但这仍然是一个转换。 直到所有先前的future都已完成（或失败）后，future才会完成。
 
 链式(Chaining)
 future转换的很大一部分是可以链接在一起的。 这使您可以轻松表达许多转换和子任务。
 让我们从上面修改示例，以了解如何利用Chaining
 ```
 /// Assume we get a future string back from some API
 let futureString: EventLoopFuture<String> = ...

 /// Assume we have created an HTTP client
 let client: Client = ...

 /// Transform the string to a url, then to a response
 let futureResponse = futureString.flatMapThrowing { string in
     guard let url = URL(string: string) else {
         throw Abort(.badRequest, reason: "Invalid URL string: \(string)")
     }
     return url
 }.flatMap { url in
     client.get(url)
 }

 print(futureResponse) // EventLoopFuture<ClientResponse>
 ```
 首次调用map之后，将创建一个临时的EventLoopFuture <URL>。 然后立即将此将来映射到EventLoopFuture <Response>
 
 
 Future
 让我们看一下使用EventLoopFuture <T>的其他方法。
 makeFuture
 您可以使用事件循环使用值或错误创建预完成的future。
 ```
 // Create a pre-succeeded future.
 let futureString: EventLoopFuture<String> = eventLoop.makeSucceededFuture("hello")

 // Create a pre-failed future.
 let futureString: EventLoopFuture<String> = eventLoop.makeFailedFuture(error)
 ```
 
 whenComplete
 您可以使用whenComplete添加将在将来成功或失败时执行的回调
 ```
 /// Assume we get a future string back from some API
 let futureString: EventLoopFuture<String> = ...

 futureString.whenComplete { result in
     switch result {
     case .success(let string):
         print(string) // The actual String
     case .failure(let error):
         print(error) // A Swift Error
     }
 }
 ```
 您可以根据需要向将来添加尽可能多的回调。
 
 */
