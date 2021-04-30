//
//  File.swift
//  
//
//  Created by CaiGou on 2021/4/30.
//

import Foundation
import Vapor

//自定义环境变量

extension Environment {
    public static var staging: Environment {
        .custom(name: "staging")
    }
}
