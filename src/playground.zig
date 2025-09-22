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

    pub fn init() !Playground {
        return .{};
    }

    pub fn start(self: *Playground) !void {
        try enableRaw();
        try hideCursor();
        try self.initSize();

        try self.startDrawThread();
    }

    fn startDrawThread(self: *Playground) !void {
        var buf: [1024]u8 = undefined;
        var stdout_writer = std.fs.File.stdout().writer(&buf);
        var stdout = &stdout_writer.interface;

        const base_allocator = std.heap.page_allocator;
        var gpa = std.heap.ArenaAllocator.init(base_allocator);

        var row: u16 = 1;
        while (true) {
            const allocator = gpa.allocator();
            defer _ = gpa.reset(.retain_capacity);

            _ = try stdout.write(erase.entireScreen);
            _ = try stdout.write(try drawer.drawRect(allocator, row, 1, self.size.w, self.size.h));
            _ = try stdout.write(cursor.home);
            try stdout.flush();

            std.Thread.sleep(std.time.ns_per_s);
            row += 1;
        }
    }

    fn startInputThread() !void {}

    fn initSize(self: *Playground) !void {
        const size = getTermSize();
        if (size) |val| {
            self.size = val;
        } else {
            @panic("can not get TermSize");
        }
    }

    fn hideCursor() !void {
        try std.fs.File.stdout().writeAll(cursor.hide);
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
