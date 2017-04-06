//  JSON.swift

import Foundation

let JSONErrorDomain = "JSONErrorDomain"
//MARK:- Base
public enum JSON {
    
    case ScalarNumber(NSNumber)
    case ScalarString(String)
    // technically this should be treated as a set because the order doesn't matter.
    // This issue comes into play in the equality test below featuring arrays.
    case Sequence(Array<JSON>)
    case Mapping(Dictionary<String, JSON>)
    case Null(NSError?)
    
    public init(data:NSData, options opt: NSJSONReadingOptions = NSJSONReadingOptions.MutableContainers, error: NSErrorPointer = nil) {
        do {
            let object: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: opt)
            self = JSON(object: object)
        } catch let error1 as NSError {
            if(error != nil){
                error.memory = error1
            }
            self = .Null(nil)
        }
    }
    
    public init(string:String, options opt: NSJSONReadingOptions = NSJSONReadingOptions.MutableContainers, error: NSErrorPointer = nil) {
        self.init(data: Utils.StringToNSData(string), options: opt, error: error)
    }
    
    public init() {
        self.init(string: "{}", options: [], error: nil)
    }
    
    public init(object: AnyObject) {
        switch object {
        case let number as NSNumber:
            self = .ScalarNumber(number)
        case let string as String:
            self = .ScalarString(string)
        case _ as NSNull:
            self = .Null(nil)
        case let array as NSArray:
            var jsonArray = Array<JSON>()
            for object : AnyObject in array {
                jsonArray.append(JSON(object: object))
            }
            self = .Sequence(jsonArray)
        case let dictionary as NSDictionary:
            var jsonObject = Dictionary<String, JSON>()
            for (key, value): (AnyObject, AnyObject) in dictionary {
                if let key = key as? NSString {
                    jsonObject[key as String] = JSON(object: value)
                }
            }
            self = .Mapping(jsonObject)
        default:
            self = .Null(nil)
        }
    }
}

extension JSON {
    
    
    /// FIXME: Maybe this would be better if we used NSJSONSerialization
    /// but we need the canonical version below anyway.
    /// We actually use NSJSONSerialization.dataWithJSONObject in the code
    /// that converts our the NSDictionarys we use to send JSON encoded commands,
    /// but we haven't yet integrated that code with this code. Mainly this is because
    /// this code uses Dictionary<String, JSON> and the sending code uses NSDictionary.
    
    /// Converts this JSON object into a string representation.
    public var toString: String {
        switch self {
        case .ScalarNumber(let number):
            return number.stringValue
        case .ScalarString(let string):
            var result = "\""
            result += string
            result += "\""
            return result
        case .Sequence(let array):
            var result = "["
            var prefix = ""
            for object in array {
                result += prefix
                result += object.toString
                prefix = ","
            }
            result += "]"
            return result
        case .Mapping(let dictionary):
            let keys = Array(dictionary.keys)
            var result = "{"
            var prefix = ""
            for key in keys {
                let value = dictionary[key]
                result += prefix
                result += "\""
                result += key
                result += "\""
                result += ":"
                result += value!.toString
                prefix = ","
            }
            result += "}"
            return result
        default:
            return "\"null\""
        }
    }
    /// This spends a little more effort sorting the results so they always will be the same.
    /// Useful when we're signing JSON output.
    public var toStringCanonical: String {
        switch self {
        case .ScalarNumber(let number):
            return number.stringValue
        case .ScalarString(let string):
            var result = "\""
            result += string
            result += "\""
            return result
        case .Sequence(let array):
            var result = "["
            var prefix = ""
            for object in array {
                result += prefix
                result += object.toStringCanonical
                prefix = ","
            }
            result += "]"
            return result
        case .Mapping(let dictionary):
            let sortedKeys = Array(dictionary.keys).sort(<)
            var result = "{"
            var prefix = ""
            for key in sortedKeys {
                let value = dictionary[key]
                result += prefix
                result += "\""
                result += key
                result += "\""
                result += ":"
                result += value!.toStringCanonical
                prefix = ","
            }
            result += "}"
            return result
        default:
            return "\"null\""
            }
    }
    
}

