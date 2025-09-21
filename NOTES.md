TODO: Use keypath in round(...) when possible. See Feedback.


// <unknown>:0: error: copy of noncopyable typed value. This is a compiler bug. Please file a bug with a small example of the bug
// <unknown>:0: error: '$0' is borrowed and cannot be consumed
// /Users/konstantin/Developer/sha1-swift/Sources/SHA1/State.swift:20:39: note: consumed here
// state.brokenRound(with: \.choice, constant: 0x5a827999, word: $0[index]) 

```swift
mutating func brokenRound(
    with function: (borrowing Self) -> UInt32,
    constant: UInt32,
    word: UInt32
) {
    self.round(with: function(self), constant: constant, word: word)
}
```
