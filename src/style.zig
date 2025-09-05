const Control = @import("control_code.zig");
const ASCII = @import("ascii_code.zig");
const std = @import("std");

pub const Rest = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"0" ++ ASCII.m;

const Setting = struct {
    bold: bool = false,
    italic: bool = false,
    dim: bool = false,
    underline: bool = false,
    blinking: bool = false,
    inverse: bool = false,
    hidden: bool = false,
    strikethrough: bool = false,
    color: ?u8 = null,
};

pub fn style(buf: []u8, setting: Setting) ![]const u8 {
    var cur: usize = 0;

    buf[cur] = Control.ESC[0];
    cur += 1;
    buf[cur] = ASCII.LeftSquare[0];
    cur += 1;

    if (setting.bold) {
        buf[cur] = ASCII.@"1"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    if (setting.italic) {
        buf[cur] = ASCII.@"3"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    buf[cur] = ASCII.m[0];
    return buf[0..(cur + 1)];
}

test "style" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .bold = true });
    const expetc = "\x1b[1;m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
