//
//  File.swift
//  
//
//  Created by xzh on 2021/4/24.
//

import Foundation
import Vapor
struct DemoUser: Content {
    var name: String
    var age: Int
    var email: String
    
    // 此内容编码前运行。只有 Struct 才需要 'mutating'，而 Class 则不需要。
    mutating func beforeEncode() throws {
        // 必须*总是*传递一个名称回来，它不能是一个空字符串。
        print("beforeEncode")
        let name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
                throw Abort(.badRequest, reason: "Name must not be empty.")
        }
        self.name = name
    }
    
    
    // 此内容解码后运行。只有 Struct 才需要 'mutating'，而 Class 则不需要
    mutating func afterDecode() throws {
        // 名称可能没有传入，但如果传入了，那就不能是空字符串。
        print("afterDecode")
        self.name = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if self.name.isEmpty {
            throw Abort(.badRequest, reason: "Name must not be empty.")
        }
    }
}

// 校验
extension DemoUser: Validatable {
    static func validations(_ validations: inout Validations) {
        //名称不能为空
        validations.add("name", as: String.self, is: !.empty)
        //年龄大于13
        validations.add("age", as: Int.self, is: .range(13...))
        //邮箱格式正确
        validations.add("email", as: String.self, is: .email)
    }
}

struct SlideShow: Content {
    var author: String
    var date: String
}

struct tJson: Content {
    var slideshow: SlideShow
}


