import Fluent

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos")
            .id()
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}

struct CreateDemouser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        ///准备用于存储demousers模型的数据库
        print("创建 demousers 表")
        return database.schema("demousers").id()
            .field("name", .string)
            .updateField("age", .int8)
            .field("email", .string)
            .field("created_at", .date)
            .field("updated_at", .date)
            .create()
        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("demousers").delete()
    }
}

struct UpdateDemouser_V3: Migration{
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        print("更新 demousers ")
        return database.schema("demousers")
            .field("deleted_at", .date)
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("demousers")
            .deleteField("deleted_at")
            .update()
    }
    
    
}
