// Playground - noun: a place where people can play
import Foundation
import UIKit

var str = "Hello, playground"


var s = "ABCDEFG"

for c in s {
    print(c)
}
s.endIndex

let d = [ "abc": (0, 0, "Cell"), "def": (0,1, "Cell"), "xyz": (1,0,"CellEdit") ]
for (key,val) in d {
    NSLog("key={key} val={#val}")
    key
    val
}

var h = [
"title":   0 * 100 + 0,
"url":     0 * 100 + 1,
"userid":  1 * 100 + 0,
"pass":    2 * 100 + 0,
"set":     2 * 100 + 1,
"length":  2 * 100 + 2,
"char":    2 * 100 + 3,
"picker":  2 * 100 + 4,
"memo":    3 * 100 + 0 ]
h
h.count


var x = h.values.array.sorted(<).map( { ($0 / 100, $0 % 100 ) } )
x
x.map( { (sec,row) in println("\(sec) \(row)") } )

var ip1 = NSIndexPath(forRow: 0, inSection: 1)
var ip2 = NSIndexPath(forRow: 0, inSection: 1)
ip1 == ip2


var h1 =                     [
    "title":   NSIndexPath(forRow: 0, inSection:0),
    "url":     NSIndexPath(forRow: 1, inSection:0),
    "userid":  NSIndexPath(forRow: 0, inSection:1),
    "pass":    NSIndexPath(forRow: 0, inSection:2),
    "set":     NSIndexPath(forRow: 1, inSection:2),
    "length":  NSIndexPath(forRow: 2, inSection:2),
    "char":    NSIndexPath(forRow: 3, inSection:2),
    "picker":  NSIndexPath(forRow: 4, inSection:2),
    "memo":    NSIndexPath(forRow: 0, inSection:3) ]

var h2 = [
    "title":   NSIndexPath(forRow: 0, inSection:0),
    "url":     NSIndexPath(forRow: 1, inSection:0),
    "userid":  NSIndexPath(forRow: 0, inSection:1),
    "pass":    NSIndexPath(forRow: 1, inSection:1),
    "memo":    NSIndexPath(forRow: 0, inSection:2) ]


func unique<T: Equatable>(array: [T]) -> [T] {
    var result = [T]()
    
    for elm in array {
        if find(result, elm) == nil {
            result += [elm]
        }
    }
    return result
}

func difference<T: Equatable>(x: [T], y: [T]) -> [T] {
    return x.filter {find(y, $0)==nil}
}

func intersection<T: Equatable>(x: [T], y: [T]) -> [T] {
    return x.filter {find(y, $0) == nil ? false : true}
}

unique(h1.keys.array)

difference(h1.keys.array, h2.keys.array)
difference(h2.keys.array, h1.keys.array)
intersection(h1.keys.array, h2.keys.array+["xz","yz"])
intersection(h2.keys.array, h1.keys.array)

var hhh = [ "title": "Apple", "url": "http://www.apple.com/", "length": 10]
hhh[ "length"]







