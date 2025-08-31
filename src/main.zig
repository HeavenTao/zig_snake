const std = @import("std");
const getTermSize = @import("termSize.zig").getTermSize;
const print = std.debug.print;

pub fn main() !void {
    const size = getTermSize();
    if (size == null) {
        @panic("no term size");
    }
}
