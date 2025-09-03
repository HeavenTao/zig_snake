const std = @import("std");
const BufError = @import("error.zig").BufError;
const Control = @import("control_code.zig").Control;
const ASCII = @import("ascii_code.zig").ASCII;

fn common(buf: []u8, num: ASCII, char: ASCII) ![]const u8 {
    if (buf.len < 4) {
        return BufError.notEnoughLength;
    }

    var cur: usize = 0;
    buf[cur] = @intFromEnum(Control.ESC);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftSquare);
    cur += 1;
    buf[cur] = @intFromEnum(num);
    cur += 1;
    buf[cur] = @intFromEnum(char);
    return buf[0..(cur + 1)];
}

pub fn cursorToScreenEnd(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"0", ASCII.J);
}

test "cursorToScreenEnd" {
    var buf: [10]u8 = undefined;

    const result = try cursorToScreenEnd(&buf);
    const expect = [_]u8{ 27, 91, 48, 74 };

    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn screenStartToCursor(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"1", ASCII.J);
}

test "screenStartToCursor" {
    var buf: [10]u8 = undefined;
    const result = try screenStartToCursor(&buf);
    const expect = [_]u8{ 27, 91, 49, 74 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn entireScreen(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"2", ASCII.J);
}

test "entireScreen" {
    var buf: [10]u8 = undefined;
    const result = try entireScreen(&buf);
    const expect = [_]u8{ 27, 91, 50, 74 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn savedLines(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"3", ASCII.J);
}

test "savedLines" {
    var buf: [10]u8 = undefined;
    const result = try savedLines(&buf);
    const expect = [_]u8{ 27, 91, 51, 74 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn cursorToLineEnd(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"0", ASCII.K);
}

test "cursorToLineEnd" {
    var buf: [10]u8 = undefined;
    const result = try cursorToLineEnd(&buf);
    const expect = [_]u8{ 27, 91, 48, 75 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn lineStartToCursor(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"1", ASCII.K);
}

test "lineStartToCursor" {
    var buf: [10]u8 = undefined;
    const result = try lineStartToCursor(&buf);
    const expect = [_]u8{ 27, 91, 49, 75 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn entireLine(buf: []u8) ![]const u8 {
    return common(buf, ASCII.@"2", ASCII.K);
}

test "entireLine" {
    var buf: [10]u8 = undefined;
    const result = try entireLine(&buf);
    const expect = [_]u8{ 27, 91, 50, 75 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}
