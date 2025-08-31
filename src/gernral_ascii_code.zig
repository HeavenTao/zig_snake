const std = @import("std");
pub const BufError = error{notEnoughLength};

pub const Control = enum(u8) {
    BEL = 7,
    BS = 8,
    ///H-Tab
    HT = 9,
    LF = 10,
    ///V-Tab
    VT = 11,
    FF = 12,
    CR = 13,
    ESC = 27,
    DEL = 127,
};

const ASCII = enum(u8) {
    ///分号；
    Semi = 59,
    A = 65,
    B = 66,
    C = 67,
    D = 68,
    E = 69,
    F = 70,
    H = 72,
    ///左括号[
    LeftSquare = 91,
    ///右括号]
    RightSquare = 93,
    ///左花括号{
    LeftBraces = 123,
    ///右花括号}
    RightBraces = 125,
};

pub fn home(buf: []u8) ![]const u8 {
    if (buf.len < 3) {
        return BufError.notEnoughLength;
    }
    buf[0] = @intFromEnum(Control.ESC);
    buf[1] = @intFromEnum(ASCII.LeftSquare);
    buf[2] = @intFromEnum(ASCII.H);
    return buf[0..3];
}

test "home" {
    var buf: [10]u8 = undefined;
    const result = try home(&buf);
    const expect: [3]u8 = [_]u8{ 27, 91, 72 };
    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

pub fn to(line: u16, column: u16, buf: []u8) ![]const u8 {
    if (buf.len < 10) {
        return BufError.notEnoughLength;
    }
    var temp: [5]u8 = undefined;

    var cur: usize = 0;
    buf[cur] = @intFromEnum(Control.ESC);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftSquare);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftBraces);
    cur += 1;
    const lineBuf = try std.fmt.bufPrint(&temp, "{}", .{line});
    @memcpy(buf[cur..(cur + lineBuf.len)], lineBuf);
    cur += lineBuf.len;
    buf[cur] = @intFromEnum(ASCII.RightBraces);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.Semi);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftBraces);
    cur += 1;
    const columnBuf = try std.fmt.bufPrint(&temp, "{}", .{column});
    @memcpy(buf[cur..(cur + columnBuf.len)], columnBuf);
    cur += columnBuf.len;
    buf[cur] = @intFromEnum(ASCII.RightBraces);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.H);
    return buf[0..(cur + 1)];
}

test "to" {
    var buf: [10]u8 = undefined;
    const result = try to(0, 0, &buf);

    const expect = [_]u8{ 27, 91, 123, 48, 125, 59, 123, 48, 125, 72 };

    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

test "to2" {
    var buf: [20]u8 = undefined;
    const result = try to(11, 11, &buf);

    const expect = [_]u8{ 27, 91, 123, 49, 49, 125, 59, 123, 49, 49, 125, 72 };

    try std.testing.expectEqualSlices(u8, expect[0..], result);
}

pub fn up(lines: u16, buf: []u8) ![]const u8 {
    return move(lines, ASCII.A, buf);
}

pub fn down(lines: u16, buf: []u8) ![]const u8 {
    return move(lines, ASCII.B, buf);
}

pub fn left(columns: u16, buf: []u8) ![]const u8 {
    return move(columns, ASCII.D, buf);
}

pub fn right(columns: u16, buf: []u8) ![]const u8 {
    return move(columns, ASCII.C, buf);
}

fn move(num: u16, dire: ASCII, buf: []u8) ![]const u8 {
    if (buf.len < 4) {
        return BufError.notEnoughLength;
    }
    var temp: [5]u8 = undefined;
    const linesBuf = try std.fmt.bufPrint(&temp, "{}", .{num});
    var cur: usize = 0;
    buf[cur] = @intFromEnum(Control.ESC);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftSquare);
    cur += 1;
    @memcpy(buf[cur..(cur + linesBuf.len)], linesBuf);
    cur += linesBuf.len;
    buf[cur] = @intFromEnum(dire);
    return buf[0..(cur + 1)];
}

test "up" {
    var buf: [10]u8 = undefined;
    const result = try up(2, &buf);

    const expect = [_]u8{ 27, 91, 50, 65 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "down" {
    var buf: [10]u8 = undefined;
    const result = try down(2, &buf);

    const expect = [_]u8{ 27, 91, 50, 66 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "left" {
    var buf: [10]u8 = undefined;
    const result = try left(2, &buf);

    const expect = [_]u8{ 27, 91, 50, 68 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

test "right" {
    var buf: [10]u8 = undefined;
    const result = try right(2, &buf);

    const expect = [_]u8{ 27, 91, 50, 67 };
    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn beginOfNextLines(lines: u16, buf: []u8) ![]const u8 {
    if (buf.len < 4) {
        return BufError.notEnoughLength;
    }

    var temp: [5]u8 = undefined;

    const linesBuf = try std.fmt.bufPrint(&temp, "{}", .{lines});
    var cur: usize = 0;
    buf[cur] = @intFromEnum(Control.ESC);
    cur += 1;
    buf[cur] = @intFromEnum(ASCII.LeftSquare);
    cur += 1;
    @memcpy(buf[cur..(cur + linesBuf.len)], linesBuf);
    cur += linesBuf.len;
    buf[cur] = @intFromEnum(ASCII.E);
    return buf[0..(cur + 1)];
}

test "beginOfNextLines" {
    var buf: [10]u8 = undefined;
    const result = try beginOfNextLines(1, &buf);
    const expect = [_]u8{ 27, 91, 49, 69 };

    try std.testing.expectEqualSlices(u8, &expect, result);
}
