//
//  Set.swift
//  GnsClientIOS
//
//  Created by David Westbrook on 11/10/14.
//  Copyright (c) 2014 University of Massachusetts.
//

import Foundation

public struct Set<T: Hashable>: SequenceType, Hashable, Equatable {
    
    var container :Dictionary<T, Bool>
    
    public var description: String {
        get {
            let items = self.toArray()
            return "Set: \(items)"
        }
    }
    
    public var count: Int {
        get {
            return container.count
        }
    }
    
    public var isEmpty: Bool {
        get {
            return container.count == 0
        }
    }
    
    public var hashValue: Int {
        get {
            var hash = 0
            for object in self {
                hash ^= object.hashValue
            }
            return hash
        }
    }
    
    var debugDescription: String {
        get {
            return self.description
        }
    }
    
    public init(minimumCapacity: Int = 2)
    {
        container = Dictionary<T, Bool>(minimumCapacity: minimumCapacity)
    }
    
    public init(array: Array<T>)
    {
        if array.count < 2 {
            self.init()
        }
        else {
            self.init(minimumCapacity: array.count)
        }
        
        for item in array
        {
            container[item] = true
        }
    }
    
    public func member(object: T) -> Bool
    {
        return container.indexForKey(object) != nil
    }
    
    public mutating func add(object: T) {
        container[object] = true
    }
    
    public mutating func add(array: Array<T>)
    {
        for object in array {
            container[object] = true
        }
    }
    
    public mutating func remove(object: T) {
        container.removeValueForKey(object)
    }
    
    public mutating func removeAll(keepCapacity: Bool = true)
    {
        container.removeAll(keepCapacity: keepCapacity)
    }
    
    public func reduce<U>(initial: U, combine: (U, T) -> U) -> U {
        var acc = initial
        for object in self {
            acc = combine(acc, object)
        }
        return acc
    }
    
    public func filter(predicate: T -> Bool) -> Set<T>
    {
        return self.reduce(Set<T>()) { (acc: Set<T>, t: T) -> Set<T> in if predicate(t) { var acc = acc
            acc.add(t) }; return acc }
    }
    
    public func map<U>(transform: T -> U) -> Set<U> {
        return self.reduce(Set<U>(minimumCapacity: self.count)) { (acc: Set<U>, t: T) -> Set<U> in var acc = acc
            acc.add(transform(t)); return acc }
    }
    
    public func iter(action: T -> ()) {
        for object in self {
            action(object)
        }
    }
    
    public func toArray() -> Array<T> {
        var array = Array<T>()
        for key in container.keys {
            array.append(key)
        }
        
        return array
    }
    
    public func generate() -> IndexingGenerator<Array<T>> {
        let items = self.toArray()
        
        return items.generate()
    }
    
    func union(set: Set<T>) -> Set<T> {
        var result = Set<T>(array: self.toArray())
        result.add(set.toArray())
        return result
    }
    
    func minus(set: Set<T>) -> Set<T>{
        var result = Set<T>(array: self.toArray())
        for object in set {
            result.remove(object)
        }
        return result
    }
    
    func intersect(set: Set<T>) -> Set<T>{
        var result = Set<T>(array: self.toArray())
        for object in result {
            if !set.member(object) {
                result.remove(object)
            }
        }
        return result
    }
}

public func ==<T> (lhs: Set<T>, rhs: Set<T>) -> Bool {
    return lhs.count == rhs.count && lhs.minus(rhs).isEmpty
}

public func +<T> (lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.union(rhs)
}

public func -<T> (lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.minus(rhs)
}

public func ^<T> (lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.intersect(rhs)
}
