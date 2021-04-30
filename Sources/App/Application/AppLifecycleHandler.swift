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
        application.logger.info("app lifecycle --------- 将要启动")
    }
    
    func didBoot(_ application: Application) throws {
        application.logger.info("app lifecycle --------- 已经启动")
    }
    
    func shutdown(_ application: Application) {
        application.logger.info("app lifecycle --------- 关机")
    }
}
