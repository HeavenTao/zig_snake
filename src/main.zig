const std = @import("std");
const TermSize = @import("termSize.zig");
const cursor = @import("cursorMove.zig");
const ASCII_CODE = @import("gernral_ascii_code.zig");
const print = std.debug.print;

pub fn main() !void {
    var buf: [10]u8 = undefined;
    const result = try ASCII_CODE.to(0, 0, &buf);

    print("{any}", .{result});
}
