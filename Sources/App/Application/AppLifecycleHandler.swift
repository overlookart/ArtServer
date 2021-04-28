//
//  File.swift
//  
//
//  Created by xzh on 2021/4/28.
//

import Foundation
import Vapor
class AppLifecycleHandler: LifecycleHandler {
    func willBoot(_ application: Application) throws {
        print("app-----将要启动")
    }
    
    func didBoot(_ application: Application) throws {
        print("app-----已经启动")
    }
    
    func shutdown(_ application: Application) {
        print("app-----关机")
    }
}
