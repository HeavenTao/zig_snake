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

    try bufArray.appendSlice(allocator, try cursor.to(allocator, topY, x));

    for (topY..bottomY) |_| {
        try bufArray.append(allocator, useChar);
        try bufArray.appendSlice(allocator, try cursor.down(allocator, 1));
        try bufArray.appendSlice(allocator, cursor.backSpace);
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

    try burArray.appendSlice(allocator, try cursor.to(allocator, y, leftX));

    for (leftX..rightX) |_| {
        try burArray.append(allocator, useChar);
    }

    return burArray.items;
}
