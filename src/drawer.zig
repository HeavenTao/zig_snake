const std = @import("std");
const cursor = @import("move_cursor.zig");

pub fn drawPoint(buf: []u8, x: u16, y: u16, char: ?u8) ![]const u8 {
    var bufArray = try std.BoundedArray(u8, 30).init(0);
    var temp: [30]u8 = undefined;

    try bufArray.appendSlice(try cursor.to(&temp, x, y));

    if (char) |value| {
        try bufArray.append(value);
    } else {
        try bufArray.append('*');
    }

    @memcpy(buf[0..bufArray.len], bufArray.slice());
    return buf[0..bufArray.len];
}

pub fn drawLine(buf: []u8, x1: u16, y1: u16, x2: u16, y2: u16) !void {
    const leftX: u8 = if (x1 < x2) x1 orelse x2;
    const leftY: u8 = if (y1 < y2) y1 orelse y2;
    const rightX: u8 = if (x1 < x2) x2 orelse x1;
    const rightY: u8 = if (y1 < y2) y2 orelse y1;

    var x: u16 = 0;
    var y: u16 = 0;
}
