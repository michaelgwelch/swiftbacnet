//
//  InputStreamTests.swift
//  swfitbacnet
//
//  Created by Michael Welch on 6/17/17.
//  Copyright © 2017 Michael Welch. All rights reserved.
//

import XCTest




class InputStreamTests: XCTestCase {

    func assert<T>(_ buffer:[UInt8], whenReadUsingMethod read: (InputStream)->T?, meetExpectation matches:((T)->Bool), file: StaticString = #file, line: UInt = #line) where T:Equatable {

        let data = Data(buffer)
        let stream = InputStream(data: data)
        stream.open()
        defer {
            stream.close()
        }

        let actual = read(stream)

        XCTAssert(matches(actual!), "", file:file, line:line)
    }

    func assert<T>(_ buffer:[UInt8], whenReadUsingMethod read: (InputStream)->T?, areEqualTo expected:T, file: StaticString = #file, line: UInt = #line) where T:Equatable {

        let data = Data(buffer)
        let stream = InputStream(data: data)
        stream.open()
        defer {
            stream.close()
        }

        let actual = read(stream)

        XCTAssertEqual(expected, actual!, "", file:file, line:line)
    }

    let readInt8:(InputStream) -> Int8? = { $0.readInt8() }
    let readInt16:(InputStream) -> Int16? = { $0.readInt16() }
    let readInt24:(InputStream) -> Int32? = { $0.readInt24() }
    let readInt32:(InputStream) -> Int32? = { $0.readInt32() }


    let readUInt8:(InputStream) -> UInt8? = { $0.readUInt8() }
    let readUInt16:(InputStream) -> UInt16? = { $0.readUInt16() }
    let readUInt24:(InputStream) -> UInt32? = { $0.readUInt24() }
    let readUInt32:(InputStream) -> UInt32? = { $0.readUInt32() }

    let readFloat:(InputStream) -> Float? = { $0.readFloat() }
    let readDouble:(InputStream) -> Double? = { $0.readDouble() }

}


/**
 Unsigned integers
 */
extension InputStreamTests {

    func testReadUInt8Min() {
        let bytes:[UInt8] = [0]
        assert(bytes, whenReadUsingMethod: readUInt8, areEqualTo: 0)
    }

    func testReadUInt8() {
        let bytes:[UInt8] = [123]
        assert(bytes, whenReadUsingMethod: readUInt8, areEqualTo: 123)
    }

    func testReadUInt8Max() {
        let bytes:[UInt8] = [255]
        assert(bytes, whenReadUsingMethod: readUInt8, areEqualTo: 255)
    }

    func testUInt16Min() {
        let bytes:[UInt8] = [0x01, 0x00]
        assert(bytes, whenReadUsingMethod: readUInt16, areEqualTo: 256)
    }

    func testReadUInt16() {
        let bytes:[UInt8] = [0x01, 0x02]
        assert(bytes, whenReadUsingMethod: readUInt16, areEqualTo: 258)
    }

    func testReadUInt16Max() {
        let bytes:[UInt8] = [0xFF,0xFF]
        assert(bytes, whenReadUsingMethod: readUInt16, areEqualTo: UInt16.max)
    }

    func testReadUInt24Min() {
        let bytes:[UInt8] = [0x01, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readUInt24, areEqualTo: UInt32(UInt16.max) + 1)
    }

    func testReadUInt24() {
        let bytes:[UInt8] = [0x01,0x02,0x03]
        assert(bytes, whenReadUsingMethod: readUInt24, areEqualTo: UInt32(65536 + 2 * 256 + 3))
    }

    func testReadUInt24Max() {
        let bytes:[UInt8] = [0xFF, 0xFF, 0xFF]
        assert(bytes, whenReadUsingMethod: readUInt24, areEqualTo: 0xFFFFFF)
    }

    func testReadUInt32Min() {
        let bytes:[UInt8] = [0x01, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readUInt32, areEqualTo: 0x01000000)
    }

    func testReadUInt32() {
        let bytes:[UInt8] = [0x01,0x02,0x03,0x04]
        assert(bytes, whenReadUsingMethod: readUInt32, areEqualTo: UInt32(16777216 + 2 * 65536 + 3 * 256 + 4))
    }

    func testReadUInt32Max() {
        let bytes:[UInt8] = [0xFF,0xFF,0xFF,0xFF]
        assert(bytes, whenReadUsingMethod: readUInt32, areEqualTo: UInt32.max)
    }

}

/**
 Signed integer tests
 */
extension InputStreamTests {


    func testReadInt8Min() {
        let bytes:[UInt8] = [0x80]
        assert(bytes, whenReadUsingMethod: readInt8, areEqualTo: -128)
    }

