const std = @import("std");
const cursor = @import("move_cursor.zig");
const Allocator = std.mem.Allocator;

pub fn drawPoint(allocator: Allocator, x: u16, y: u16, char: ?u8) ![]const u8 {
    var bufArray = std.ArrayList(u8).init(allocator);

    try bufArray.appendSlice(try cursor.to(allocator, x, y));

    if (char) |value| {
        try bufArray.append(value);
    } else {
        try bufArray.append('*');
    }

    return bufArray.items;
}

pub fn drawVLine(allocator: Allocator, x: u16, y1: u16, y2: u16, char: ?u8) ![]const u8 {
    const topY = if (y1 < y2) y1 else y2;
    const bottomY = if (y1 < y2) y2 else y1;

    var useChar: u8 = '*';
    if (char) |val| {
        useChar = val;
    }

    var bufArray = std.ArrayList(u8).init(allocator);

    try bufArray.appendSlice(try cursor.to(allocator, topY, x));

    for (topY..bottomY) |_| {
        try bufArray.append(useChar);
        try bufArray.appendSlice(try cursor.down(allocator, 1));
        try bufArray.appendSlice(cursor.backSpace);
    }

    return bufArray.items;
}
