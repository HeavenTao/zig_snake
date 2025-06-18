const std = @import("std");
const TermSize = @import("termSize.zig");
const cursor = @import("cursorMove2.zig");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

pub fn main() !void {
    const writer = std.io.getStdOut().writer();
    const cursorOp = cursor.init(writer);
    try writer.print("hello", .{});
    try cursorOp.Down(5);
    try cursorOp.Up(3);
}
