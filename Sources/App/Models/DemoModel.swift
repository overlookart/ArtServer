//
//  File.swift
//  
//
//  Created by CaiGou on 2021/4/30.
//

import Foundation
import Vapor
import Fluent

/**
 模型代表存储在数据库table或collection的数据。
 模型具有一个或多个存储可编码值的字段。
 所有模型都有唯一的标识符。
 属性包装器用于表示标识符，字段和关系
 */

final class demouser: Model, Content {
    //table或collection的名称
    static let schema: String = "demousers"
    //唯一标识
    @ID(key: .id)
    var id: UUID?
    
    //模型可以具有零个或多个@Field属性来存储数据
    //该数据模型 字段:名称
    //字段要求显式定义数据库key。 不需要与属性名称相同
    //Fluent建议对数据库key使用snake_case，对属性名称使用camelCase
    @Field(key: "name")
    var name: String
    
    //可选字段
    @OptionalField(key: "age")
    var age: Int?
    
    @OptionalField(key: "email")
    var email: String?
    
    //Relations 关系
    //父级
//    @Parent(key: "parent")
    //子级
//    @Children(for: T##KeyPath<_, _.Parent<DemoModel>>)
    //同级
//    @Siblings(through: T##_.Type, from: T##KeyPath<_, _.Parent<DemoModel>>, to: T##KeyPath<_, _.Parent<_>>)
    
    //@Timestamp是@Field的一种特殊类型，用于存储Foundation.Date。 Fluent会根据所选触发器自动设置时间戳。
    //创建时的时间
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    //更新时的时间
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    //删除时的时间 软删除 soft delete 时间戳格式 /.default /.iso8601 /.unix
    @Timestamp(key: "deleted_at", on: .delete)
    var deleteAt: Date?
    
    
    
    
    //初始化
    init() {
        
    }
    
    init(id: UUID? = nil, name: String, age: Int? = 0, email: String? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.email = email
    }
}

/**
 //数据库报错
 connection reset (error set): Connection refused (errno: 61)
 https://stackoverflow.com/questions/55205247/vapor-connection-refused-errno-61
 未安装数据库
 安装数据库
 brew install postgresql
 启动数据库服务
 brew services start postgres
 */