// MARK: - Subscript
extension JSON {
    
    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case .Sequence(let array) where array.count > index:
                return array[index]
            default:
                return .Null(NSError(domain: JSONErrorDomain, code: 0, userInfo: nil))
            }
        }
    }
    
    public subscript(key: String) -> JSON {
        get {
            switch self {
            case .Mapping(let dictionary) where dictionary[key] != nil:
                return dictionary[key]!
            default:
                return .Null(NSError(domain: JSONErrorDomain, code: 0, userInfo: nil))
            }
        }
    }
}

//MARK: - Printable, DebugPrintable
extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .ScalarNumber(let number):
            return number.description
        case .ScalarString(let string):
            return string
        case .Sequence(let array):
            return array.description
        case .Mapping(let dictionary):
            return dictionary.description
        default:
            return "null"
            }
    }
    
    public var debugDescription: String {
        get {
            switch self {
            case .ScalarNumber(let number):
                return number.debugDescription
            case .ScalarString(let string):
                return string.debugDescription
            case .Sequence(let array):
                return array.debugDescription
            case .Mapping(let dictionary):
                return dictionary.debugDescription
            default:
                return "null"
            }
        }
    }
}

// MARK: - Sequence: Array<JSON>
extension JSON {
    
    public var arrayValue: Array<JSON>? {
        get {
            switch self {
            case .Sequence(let array):
                return array
            default:
                return nil
            }
        }
    }
}

// MARK: - Mapping: Dictionary<String, JSON>
extension JSON {
    
    public var dictionaryValue: Dictionary<String, JSON>? {
        get {
            switch self {
            case .Mapping(let dictionary):
                return dictionary
            default:
                return nil
            }
        }
    }
    
    public var naturalValue: AnyObject {
        get {
            switch self {
            case .ScalarNumber(let number):
                return number
            case .ScalarString(let string):
                return string
            case .Mapping(let dictionary):
                let nsDictionary = NSMutableDictionary()
                for (key, value): (String, JSON) in dictionary {
                    nsDictionary.setObject(value.naturalValue, forKey: key)
                }
                return nsDictionary
            case .Sequence(let array):
                let nsArray = NSMutableArray()
                for object in array {
                    nsArray.addObject(object.naturalValue)
                }
                return nsArray
            default:
                return NSMutableDictionary()
            }
        }
    }
}

//MARK: - Scalar: Bool
extension JSON: BooleanType {
    
    public var boolValue: Bool {
        switch self {
        case .ScalarNumber(let number):
            return number.boolValue
        case .ScalarString(let string):
            return (string as NSString).boolValue
        case .Sequence(let array):
            return array.count > 0
        case .Mapping(let dictionary):
            return dictionary.count > 0
        case .Null:
            return false
            }
    }
}

//MARK: - Scalar: String, NSNumber, NSURL, Int, ...
extension JSON {
    
    public var stringValue: String? {
        get {
            switch self {
            case .ScalarString(let string):
                return string
            case .ScalarNumber(let number):
                return number.stringValue
            default:
                return nil
            }
        }
    }
    
    public var numberValue: NSNumber? {
        get {
            switch self {
            case .ScalarString(let string):
                var ret: NSNumber? = nil
                let scanner = NSScanner(string: string)
                if scanner.scanDouble(nil){
                    if (scanner.atEnd) {
                        ret = NSNumber(double:(string as NSString).doubleValue)
                    }
                }
                return ret
            case .ScalarNumber(let number):
                return number
            default:
                return nil
            }
        }
    }
    
    public var URLValue: NSURL? {
        get {
            switch self {
            case .ScalarString(let string):
                return NSURL(string: string)
            default:
                return nil
            }
        }
    }
    
