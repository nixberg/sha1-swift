import CryptoExtras

typealias State = InlineArray<5, UInt32>

extension State {
    fileprivate static func &+= (lhs: inout Self, rhs: borrowing WorkingState) {
        lhs[0] &+= rhs.a
        lhs[1] &+= rhs.b
        lhs[2] &+= rhs.c
        lhs[3] &+= rhs.d
        lhs[4] &+= rhs.e
    }

    init() {
        self = [
            0x6745_2301,
            0xefcd_ab89,
            0x98ba_dcfe,
            0x1032_5476,
            0xc3d2_e1f0,
        ]
    }

    mutating func compress(_ buffer: borrowing RawSpan) {
        var workingState = WorkingState(self)

        let expandedBuffer = ExpandedBuffer(parsingBigEndian: buffer)

        workingState.round0(with: expandedBuffer[00])
        workingState.round0(with: expandedBuffer[01])
        workingState.round0(with: expandedBuffer[02])
        workingState.round0(with: expandedBuffer[03])
        workingState.round0(with: expandedBuffer[04])
        workingState.round0(with: expandedBuffer[05])
        workingState.round0(with: expandedBuffer[06])
        workingState.round0(with: expandedBuffer[07])
        workingState.round0(with: expandedBuffer[08])
        workingState.round0(with: expandedBuffer[09])
        workingState.round0(with: expandedBuffer[10])
        workingState.round0(with: expandedBuffer[11])
        workingState.round0(with: expandedBuffer[12])
        workingState.round0(with: expandedBuffer[13])
        workingState.round0(with: expandedBuffer[14])
        workingState.round0(with: expandedBuffer[15])
        workingState.round0(with: expandedBuffer[16])
        workingState.round0(with: expandedBuffer[17])
        workingState.round0(with: expandedBuffer[18])
        workingState.round0(with: expandedBuffer[19])

        workingState.round1(with: expandedBuffer[20])
        workingState.round1(with: expandedBuffer[21])
        workingState.round1(with: expandedBuffer[22])
        workingState.round1(with: expandedBuffer[23])
        workingState.round1(with: expandedBuffer[24])
        workingState.round1(with: expandedBuffer[25])
        workingState.round1(with: expandedBuffer[26])
        workingState.round1(with: expandedBuffer[27])
        workingState.round1(with: expandedBuffer[28])
        workingState.round1(with: expandedBuffer[29])
        workingState.round1(with: expandedBuffer[30])
        workingState.round1(with: expandedBuffer[31])
        workingState.round1(with: expandedBuffer[32])
        workingState.round1(with: expandedBuffer[33])
        workingState.round1(with: expandedBuffer[34])
        workingState.round1(with: expandedBuffer[35])
        workingState.round1(with: expandedBuffer[36])
        workingState.round1(with: expandedBuffer[37])
        workingState.round1(with: expandedBuffer[38])
        workingState.round1(with: expandedBuffer[39])

        workingState.round2(with: expandedBuffer[40])
        workingState.round2(with: expandedBuffer[41])
        workingState.round2(with: expandedBuffer[42])
        workingState.round2(with: expandedBuffer[43])
        workingState.round2(with: expandedBuffer[44])
        workingState.round2(with: expandedBuffer[45])
        workingState.round2(with: expandedBuffer[46])
        workingState.round2(with: expandedBuffer[47])
        workingState.round2(with: expandedBuffer[48])
        workingState.round2(with: expandedBuffer[49])
        workingState.round2(with: expandedBuffer[50])
        workingState.round2(with: expandedBuffer[51])
        workingState.round2(with: expandedBuffer[52])
        workingState.round2(with: expandedBuffer[53])
        workingState.round2(with: expandedBuffer[54])
        workingState.round2(with: expandedBuffer[55])
        workingState.round2(with: expandedBuffer[56])
        workingState.round2(with: expandedBuffer[57])
        workingState.round2(with: expandedBuffer[58])
        workingState.round2(with: expandedBuffer[59])

        workingState.round3(with: expandedBuffer[60])
        workingState.round3(with: expandedBuffer[61])
        workingState.round3(with: expandedBuffer[62])
        workingState.round3(with: expandedBuffer[63])
        workingState.round3(with: expandedBuffer[64])
        workingState.round3(with: expandedBuffer[65])
        workingState.round3(with: expandedBuffer[66])
        workingState.round3(with: expandedBuffer[67])
        workingState.round3(with: expandedBuffer[68])
        workingState.round3(with: expandedBuffer[69])
        workingState.round3(with: expandedBuffer[70])
        workingState.round3(with: expandedBuffer[71])
        workingState.round3(with: expandedBuffer[72])
        workingState.round3(with: expandedBuffer[73])
        workingState.round3(with: expandedBuffer[74])
        workingState.round3(with: expandedBuffer[75])
        workingState.round3(with: expandedBuffer[76])
        workingState.round3(with: expandedBuffer[77])
        workingState.round3(with: expandedBuffer[78])
        workingState.round3(with: expandedBuffer[79])

        self &+= workingState
    }

    func storeBytes(into output: inout MutableRawSpan) {
        output.storeBytes(of: self[0].bigEndian, toByteOffset: 00, as: UInt32.self)
        output.storeBytes(of: self[1].bigEndian, toByteOffset: 04, as: UInt32.self)
        output.storeBytes(of: self[2].bigEndian, toByteOffset: 08, as: UInt32.self)
        output.storeBytes(of: self[3].bigEndian, toByteOffset: 12, as: UInt32.self)
        output.storeBytes(of: self[4].bigEndian, toByteOffset: 16, as: UInt32.self)
    }
}
