//
//  SLog.swift
//  Pods
//
//  Created by Kostiantyn Koval on 08/07/15.
//
//

import Foundation

typealias SLog = SpeedLog


///LogMode type. Specify what details should be included to the log
public struct LogMode : OptionSet {
    
    public let rawValue: UInt
    public init(rawValue: UInt)  { self.rawValue = rawValue }
    
    //MARK:- Options
    public static let None     = LogMode(rawValue: 0)
    public static let FileName = LogMode(rawValue: 1 << 0)
    public static let FuncName = LogMode(rawValue: 1 << 1)
    public static let Line     = LogMode(rawValue: 1 << 2)
    public static let Date     = LogMode(rawValue: 1 << 3)
    
    /// AllOptions - Enable all options, [FileName, FuncName, Line]
    public static let AllOptions: LogMode = [Date, FileName, FuncName, Line]
    public static let FullCodeLocation: LogMode = [FileName, FuncName, Line]
}

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


// Log level helpers

public  func ERROR(items: Any..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    
    SLog.print(items: items, level: .Error, separator: separator, terminator: terminator)
}

public func WARNING(items: Any..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    
    SLog.print(items: items, level: .Warning, separator: separator, terminator: terminator)
}

public func INFO(items: Any..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    
    SLog.print(items: items, level: .Info, separator: separator, terminator: terminator)
}

public func VERBOSE(items: Any..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    
    SLog.print(items: items, level: .Verbose, separator: separator, terminator: terminator)
}

public  func DEBUG(items: Any..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    
    SLog.print(items: items, level: .Debug, separator: separator, terminator: terminator)
}


///SpeedLog Type
public struct SpeedLog {
    /// Log Mode
    public static var mode : LogMode = .None
    public static var level: LogLevel = .NormalOptions
    
    /**
     print items to the console
     
     - parameter items:      items to print
     - parameter level:      log level
     - parameter separator:  separator between items. Default is space" "
     - parameter terminator: a character inserted at the end of output.
     */
    
    public static func print(items: Any..., level:LogLevel = .AllOptions, separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        #if !DISABLE_LOG
            let prefix = modePrefix(date: NSDate(), file: file, function: function, line: line)
            let stringItem = items.map {"\($0)"}.joined(separator: separator)
            if (SLog.level.contains(level)) {
                Swift.print("\(prefix)\(stringItem)", terminator: terminator)
            }
        #endif
    }
}

extension SpeedLog {
    
    /// Create an output string for the currect log Mode
    static func modePrefix(date: NSDate, file: String, function: String, line: Int) -> String {
        var result: String = ""
        if mode.contains(.Date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS "
            
            let s = formatter.string(from: date as Date)
            result += s
        }
        if mode.contains(.FileName) {
            let filename = file.lastPathComponent.stringByDeletingPathExtension
            result += "\(filename)."
        }
        if mode.contains(.FuncName) {
            result += "\(function)"
        }
        if mode.contains(.Line) {
            result += "[\(line)]"
        }
        
        if !result.isEmpty {
            result = result.trimmingCharacters(in:CharacterSet.whitespaces)
            result += ": "
        }
        
        return result
    }
}

/// String syntax sugar extension
extension String {
    var ns: NSString {
        return self as NSString
    }
    var lastPathComponent: String {
        return ns.lastPathComponent
    }
    var stringByDeletingPathExtension: String {
        return ns.deletingPathExtension
    }
}
