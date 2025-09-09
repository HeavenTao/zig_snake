const std = @import("std");
const cursor = @import("move_cursor.zig");
const erase = @import("erase.zig");
const drawer = @import("drawer.zig");
const getTermSize = @import("termSize.zig").getTermSize;
const Size = @import("termSize.zig").Size;
const Allocator = std.mem.Allocator;

pub const Playground = struct {
    stdOut: std.fs.File = std.io.getStdOut(),
    writer: std.fs.File.Writer,
    size: Size = .{ .h = 0, .w = 0 },
    allocator: Allocator,

    pub fn init(allocator: Allocator) Playground {
        return .{ .stdOut = std.io.getStdOut(), .writer = std.io.getStdOut().writer(), .allocator = allocator };
    }

    pub fn start(self: *Playground) !void {
        try self.enableRaw();
        try self.hideCursor();
        try self.initSize();

        // _ = try self.writer.write(try drawer.drawPoint(self.allocator, 5, 5, null));
        _ = try self.writer.write(try drawer.drawVLine(self.allocator, 10, 5, 20, '#'));

        const reader = std.io.getStdIn().reader();
        var readerBuf: [10]u8 = undefined;

        _ = try reader.read(&readerBuf);
    }

    pub fn initSize(self: *Playground) !void {
        const size = getTermSize();
        if (size) |val| {
            self.size = val;
        } else {
            _ = try self.writer.print("can not get TerSize", .{});
            @panic("can not get TermSize");
        }
        const nextLineBuf = try cursor.beginOfNextLines(self.allocator, self.size.h);

        _ = try self.writer.write(nextLineBuf);
    }

    fn hideCursor(self: *Playground) !void {
        _ = try self.writer.write(cursor.hide);
    }

    fn enableRaw(self: *Playground) !void {
        var old_termios = try std.posix.tcgetattr(self.stdOut.handle);
        //回显输入关闭
        old_termios.lflag.ECHO = false;
        //关闭回车输入
        old_termios.lflag.ICANON = false;

        try std.posix.tcsetattr(self.stdOut.handle, std.posix.TCSA.FLUSH, old_termios);
    }
};

test "playgorund start" {
    var arean = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arean.deinit();

    const allocator = arean.allocator();
    var playground = Playground.init(allocator);

    try playground.start();
}
