const std = @import("std");
const getTermSize = @import("termSize.zig").getTermSize;
const cursor = @import("move_cursor.zig");
const print = std.debug.print;
const erase = @import("erase.zig");
const style = @import("style.zig");
const Playground = @import("playground.zig").Playground;

pub fn main() !void {
    var playground = try Playground.init();
    try playground.start();
}
