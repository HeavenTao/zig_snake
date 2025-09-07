const std = @import("std");
const Control = @import("control_code.zig");
const ASCII = @import("ascii_code.zig");
const BufError = @import("error.zig").BufError;

pub const home = Control.ESC ++ ASCII.LeftSquare ++ ASCII.H;

pub const hide = Control.ESC ++ ASCII.LeftSquare ++ "?25l";
pub const show = Control.ESC ++ ASCII.LeftSquare ++ "?25h";

pub fn to(buf: []u8, line: u16, column: u16) ![]const u8 {
    if (buf.len < 10) {
        return BufError.notEnoughLength;
    }
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{};{}" ++ ASCII.H, .{ line, column });
}

test "to" {
    var buf: [10]u8 = undefined;
    const result = try to(&buf, 0, 0);

    const expect = [_]u8{ 27, 91, 48, 59, 48, 72 };

    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

test "to2" {
    var buf: [20]u8 = undefined;
    const result = try to(&buf, 11, 11);

    const expect = [_]u8{ 27, 91, 49, 49, 59, 49, 49, 72 };

    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

pub fn up(buf: []u8, lines: u16) ![]const u8 {
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.A, .{lines});
}

pub fn down(buf: []u8, lines: u16) ![]const u8 {
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.B, .{lines});
}

pub fn left(buf: []u8, columns: u16) ![]const u8 {
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.D, .{columns});
}

pub fn right(buf: []u8, columns: u16) ![]const u8 {
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.C, .{columns});
}

test "up" {
    var buf: [10]u8 = undefined;
    const result = try up(&buf, 2);

    const expect = [_]u8{ 27, 91, 50, 65 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "down" {
    var buf: [10]u8 = undefined;
    const result = try down(&buf, 2);

    const expect = [_]u8{ 27, 91, 50, 66 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "left" {
    var buf: [10]u8 = undefined;
    const result = try left(&buf, 2);

    const expect = [_]u8{ 27, 91, 50, 68 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "right" {
    var buf: [10]u8 = undefined;
    const result = try right(&buf, 2);

    const expect = [_]u8{ 27, 91, 50, 67 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn beginOfNextLines(buf: []u8, lines: u16) ![]const u8 {
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.E, .{lines});
}

test "beginOfNextLines" {
    var buf: [10]u8 = undefined;
    const result = try beginOfNextLines(&buf, 1);
    const expect = [_]u8{ 27, 91, 49, 69 };

    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn beginOfPreviousLines(buf: []u8, lines: u16) ![]const u8 {
    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.F, .{lines});
}

test "beginOfPreviousLines" {
    var buf: [10]u8 = undefined;
    const result = try beginOfPreviousLines(&buf, 1);
    const expect = [_]u8{ 27, 91, 49, 70 };

    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn toColumns(buf: []u8, columns: u16) ![]const u8 {
    if (buf.len < 4) {
        return BufError.notEnoughLength;
    }

    return std.fmt.bufPrint(buf, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.G, .{columns});
}

test "toColumns" {
    var buf: [10]u8 = undefined;
    const result = try toColumns(&buf, 1);
    const expect = [_]u8{ 27, 91, 49, 71 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub const getPosition = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"6" ++ ASCII.n;

test "getPosition" {
    const expect = [_]u8{ 27, 91, 54, 110 };

    try std.testing.expectEqualSlices(u8, &expect, getPosition);
}

pub const scrollUpOneLine = Control.ESC ++ ASCII.M;

test "scrollUpOneLine" {
    const expect = [_]u8{ 27, 77 };

    try std.testing.expectEqualSlices(u8, &expect, scrollUpOneLine);
}

pub const saveCursorDEC = Control.ESC ++ ASCII.@"7";

test "saveCursorDEC" {
    const expect = [_]u8{ 27, 55 };
    try std.testing.expectEqualSlices(u8, &expect, saveCursorDEC);
}

pub const restoreCursorDEC = Control.ESC ++ ASCII.@"8";

test "restoreCursorDEC" {
    const expect = [_]u8{ 27, 56 };
    try std.testing.expectEqualSlices(u8, &expect, restoreCursorDEC);
}

pub const saveCursorSCO = Control.ESC ++ ASCII.LeftSquare ++ ASCII.s;

test "saveCursorSCO" {
    const expect = [_]u8{ 27, 91, 115 };
    try std.testing.expectEqualSlices(u8, &expect, saveCursorSCO);
}

pub const restoreCursorSCO = Control.ESC ++ ASCII.LeftSquare ++ ASCII.u;

test "restoreCursorSCO" {
    const expect = [_]u8{ 27, 91, 117 };
    try std.testing.expectEqualSlices(u8, &expect, restoreCursorSCO);
}
