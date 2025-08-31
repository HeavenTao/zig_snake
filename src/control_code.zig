pub const Control = enum(u8) {
    BEL = 7,
    BS = 8,
    ///H-Tab
    HT = 9,
    LF = 10,
    ///V-Tab
    VT = 11,
    FF = 12,
    CR = 13,
    ESC = 27,
    DEL = 127,
};
