const std = @import("std");
const BufError = @import("error.zig").BufError;
const Control = @import("control_code.zig");
const ASCII = @import("ascii_code.zig");

pub const cursorToScreenEnd = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"0" ++ ASCII.J;

test "cursorToScreenEnd" {
    const expect = [_]u8{ 27, 91, 48, 74 };

    try std.testing.expectEqualSlices(u8, &expect, cursorToScreenEnd);
}

pub const screenStartToCursor = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"1" ++ ASCII.J;

test "screenStartToCursor" {
    const expect = [_]u8{ 27, 91, 49, 74 };
    try std.testing.expectEqualSlices(u8, &expect, screenStartToCursor);
}

pub const entireScreen = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"2" ++ ASCII.J;

test "entireScreen" {
    const expect = [_]u8{ 27, 91, 50, 74 };
    try std.testing.expectEqualSlices(u8, &expect, entireScreen);
}

pub const savedLines = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"3" ++ ASCII.J;

test "savedLines" {
    const expect = [_]u8{ 27, 91, 51, 74 };
    try std.testing.expectEqualSlices(u8, &expect, savedLines);
}

pub const cursorToLineEnd = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"0" ++ ASCII.K;

test "cursorToLineEnd" {
    const expect = [_]u8{ 27, 91, 48, 75 };
    try std.testing.expectEqualSlices(u8, &expect, cursorToLineEnd);
}

pub const lineStartToCursor = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"1" ++ ASCII.K;

test "lineStartToCursor" {
    const expect = [_]u8{ 27, 91, 49, 75 };
    try std.testing.expectEqualSlices(u8, &expect, lineStartToCursor);
}

pub const entireLine = Control.ESC ++ ASCII.LeftSquare ++ ASCII.@"2" ++ ASCII.K;

test "entireLine" {
    const expect = [_]u8{ 27, 91, 50, 75 };
    try std.testing.expectEqualSlices(u8, &expect, entireLine);
}
