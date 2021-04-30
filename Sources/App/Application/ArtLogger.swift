//
//  File.swift
//  
//
//  Created by CaiGou on 2021/4/30.
//

import Foundation
import Vapor
/*
LoggingSystem.bootstrap { (label) -> LogHandler in
    StreamLogHandler.standardOutput(label: label)
}*/
class ArtLogger {
    class func artLogger() -> Logger {
        let log = Logger(label: "art")
        return log
    }
}

