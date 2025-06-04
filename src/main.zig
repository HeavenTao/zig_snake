const std = @import("std");
pub fn main() !void {
    const termSize = getTermSize();
    // if (termSize) |value| {
    //     std.debug.print("{},{}", .{ value.h, value.w });
    // } else {
    //     std.debug.print("no size", .{});
    // }

    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer allocator.deinit();
    const a = allocator.allocator();
    try drawWalls(termSize.?, a);
}

fn drawWalls(size: TermSize, allocator: std.mem.Allocator) !void {
    var line = try allocator.alloc(u8, size.w);
    for (0..line.len) |i| {
        line[i] = '=';
    }
    std.debug.print("{s}", .{line});
}

const TermSize = struct { w: u16, h: u16 };

fn getTermSize() ?TermSize {
    const file = std.io.getStdOut();
    var buf: std.posix.winsize = undefined;
    const result = std.posix.system.ioctl(file.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&buf));
    if (result == 0) {
        return TermSize{ .w = buf.col, .h = buf.row };
    } else {
        return null;
    }
}
