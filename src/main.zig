const std = @import("std");
const TermSize = @import("termSize.zig");
const cursor = @import("cursorMove.zig");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();

    const a = allocator.allocator();

    const size = TermSize.getTermSize();

    try drawWalls(size.?, a);
}

fn drawWalls(size: TermSize.Size, allocator: std.mem.Allocator) !void {
    try drawW(allocator, size.w);
    try drawH(allocator, size.h, size.w);
    try drawW(allocator, size.w);
}

fn drawH(allocator: Allocator, height: u16, width: u16) !void {
    for (0..height) |_| {
        try cursor.MoveBgeinOfNextLine(allocator);
        print("|", .{});
        try cursor.MoveRight(allocator, width);
        print("|", .{});
    }
}

fn drawW(allocator: Allocator, width: u16) !void {
    var line = try allocator.alloc(u8, width);
    defer allocator.free(line);

    for (0..line.len) |i| {
        line[i] = '-';
    }
    print("{s}", .{line});
}
