import Testing

struct TestVector: CustomTestStringConvertible, Identifiable {
    let id: Int
    let message: ArraySlice<UInt8>
    let expected: ArraySlice<UInt8>

    var testDescription: String {
        "#\(id)"
    }
}

let `sha1.blb` = try! PackageResources.sha1_blb.blobs().couples().enumerated().map({
    TestVector(id: $0.offset, message: $0.element.0, expected: $0.element.1)
})