    func testReadInt8Neg1() {
        let bytes:[UInt8] = [0xFF]
        assert(bytes, whenReadUsingMethod: readInt8, areEqualTo: -1)
    }

    func testReadInt8Max() {
        let bytes:[UInt8] = [0x7F]
        assert(bytes, whenReadUsingMethod: readInt8, areEqualTo: 127)
    }

    func testReadInt16() {
        let bytes:[UInt8] = [0x80, 0x00]
        assert(bytes, whenReadUsingMethod: readInt16, areEqualTo: -32768)
    }

    func testReadInt24() {
        let bytes:[UInt8] = [0x80, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readInt24, areEqualTo: -8388608)
    }

    func testReadInt32() {
        let bytes:[UInt8] = [0x80, 0x00, 0x00, 0x00]
        let expected:Int32 = Int32.min

        assert(bytes, whenReadUsingMethod: readInt32, areEqualTo: expected)
    }
}

/**
 Float tests
 */
extension InputStreamTests {

    func testReadFloatGreatestFiniteMagnitudePositive() {
        let bytes:[UInt8] = [0x7F, 0x7F, 0xFF, 0xFF]
        assert(bytes, whenReadUsingMethod: readFloat, areEqualTo: Float.greatestFiniteMagnitude)
    }

    func testReadFloatGreatestFiniteMagnitudeNegative() {
        let bytes:[UInt8] = [0xFF, 0x7F, 0xFF, 0xFF]
        assert(bytes, whenReadUsingMethod: readFloat, areEqualTo: -Float.greatestFiniteMagnitude)
    }

    func testReadFloatLeastNonZeroMagnitudePositive() {
        let bytes:[UInt8] = [0x00, 0x00, 0x00, 0x01]
        assert(bytes, whenReadUsingMethod: readFloat, areEqualTo: Float.leastNonzeroMagnitude)
    }

    func testReadFloatLeastNonZeroMagnitudeNegative() {
        let bytes:[UInt8] = [0x80, 0x00, 0x00, 0x01]
        assert(bytes, whenReadUsingMethod: readFloat, areEqualTo: -Float.leastNonzeroMagnitude)
    }

    func testReadFloatLeastNormalMagnitudePositive() {
        let bytes:[UInt8] = [0x00, 0x80, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readFloat, areEqualTo: Float.leastNormalMagnitude)
    }

    func testReadFloatLeastNormalMagnitudeNegative() {
        let bytes:[UInt8] = [0x80, 0x80, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readFloat, areEqualTo: -Float.leastNormalMagnitude)
    }

}

/**
 Double tests
 */
extension InputStreamTests {

    func testReadDoubleGreatestFiniteMagnitudePositive() {
        let bytes:[UInt8] = [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: Double.greatestFiniteMagnitude)
    }

    func testReadDoubleGreatestFiniteMagnitudeNegative() {
        let bytes:[UInt8] = [0xFF, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: -Double.greatestFiniteMagnitude)
    }

    func testReadDoubleLeastNonzeroMagnitudePositive() {
        let bytes:[UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: Double.leastNonzeroMagnitude)
    }

    func testReadDoubleLeastNonzeroMagnitudeNegative() {
        let bytes:[UInt8] = [0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: -Double.leastNonzeroMagnitude)
    }

    func testReadDoubleLeastNormalMagnitudePositive() {
        let bytes:[UInt8] = [0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: Double.leastNormalMagnitude)
    }

    func testReadDoubleLeastNormalMagnitudeNegative() {
        let bytes:[UInt8] = [0x80, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: -Double.leastNormalMagnitude)
    }

    func testReadDoubleTwoAndAQuarter() {
        let bytes:[UInt8] = [0x40, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: 2.25)
    }

    func testReadDoublOneAndAHalf() {
        let bytes:[UInt8] = [0x3F, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, areEqualTo: 1.5)
    }

    func testReadDoubleNaN() {
        let bytes:[UInt8] = [0x7F, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, meetExpectation: { $0.isNaN })
    }

    func testReadDoublePosInf() {
        let bytes:[UInt8] = [0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, meetExpectation: { $0.isPositiveInfinite })
    }

    func testReadDoubleNegInf() {
        let bytes:[UInt8] = [0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        assert(bytes, whenReadUsingMethod: readDouble, meetExpectation: { $0.isNegativeInfinite })
    }
}

extension FloatingPoint {

    var isPositiveInfinite:Bool {
        return isInfinite && self > 0
    }

    var isNegativeInfinite:Bool {
        return isInfinite && self < 0
    }

}
