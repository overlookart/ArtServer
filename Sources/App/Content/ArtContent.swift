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
 
 查询
 Vapor的内容API支持处理URL查询字符串中的URL编码数据。
 
 解码
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
 
 */


struct ArtContent: Content {
    var name: String
}
