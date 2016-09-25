//
//  OMLog.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 25/9/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import Foundation

// Based on : https://github.com/kostiakoval/SpeedLog


///LogLevel type. Specify what level of details should be included to the log
public struct LogLevel : OptionSet {
    
    public let rawValue: UInt
    public init(rawValue: UInt)  { self.rawValue = rawValue }
    
    //MARK:- Options
    public static let Debug     = LogLevel(rawValue: 1 << 0)
    public static let Verbose   = LogLevel(rawValue: 1 << 1)
    public static let Info      = LogLevel(rawValue: 1 << 2)
    public static let Warning   = LogLevel(rawValue: 1 << 3)
    public static let Error     = LogLevel(rawValue: 1 << 4)
    
    /// AllOptions - Enable all options, [Debug, Verbose, Info, Warning, Error]
    public static let AllOptions: LogLevel = [Debug, Verbose, Info, Warning, Error]
    /// NormalOptions - Enable normal options, [Info, Warning, Error]
    public static let NormalOptions: LogLevel = [Warning, Error]
    /// DeveloperOptions - Enable normal options, [Info, Warning, Error]
    public static let DevOptions: LogLevel = [Verbose, Info, Warning, Error]
    /// QAOptions - Enable QA options, [Debug, Verbose, Info, Warning, Error]
    public static let DebugOptions: LogLevel = AllOptions
}


///SpeedLog Type
public struct OMLog {
    /// Log Mode
    public static var level: LogLevel = .DevOptions
    
    /**
     * print items to the console
     * parameter items:      items to print
     * parameter level:      log level
     */
    
    public static func printd(_ items: Any..., level:LogLevel = .Debug) {
        #if !DISABLE_LOG
            let stringItem = items.map {"\($0)"}.joined(separator: " ")
            if (OMLog.level.contains(level)) {
                Swift.print("[DEBUG] \(stringItem)", terminator: "\n")
            }
        #endif
    }
    public static func printw(_ items: Any..., level:LogLevel = .Warning) {
        #if !DISABLE_LOG
            let stringItem = items.map {"\($0)"}.joined(separator: " ")
            if (OMLog.level.contains(level)) {
                Swift.print("[WARNING] \(stringItem)", terminator: "\n")
            }
        #endif
    }
    public static func printi(_ items: Any..., level:LogLevel = .Info) {
        #if !DISABLE_LOG
            let stringItem = items.map {"\($0)"}.joined(separator: " ")
            if (OMLog.level.contains(level)) {
                Swift.print("[INFO] \(stringItem)", terminator: "\n")
            }
        #endif
    }
    public static func printe(_ items: Any..., level:LogLevel = .Error) {
        #if !DISABLE_LOG
            let stringItem = items.map {"\($0)"}.joined(separator: " ")
            if (OMLog.level.contains(level)) {
                Swift.print("[ERROR] \(stringItem)", terminator: "\n")
            }
        #endif
    }
    public static func printv(_ items: Any..., level:LogLevel = .Verbose) {
        #if !DISABLE_LOG
            let stringItem = items.map {"\($0)"}.joined(separator: " ")
            if (OMLog.level.contains(level)) {
                Swift.print("[VERBOSE] \(stringItem)", terminator: "\n")
            }
        #endif
    }
    
}
