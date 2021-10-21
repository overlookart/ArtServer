//
//  File.swift
//  
//
//  Created by CaiGou on 2021/10/21.
//

import Foundation
import Vapor
import Fluent

/// 用户相关的路由集合
struct UserController: RouteCollection{
    
    /// 注册路由
    /// - Parameter routes: <#routes description#>
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("user");
    }
    
    
}

extension UserController {
//    func registerUserHandler(_ req: Request) throws -> EventLoopFuture {
//        
//    }
}
