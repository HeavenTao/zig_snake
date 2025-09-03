const std = @import("std");
const BufError = @import("error.zig").BufError;
const Control = @import("control_code.zig").Control;
const ASCII = @import("ascii_code.zig").ASCII;

pub fn erase_from_cursor_until_screen_end(buf: []u8) ![]const u8 {
    if (buf.len < 4) {}

    var cur: usize = 0;
    buf[cur] = @intFromEnum(Control.ESC);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftSquare);
    cur += 1;
    buf[cur] = 48;
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.J);

    return buf[0..(cur + 1)];
}

test "earse_from_cursor_until_screen_end" {
    var buf: [10]u8 = undefined;

    const result = try erase_from_cursor_until_screen_end(&buf);
    const expect = [_]u8{ 27, 91, 48, 74 };

    try std.testing.expectEqualSlices(u8, &expect, result);
}
