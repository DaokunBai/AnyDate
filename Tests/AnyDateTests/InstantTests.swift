import XCTest
import Foundation
import AnyDate

class InstantTests: XCTestCase {
    
    func testPropertySetter() {
        var zero = Instant.epoch
        zero.second = 100
        zero.nano = 100

        XCTAssertEqual(zero.second, 100)
        XCTAssertEqual(zero.nano, 100)
    }
    func testComparable() {
        let min = Instant.min
        let max = Instant.max

        let oldDate = Instant(epochSecond: 100_000, nano: 999_999_000)
        let newDate = Instant(epochSecond: 100_000, nano: 999_999_001)
        let equalDate = Instant(epochSecond: 100_000, nano: 999_999_000)

        XCTAssertLessThan(min, oldDate)
        XCTAssertGreaterThan(max, newDate)
        XCTAssertLessThanOrEqual(oldDate, equalDate)
        XCTAssertGreaterThanOrEqual(oldDate, equalDate)
        XCTAssertLessThan(oldDate, newDate)
        XCTAssertGreaterThan(newDate, oldDate)
        XCTAssertEqual(oldDate, equalDate)
        XCTAssertLessThan(oldDate, newDate)
    }
    func testNormalize() {
        var instant = Instant(epochSecond: -100, nano: -100)
        XCTAssertEqual(instant.second, -101)
        XCTAssertEqual(instant.nano, 999_999_900)
    }
    func testEpoch() {
        let instant = Instant.epoch
        XCTAssertEqual(instant.second, 0)
        XCTAssertEqual(instant.nano, 0)
    }
    func testMin() {
        let min = Instant.min
        XCTAssertEqual(min.second, -31_557_014_167_219_200)
        XCTAssertEqual(min.nano, 0)
    }
    func testMax() {
        let max = Instant.max
        XCTAssertEqual(max.second, 31_556_889_864_403_199)
        XCTAssertEqual(max.nano, 999_999_999)
    }
    func testEpochMilli() {
        let instant1 = Instant(epochSecond: 100_000, nano: 999_999_999)
        XCTAssertEqual(instant1.epochMilli, 100_000_999)

        let instant2 = Instant(epochMilli: 100_000_999)
        XCTAssertEqual(instant2.second, 100_000)
        XCTAssertEqual(instant2.nano, 999_000_000)
    }
    func testParse() {
        let instant1 = Instant.parse("1970-1-1T0:1:5.123Z")!
        XCTAssertEqual(instant1.second, 65)
        XCTAssertGreaterThan(123_500_000, instant1.nano)
        XCTAssertLessThanOrEqual(122_500_000, instant1.nano)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'SSS'Z'"
        let instant2 = Instant.parse("1970-1-1T0:1:5.123Z", formatter: formatter, clock: Clock.UTC)
        XCTAssertEqual(instant2, nil)
    }
    func testToZone() {
        let instant = Instant(epochSecond: 65, nano: 123_000_000)
        let zone = instant.toZone()

        XCTAssertEqual(zone.year, 1970)
        XCTAssertEqual(zone.month, 1)
        XCTAssertEqual(zone.day, 1)
        XCTAssertEqual(zone.hour, 0)
        XCTAssertEqual(zone.minute, 1)
        XCTAssertEqual(zone.second, 5)
        XCTAssertEqual(zone.nano, 123_000_000)
    }
    func testPlus() {
        let instant = Instant(epochSecond: 100_000, nano: 999_000_000)

        let compare1 = Instant(epochSecond: 100_001, nano: 999_000_000)
        let compare2 = Instant(epochSecond: 100_000, nano: 999_000_001)
        let compare3 = Instant(epochSecond: 100_001, nano: 000_000_000)
        let compare4 = Instant(epochSecond: 100_001, nano: 999_000_001)

        XCTAssertEqual(instant.plus(second: 1), compare1)
        XCTAssertEqual(instant.plus(nano: 1), compare2)
        XCTAssertEqual(instant.plus(milli: 1), compare3)
        XCTAssertEqual(instant.plus(component: .second, newValue: 1), compare1)
        XCTAssertEqual(instant.plus(component: .nanosecond, newValue: 1), compare2)
        XCTAssertEqual(instant.plus(second: 1, nano: 1), compare4)
    }
    func testMinus() {
        let instant = Instant(epochSecond: 100_000, nano: 999_000_000)

        let compare1 = Instant(epochSecond: 99_999, nano: 999_000_000)
        let compare2 = Instant(epochSecond: 100_000, nano: 998_999_999)
        let compare3 = Instant(epochSecond: 100_000, nano: 998_000_000)
        let compare4 = Instant(epochSecond: 99_999, nano: 998_999_999)

        XCTAssertEqual(instant.minus(second: 1), compare1)
        XCTAssertEqual(instant.minus(nano: 1), compare2)
        XCTAssertEqual(instant.minus(milli: 1), compare3)
        XCTAssertEqual(instant.minus(component: .second, newValue: 1), compare1)
        XCTAssertEqual(instant.minus(component: .nanosecond, newValue: 1), compare2)
        XCTAssertEqual(instant.minus(second: 1, nano: 1), compare4)
    }
    func testUntil() {
        let instant1 = Instant(epochSecond: 100_000, nano: 999_000_000)
        let zero = Instant(epochSecond: 0, nano: 0)
        
        XCTAssertEqual(zero.until(endInstant: instant1, component: .nanosecond), 100_000_999_000_000)
        XCTAssertEqual(zero.until(endInstant: instant1, component: .second), 100_000)
        XCTAssertEqual(zero.until(endInstant: instant1, component: .minute), 1666)
        XCTAssertEqual(zero.until(endInstant: instant1, component: .hour), 27)
        XCTAssertEqual(zero.until(endInstant: instant1, component: .day), 1)

        let instant2 = Instant(epochSecond: 100_001, nano: 998_000_000)
        XCTAssertEqual(instant1.until(endInstant: instant2, component: .nanosecond), 999_000_000)
        XCTAssertEqual(instant1.until(endInstant: instant2, component: .second), 0)
        XCTAssertEqual(instant1.until(endInstant: instant2, component: .minute), 0)
        XCTAssertEqual(instant1.until(endInstant: instant2, component: .hour), 0)
        XCTAssertEqual(instant1.until(endInstant: instant2, component: .day), 0)

        let instant3 = Instant(epochSecond: 99_999, nano: 999_900_000)
        XCTAssertEqual(instant1.until(endInstant: instant3, component: .nanosecond), -999_100_000)
        XCTAssertEqual(instant1.until(endInstant: instant3, component: .second), 0)
        XCTAssertEqual(instant1.until(endInstant: instant3, component: .minute), 0)
        XCTAssertEqual(instant1.until(endInstant: instant3, component: .hour), 0)
        XCTAssertEqual(instant1.until(endInstant: instant3, component: .day), 0)
    }
    func testWith() {
        let instant = Instant(epochSecond: 100_000, nano: 999_000_000)

        let compare1 = Instant(epochSecond: 500, nano: 999_000_000)
        let compare2 = Instant(epochSecond: 100_000, nano: 500)

        XCTAssertEqual(instant.with(component: .second, newValue: 500), compare1)
        XCTAssertEqual(instant.with(component: .nanosecond, newValue: 500), compare2)
    }
    func testDescription() {
        let instant = Instant(epochSecond: 100_000, nano: 999_000_000)
        XCTAssertEqual(instant.description, "100000.999000000")
        XCTAssertEqual(instant.debugDescription, "100000.999000000")
    }

}