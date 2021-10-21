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
    /**
     数据表名称: table或collection的名称
     所有模型必须有一个静态常量schema 标识数据表或集合的名称
     查询该模型时从 schema 为名称的数据表获取数据
     schema 的命名规范: 通常是复数形式和小写形式的类名称
     */
    static let schema: String = "demousers"
    
    /**
     唯一标识(Identifier)
     所有的模型必须具有使用@ID属性包装定义的id属性，此字段唯一标识模型的实例
     @ID应该是UUID类型，数据库驱动支持的唯一标识符值类型
     创建模型时 Fluent 将自动生成新的 UUID 标识符
     @ID 有一个可选值，因为未保存的模型可能还没有标识符。 要获取标识符或抛出错误，请使用 requireID。
     
     唯一标识是否存在(Exists)
     @ID 有一个exists 属性，表示模型是否存在于数据库中
     初始化模型时该值为 false,保存模型后或从数据库中获取模型时该值为 true
     此属性是可变的
     */
    @ID(key: .id)
    var id: UUID?
    
    /**
     自定义唯一标识(Custom Identifier)
     Fluent 支持使用 @ID(custom:) 重载的自定义标识符键和类型
     自定义@ID 允许用户使用generatedBy 参数指定应如何生成标识符
     如果省略了generatedBy 参数，Fluent 将尝试根据@ID 值类型推断适当的情况。
     例如，除非另有说明，否则 Int 将默认为 .database 生成
     */
//    @ID(custom: "iid", generatedBy: .user)
//    var iid: Int?
    
    
    //该数据模型 字段:名称
    /**
     Field
     模型可以具有零个或多个@Field属性来存储数据
     字段要求显式定义数据库键。 不需要与属性名称相同
     Fluent建议对数据库key使用snake_case，对属性名称使用camelCase
     字段值可以是符合 Codable 的任何类型
     支持在@Field中存储嵌套结构和数组，但过滤操作是有限
     */
    @Field(key: "name") //字段名
    var name: String    //属性名
    
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
    
    /**
     Timestamp
     @Timestamp是@Field的一种特殊类型，用于存储Foundation.Date
     Fluent会根据所选触发器自动设置时间戳
     
     时间戳
     默认情况下，@Timestamp 将根据您的数据库驱动程序使用有效的日期时间编码
     也可以使用 format 参数自定义时间戳在数据库中的存储方式
     时间戳格式 /.default:Data /.iso8601:String /.unix:Double
     可以使用timestamp属性直接访问原始时间戳值
     
     软删除(Soft-delete)
     将使用 .delete 触发器的 @Timestamp 添加到您的模型将启用软删除。
     软删除的模型在删除后仍然存在于数据库中，但不会在查询中返回
     可以手动将删除时间戳设置为将来的日期。 这可以用作到期日期
     要强制从数据库中删除可软删除的模型，请在 delete 中使用 force 参数
     要恢复软删除的模型，请使用restore方法
     要在查询中包含软删除的模型，请使用 withDeleted
     */
    //创建时的时间
    @Timestamp(key: "created_at", on: .create, format: .default)
    var createdAt: Date?
    //更新时的时间
    @Timestamp(key: "updated_at", on: .update, format: .default)
    var updatedAt: Date?
    //删除时的时间 软删除 soft delete
    @Timestamp(key: "deleted_at", on: .delete, format: .default)
    var deleteAt: Date?
    
    
    
    //初始化 创建空实体
    init() {
        
    }
    
    /// 自定义初始化方法
    /// - Parameters:
    ///   - id: 唯一标识
    ///   - name: 姓名
    ///   - age: 年龄
    ///   - email: 邮箱
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
