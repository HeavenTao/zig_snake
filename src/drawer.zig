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
