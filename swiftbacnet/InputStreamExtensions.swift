//
//  InputStreamExtensions.swift
//  swfitbacnet
//
//  Created by Michael Welch on 6/17/17.
//  Copyright © 2017 Michael Welch. All rights reserved.
//

import Foundation

extension InputStream {
    public func readUInt8() -> UInt8? {
        var byte:UInt8 = 0
        return withUnsafeMutablePointer(to: &byte) {
            return readBytes(buffer: $0, count: 1, transform: {$0})
        }
    }

    public func readUInt16() -> UInt16? {
        var readBuffer:UInt16 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            return readBytes(buffer: $0, count: 2, transform: { UInt16(bigEndian: $0) })
        }
    }

    public func readUInt24() -> UInt32? {
        var readBuffer:UInt32 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            return readBytes(buffer: $0, count: 3, transform: { UInt32(bigEndian: ($0 << 8)) })
        }
    }

    public func readUInt32() -> UInt32? {
        var readBuffer:UInt32 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            readBytes(buffer: $0, count: 4, transform: { UInt32(bigEndian: $0)})
        }
    }

    public func readInt8() -> Int8? {
        var readBuffer:Int8 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            readBytes(buffer: $0, count: 1, transform: {$0})
        }
    }

    public func readInt16() -> Int16? {
        var readBuffer:Int16 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            readBytes(buffer: $0, count: 2, transform: { Int16(bigEndian: $0) })
        }
    }

    public func readInt24() -> Int32? {
        var readBuffer:Int32 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            readBytes(buffer: $0, count: 3, transform: { Int32(bigEndian: ($0 << 8) | 0x000000FF) })
        }
    }

    public func readInt32() -> Int32? {
        var readBuffer:Int32 = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            readBytes(buffer: $0, count: 4, transform: { Int32(bigEndian: $0) })
        }
    }

    /**
     Reads the next `count` bytes into the `buffer` and then applies the transform to the value of
     `T` stored in the buffer
    */
    private func readBytes<T>(buffer:UnsafeMutablePointer<T>, count:Int, transform:(T)->T) -> T? {

        var bytesRead:Int = 0
        buffer.withMemoryRebound(to: UInt8.self, capacity: count) {
            bytesRead = self.read($0, maxLength: count)
        }

        return bytesRead == count ? transform(buffer.pointee) : nil
    }


    public func readFloat() -> Float?  {
        var readBuffer:UInt32 = 0
        var bytesRead:Int = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            return $0.withMemoryRebound(to: UInt8.self, capacity:4) {
                bytesRead = self.read($0, maxLength: 4)

                guard bytesRead == 4 else {
                    return nil
                }

                return Float(bitPattern: UInt32(bigEndian: readBuffer))
            }
        }
    }

    public func readDouble() -> Double?  {
        var readBuffer:UInt64 = 0
        var bytesRead:Int = 0
        return withUnsafeMutablePointer(to: &readBuffer) {
            return $0.withMemoryRebound(to: UInt8.self, capacity:8) {
                bytesRead = self.read($0, maxLength: 8)

                guard bytesRead ==  8 else {
                    return nil
                }

                return Double(bitPattern: UInt64(bigEndian: readBuffer))
            }
        }
    }

    public func readTag() -> (UInt8, Bool, UInt8)? {
        if let byte = readUInt8() {
            let tagNumber = (byte >> UInt8(4)) & 0x0F
            let classValue = (byte & 0x08) != 0
            let lvt = byte & 0x07
            return (tagNumber, classValue, lvt)
        }
        return nil
    }
}
