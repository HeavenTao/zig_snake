const std = @import("std");
const cursor = @import("move_cursor.zig");
const erase = @import("erase.zig");
const drawer = @import("drawer.zig");
const getTermSize = @import("termSize.zig").getTermSize;
const Size = @import("termSize.zig").Size;
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");

pub const Playground = struct {
    size: Size = .{ .h = 0, .w = 0 },
    allocator: Allocator,

    pub fn init(allocator: Allocator) !Playground {
        return .{ .allocator = allocator };
    }

    pub fn start(self: *Playground) !void {
        try enableRaw();
        try hideCursor();
        try self.initSize();

        var buf: [1024]u8 = undefined;

        var stdout_writer = std.fs.File.stdout().writer(&buf);
        var stdout = &stdout_writer.interface;

        // var readBuf: [20]u8 = undefined;
        // var stdin_reader = std.fs.File.stdin().reader(&readBuf);
        // var stdin = &stdin_reader.interface;

        // _ = try stdout.write(try drawer.drawPoint(self.allocator, 5, 5, null));
        // _ = try stdout.write(try drawer.drawVLine(self.allocator, 20, 1, 41, '#'));
        while (true) {
            _ = try stdout.write(try drawer.drawRect(self.allocator, 10, 15, 20, 30));

            _ = try stdout.write(cursor.home);

            try stdout.flush();

            // _ = try stdin.takeByte();
        }
    }

    pub fn initSize(self: *Playground) !void {
        const size = getTermSize();
        if (size) |val| {
            self.size = val;
            // std.debug.print("w:{},h:{}", .{ self.size.w, self.size.h });
        } else {
            @panic("can not get TermSize");
        }
        // const nextLineBuf = try cursor.beginOfNextLines(self.allocator, self.size.h);
        //
        // var buf: [100]u8 = undefined;
        // var stdout_writer = std.fs.File.stdout().writer(&buf);
        // var stdout = &stdout_writer.interface;
        // _ = try stdout.write(nextLineBuf);
        // try stdout.flush();
    }

    fn hideCursor() !void {
        var buf: [10]u8 = undefined;
        var stdout_writer = std.fs.File.stdout().writer(&buf);
        var stdout = &stdout_writer.interface;
        _ = try stdout.write(cursor.hide);
        try stdout.flush();
    }

    fn enableRaw() !void {
        var old_termios = try std.posix.tcgetattr(std.fs.File.stdout().handle);
        //回显输入关闭
        old_termios.lflag.ECHO = false;
        //关闭回车输入
        old_termios.lflag.ICANON = false;

        try std.posix.tcsetattr(std.fs.File.stdout().handle, std.posix.TCSA.FLUSH, old_termios);
    }
};

test "playgorund start" {
    var arean = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arean.deinit();

    const allocator = arean.allocator();
    var playground = try Playground.init(allocator);

    try playground.start();
}
