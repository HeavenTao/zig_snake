const std = @import("std");
const TermSize = @import("termSize.zig");
const cursor = @import("cursorMove.zig");
const print = std.debug.print;

pub fn main() !void {
    const writer = std.io.getStdOut().writer();
    const cursorOp = cursor.init(writer);
    const size = TermSize.getTermSize().?;

    // try writer.print("Hello", .{});
    // try cursorOp.BeginOfNextLine(1);
    // try cursorOp.BeginOfNextLine(1);
    // try writer.print("Hello", .{});

    try drawWall(cursorOp, size, writer);
}

fn drawWall(cursorOp: cursor.CursorOp, size: TermSize.Size, writer: std.fs.File.Writer) !void {
    try cursorOp.Home();
    for (0..size.w) |_| {
        try writer.print("\u{2501}", .{});
    }
    for (0..size.h - 5) |_| {
        try cursorOp.BeginOfNextLine(1);
        try writer.print("\u{2503}", .{});
    }
    // for (0..size.w - 1) |_| {
    //     try writer.print("\u{2501}", .{});
    // }
}
