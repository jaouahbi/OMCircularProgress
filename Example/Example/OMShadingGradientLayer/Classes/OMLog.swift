//
//    Copyright 2017 - Jorge Ouahbi
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

//
//  OMLog.swift
//
//  Created by Jorge Ouahbi on 25/9/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import Foundation

// DISABLE_LOG

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


///OMLog Type
public struct OMLog {
    /// Log Mode
    public static var level: LogLevel = .NormalOptions
    
    private static func levelName(level:LogLevel) -> String {
        switch level {
        case LogLevel.Debug:
            return "DEBUG"
        case LogLevel.Verbose:
            return "VERBOSE"
        case LogLevel.Info:
            return "INFO"
        case LogLevel.Warning:
            return "WARNING"
        case LogLevel.Error:
            return "ERROR"
        default:
            assertionFailure()
            return "UNKNOWN"
        }
    }
    
    /// print items to the console
    ///
    /// - parameter items: items to print
    /// - parameter level: log level
    
    public static func print(_ items: Any..., level:LogLevel) {
        #if !DISABLE_LOG
            let stringItem = items.map {"\($0)"}.joined(separator: " ")
            if (OMLog.level.contains(level)) {
                Swift.print("\(levelName(level: level)):\(stringItem)", terminator: "\n")
            }
        #endif
    }
    public static func printd(_ items: Any..., level:LogLevel = .Debug) {
        #if !DISABLE_LOG
            print(items,level:level);
        #endif
    }
    public static func printw(_ items: Any..., level:LogLevel = .Warning) {
        #if !DISABLE_LOG
            print(items,level:level);
        #endif
    }
    public static func printi(_ items: Any..., level:LogLevel = .Info) {
        #if !DISABLE_LOG
            print(items,level:level);
        #endif
    }
    public static func printe(_ items: Any..., level:LogLevel = .Error) {
        #if !DISABLE_LOG
            print(items,level:level);
        #endif
    }
    public static func printv(_ items: Any..., level:LogLevel = .Verbose) {
        #if !DISABLE_LOG
            print(items,level:level);
        #endif
    }
}
