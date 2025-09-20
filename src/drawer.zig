const std = @import("std");
const cursor = @import("move_cursor.zig");
const Allocator = std.mem.Allocator;

pub fn drawPoint(allocator: Allocator, x: u16, y: u16, char: ?u8) ![]const u8 {
    var bufArray = try std.ArrayList(u8).initCapacity(allocator, 15);

    try bufArray.appendSlice(allocator, try cursor.to(allocator, x, y));

    if (char) |value| {
        try bufArray.append(allocator, value);
    } else {
        try bufArray.append(allocator, '*');
    }

    return bufArray.toOwnedSlice(allocator);
}

test "drawPoint" {
    const Control = @import("control_code.zig");
    const ASCII = @import("ascii_code.zig");
    const allocator = std.testing.allocator;
    const result = try drawPoint(allocator, 11, 11, null);

    const expect = [_]u8{
        Control.ESC[0],
        ASCII.LeftSquare[0],
    };

    try std.testing.expectEqualSlices(u8, &expect, result);
}

pub fn drawVLine(allocator: Allocator, x: u16, y1: u16, y2: u16, char: ?u8) ![]const u8 {
    const topY = if (y1 < y2) y1 else y2;
    const bottomY = if (y1 < y2) y2 else y1;

    var useChar: u8 = '*';
    if (char) |val| {
        useChar = val;
    }

    var bufArray = try std.ArrayList(u8).initCapacity(allocator, @as(usize, bottomY - topY));

    try bufArray.appendSlice(allocator, try cursor.to(allocator, x, topY));

    try bufArray.appendSlice(allocator, cursor.saveCursorDEC);

    for (topY..bottomY + 1) |_| {
        try bufArray.append(allocator, useChar);
        try bufArray.appendSlice(allocator, cursor.restoreCursorDEC);
        try bufArray.appendSlice(allocator, try cursor.down(allocator, 1));
        try bufArray.appendSlice(allocator, cursor.saveCursorDEC);
    }

    return bufArray.items;
}

pub fn drawHLine(allocator: Allocator, y: u16, x1: u16, x2: u16, char: ?u8) ![]const u8 {
    const leftX = if (x1 < x2) x1 else x2;
    const rightX = if (x1 < x2) x2 else x1;

    var useChar: u8 = '*';
    if (char) |val| {
        useChar = val;
    }

    var burArray = try std.ArrayList(u8).initCapacity(allocator, @as(usize, rightX - leftX));

    try burArray.appendSlice(allocator, try cursor.to(allocator, leftX, y));

    for (leftX..rightX + 1) |_| {
        try burArray.append(allocator, useChar);
    }

    return burArray.items;
}

pub fn drawRect(allocator: Allocator, x1: u16, y1: u16, x2: u16, y2: u16) ![]const u8 {
    var leftX: u16 = 0;
    var rightX: u16 = 0;
    var topY: u16 = 0;
    var bottomY: u16 = 0;

    if (std.math.compare(x1, .gte, x2)) {
        leftX = x2;
        rightX = x1;
    } else {
        leftX = x1;
        rightX = x2;
    }

    if (std.math.compare(y1, .gte, y2)) {
        topY = y2;
        bottomY = y1;
    } else {
        topY = y1;
        bottomY = y2;
    }

    var array = std.array_list.AlignedManaged(u8, null).init(allocator);

    {
        const lineBuf = try drawHLine(allocator, topY, leftX, rightX, null);
        defer allocator.free(lineBuf);
        try array.appendSlice(lineBuf);
    }
    {
        const lineBuf = try drawVLine(allocator, rightX, topY, bottomY, null);
        defer allocator.free(lineBuf);
        try array.appendSlice(lineBuf);
    }
    {
        const lineBuf = try drawVLine(allocator, leftX, topY, bottomY, null);
        defer allocator.free(lineBuf);
        try array.appendSlice(lineBuf);
    }
    {
        const lineBuf = try drawHLine(allocator, bottomY, leftX, rightX, null);
        defer allocator.free(lineBuf);
        try array.appendSlice(lineBuf);
    }
    return array.items;
}
