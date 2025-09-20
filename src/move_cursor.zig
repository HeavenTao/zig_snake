const std = @import("std");
const Control = @import("control_code.zig");
const ASCII = @import("ascii_code.zig");
const BufError = @import("error.zig").BufError;
const Allocator = std.mem.Allocator;

pub const home = Control.ESC ++ ASCII.LeftSquare ++ ASCII.H;

pub const hide = Control.ESC ++ ASCII.LeftSquare ++ "?25l";
pub const show = Control.ESC ++ ASCII.LeftSquare ++ "?25h";

/// x,y 1 based
pub fn to(allocator: Allocator, x: u16, y: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{};{}" ++ ASCII.H, .{ y, x });
}

test "to" {
    const allocator = std.testing.allocator;
    const result = try to(allocator, 0, 0);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 48, 59, 48, 72 };

    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

test "to2" {
    const allocator = std.testing.allocator;
    const result = try to(allocator, 11, 11);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 49, 49, 59, 49, 49, 72 };

    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

pub fn up(allocator: Allocator, y: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.A, .{y});
}

pub fn down(allocator: Allocator, y: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.B, .{y});
}

pub fn left(allocator: Allocator, x: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.D, .{x});
}

pub fn right(allocator: Allocator, x: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.C, .{x});
}

test "up" {
    var allocator = std.testing.allocator;
    const result = try up(allocator, 2);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 50, 65 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "down" {
    var allocator = std.testing.allocator;
    const result = try down(allocator, 2);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 50, 66 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "left" {
    var allocator = std.testing.allocator;
    const result = try left(allocator, 2);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 50, 68 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "right" {
    var allocator = std.testing.allocator;
    const result = try right(allocator, 2);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 50, 67 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn beginOfNextLines(allocator: Allocator, y: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.E, .{y});
}

test "beginOfNextLines" {
    var allocator = std.testing.allocator;
    const result = try beginOfNextLines(allocator, 1);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 49, 69 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn beginOfPreviousLines(allocator: Allocator, y: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.F, .{y});
}

test "beginOfPreviousLines" {
    var allocator = std.testing.allocator;
    const result = try beginOfPreviousLines(allocator, 1);
    defer allocator.free(result);

    const expect = [_]u8{ 27, 91, 49, 70 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn toColumns(allocator: Allocator, x: u16) ![]const u8 {
    return std.fmt.allocPrint(allocator, Control.ESC ++ ASCII.LeftSquare ++ "{}" ++ ASCII.G, .{x});
}

test "toColumns" {
    var allocator = std.testing.allocator;
    const result = try toColumns(allocator, 1);
    defer allocator.free(result);

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

pub const backSpace = Control.BS;
