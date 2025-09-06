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

pub fn style(setting: Setting) ![]const u8 {
    var array = try std.BoundedArray(u8, 100).init(0);
    try array.append(Control.ESC[0]);
    try array.append(ASCII.LeftSquare[0]);

    if (setting.bold) {
        try array.append(ASCII.@"1"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.dim) {
        try array.append(ASCII.@"2"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.italic) {
        try array.append(ASCII.@"3"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.underline) {
        try array.append(ASCII.@"4"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.blinking) {
        try array.append(ASCII.@"5"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.inverse) {
        try array.append(ASCII.@"7"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.hidden) {
        try array.append(ASCII.@"8"[0]);
        try array.append(ASCII.Semi[0]);
    }

    if (setting.strikethrough) {
        try array.append(ASCII.@"9"[0]);
        try array.append(ASCII.Semi[0]);
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
        try array.appendSlice(colorResultBuf);
    }

    _ = array.pop();
    try array.append(ASCII.m[0]);
    return array.slice();
}
test "strikethroughstyle" {
    const result = try style(.{ .strikethrough = true });
    const expetc = "\x1b[9m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
test "hiddenstyle" {
    const result = try style(.{ .hidden = true });
    const expetc = "\x1b[8m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
test "inversestyle" {
    const result = try style(.{ .inverse = true });
    const expetc = "\x1b[7m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "blinkingstyle" {
    const result = try style(.{ .blinking = true });
    const expetc = "\x1b[5m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "underlinestyle" {
    const result = try style(.{ .underline = true });
    const expetc = "\x1b[4m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "dimstyle" {
    const result = try style(.{ .dim = true });
    const expetc = "\x1b[2m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
test "italicstyle" {
    const result = try style(.{ .italic = true });
    const expetc = "\x1b[3m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}

test "boldstyle" {
    const result = try style(.{ .bold = true });
    const expetc = "\x1b[1m";

    try std.testing.expectEqualSlices(u8, expetc, result);
}
