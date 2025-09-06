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
    color: ?UnionColor = null,
};

const ColorType = enum { Normal, Id, Rgb };

const UnionColor = union(ColorType) { Normal: ColorNormal, Id: Color256, Rgb: ColorRgb };

const Color256 = struct { Id: u8 = 0, Fg: bool = true };

const ColorRgb = struct { R: u8 = 0, G: u8 = 0, B: u8 = 0, Fg: bool = true };

const ColorNormal = enum(u8) {
    FgBlack = 30,
    BgBlack = 40,
    FgRed = 31,
    BgRed = 41,
    FgGree = 32,
    BgGree = 42,
    FgYellow = 33,
    BgYellow = 43,
    FgBlue = 34,
    BgBlue = 44,
    FgMagenta = 35,
    BgMagenta = 45,
    FgCyan = 36,
    BgCyan = 46,
    FgWhite = 37,
    BgWhite = 47,
    FgDefault = 39,
    BgDefault = 49,
    FgBrightBlack = 90,
    BgBrightBlack = 100,
    FgBrightRed = 91,
    BgBrightRed = 101,
    FgBrightGreen = 92,
    BgBrightGreen = 102,
    FgBrightYellow = 93,
    BgBrightYellow = 103,
    FgBrightBlue = 94,
    BgBrightBlue = 104,
    FgBrightMagenta = 95,
    BgBrightMagenta = 105,
    FgBrightCyan = 96,
    BgBrightCyan = 106,
    FgBrightWhite = 97,
    BgBrightWhite = 107,
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

    if (setting.dim) {
        buf[cur] = ASCII.@"2"[0];
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

    if (setting.underline) {
        buf[cur] = ASCII.@"4"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    if (setting.blinking) {
        buf[cur] = ASCII.@"5"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    if (setting.inverse) {
        buf[cur] = ASCII.@"7"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    if (setting.hidden) {
        buf[cur] = ASCII.@"8"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    if (setting.strikethrough) {
        buf[cur] = ASCII.@"9"[0];
        cur += 1;
        buf[cur] = ASCII.Semi[0];
        cur += 1;
    }

    if (setting.color) |colorType| {
        var colorBuf: [20]u8 = undefined;
        const colorResultBuf = try switch (colorType) {
            .Normal => |value| std.fmt.bufPrint(&colorBuf, "{};", .{@intFromEnum(value)}),
            .Id => |value| blk: {
                if (value.Fg) {
                    break :blk std.fmt.bufPrint(&colorBuf, "38;5;{};", .{value.Id});
                } else {
                    break :blk std.fmt.bufPrint(&colorBuf, "48;5;{};", .{value.Id});
                }
            },
            .Rgb => |value| blk: {
                if (value.Fg) {
                    break :blk std.fmt.bufPrint(&colorBuf, "38;2;{};{};{};", .{ value.R, value.G, value.B });
                } else {
                    break :blk std.fmt.bufPrint(&colorBuf, "48;2;{};{};{};", .{ value.R, value.G, value.B });
                }
            },
        };
        std.debug.print("{any}", .{colorResultBuf});
        @memcpy(buf[cur..(cur + colorResultBuf.len)], colorResultBuf);
        cur += colorResultBuf.len;
    }

    cur -= 1;
    buf[cur] = ASCII.m[0];
    return buf[0..(cur + 1)];
}
test "strikethroughstyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .strikethrough = true });
    const expetc = "\x1b[9m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
test "hiddenstyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .hidden = true });
    const expetc = "\x1b[8m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
test "inversestyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .inverse = true });
    const expetc = "\x1b[7m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "blinkingstyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .blinking = true });
    const expetc = "\x1b[5m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "underlinestyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .underline = true });
    const expetc = "\x1b[4m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "dimstyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .dim = true });
    const expetc = "\x1b[2m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
test "italicstyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .italic = true });
    const expetc = "\x1b[3m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "boldstyle" {
    var buf: [100]u8 = undefined;

    const result = try style(&buf, .{ .bold = true });
    const expetc = "\x1b[1m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