    public var charValue: Int8? {
        get {
            if let number = self.numberValue {
                return number.charValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedCharValue: UInt8? {
        get{
            if let number = self.numberValue {
                return number.unsignedCharValue
            } else {
                return nil
            }
        }
    }
    
    public var shortValue: Int16? {
        get{
            if let number = self.numberValue {
                return number.shortValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedShortValue: UInt16? {
        get{
            if let number = self.numberValue {
                return number.unsignedShortValue
            } else {
                return nil
            }
        }
    }
    
    public var longValue: Int? {
        get{
            if let number = self.numberValue {
                return number.longValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedLongValue: UInt? {
        get{
            if let number = self.numberValue {
                return number.unsignedLongValue
            } else {
                return nil
            }
        }
    }
    
    public var longLongValue: Int64? {
        get{
            if let number = self.numberValue {
                return number.longLongValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedLongLongValue: UInt64? {
        get{
            if let number = self.numberValue {
                return number.unsignedLongLongValue
            } else {
                return nil
            }
        }
    }
    
    public var floatValue: Float? {
        get {
            if let number = self.numberValue {
                return number.floatValue
            } else {
                return nil
            }
        }
    }
    
    public var doubleValue: Double? {
        get {
            if let number = self.numberValue {
                return number.doubleValue
            } else {
                return nil
            }
        }
    }
    
    public var integerValue: Int? {
        get {
            if let number = self.numberValue {
                return number.integerValue
            } else {
                return nil
            }
        }
    }
    
    public var unsignedIntegerValue: UInt? {
        get {
            if let number = self.numberValue {
                return number.unsignedIntegerValue
            } else {
                return nil
            }
        }
    }
}

//MARK: - Comparable
extension JSON: Comparable {
    
    private var type: Int {
        get {
            switch self {
            case .ScalarNumber(_):
                return 1
            case .ScalarString(_):
                return 2
            case .Sequence(_):
                return 3
            case .Mapping(_):
                return 4
            case .Null:
                return 0
            }
        }
    }
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue == rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! == rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! == rhs.stringValue!
    case .Sequence:
        return equalsAsSet(lhs.arrayValue!, array2: rhs.arrayValue!)
        // Above originally was this which is wrong because the don't have to 
        // be in the same order to be equal
        // return lhs.arrayValue! == rhs.arrayValue!
    case .Mapping:
        return lhs.dictionaryValue! == rhs.dictionaryValue!
    case .Null:
        return true
    }
}

func equalsAsSet(array1:[JSON], array2:[JSON]) -> Bool {
    var result = Array(array1)
    for object in array2 {
        result.removeObject(object)
    }
    return result.count == 0
}

// Swift doesn't have this yet
extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in self.enumerate() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        if index != nil {
            self.removeAtIndex(index!)
        }
    }
}


public func <=(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue <= rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! <= rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! <= rhs.stringValue!
    case .Sequence:
        return lhs.arrayValue! == rhs.arrayValue!
    case .Mapping:
        return lhs.dictionaryValue! == rhs.dictionaryValue!
    case .Null:
        return true
    }
}

public func >=(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue >= rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! >= rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! >= rhs.stringValue!
    case .Sequence:
        return lhs.arrayValue! == rhs.arrayValue!
    case .Mapping:
        return lhs.dictionaryValue! == rhs.dictionaryValue!
    case .Null:
        return true
    }
}

public func >(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue > rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! > rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! > rhs.stringValue!
    case .Sequence:
        return false
    case .Mapping:
        return false
    case .Null:
        return false
    }
}

public func <(lhs: JSON, rhs: JSON) -> Bool {
    
    if lhs.numberValue != nil && rhs.numberValue != nil {
        return lhs.numberValue < rhs.numberValue
    }
    
    if lhs.type != rhs.type {
        return false
    }
    
    switch lhs {
    case JSON.ScalarNumber:
        return lhs.numberValue! < rhs.numberValue!
    case JSON.ScalarString:
        return lhs.stringValue! < rhs.stringValue!
    case .Sequence:
        return false
    case .Mapping:
        return false
    case .Null:
        return false
    }
}

// MARK: - NSNumber: Comparable
extension NSNumber: Comparable {
}

public func ==(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedSame
}

public func <(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

public func >(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == NSComparisonResult.OrderedDescending
}

public func <=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs > rhs)
}

public func >=(lhs: NSNumber, rhs: NSNumber) -> Bool {
    return !(lhs < rhs)
}
