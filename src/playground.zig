const std = @import("std");
const cursor = @import("move_cursor.zig");
const erase = @import("erase.zig");
const drawer = @import("drawer.zig");
const getTermSize = @import("termSize.zig").getTermSize;
const Size = @import("termSize.zig").Size;
pub const Playground = struct {
    stdOut: std.fs.File = std.io.getStdOut(),
    writer: std.fs.File.Writer,
    size: Size = .{ .h = 0, .w = 0 },

    pub fn init() Playground {
        return .{ .stdOut = std.io.getStdOut(), .writer = std.io.getStdOut().writer() };
    }

    pub fn start(self: *Playground) !void {
        try self.enableRaw();
        try self.hideCursor();
        try self.initSize();
        var arrayBuf = try std.BoundedArray(u8, 1024).init(0);

        const reader = std.io.getStdIn().reader();
        var readerBuf: [10]u8 = undefined;
        var writerBuf: [30]u8 = undefined;

        var result = try drawer.drawPoint(&writerBuf, self.size.h, 20, '*');
        try arrayBuf.appendSlice(result);
        result = try drawer.drawPoint(&writerBuf, 5, 20, '#');
        try arrayBuf.appendSlice(result);

        _ = try self.writer.write(arrayBuf.slice());

        _ = try reader.read(&readerBuf);
    }

    pub fn initSize(self: *Playground) !void {
        const size = getTermSize();
        if (size) |val| {
            self.size = val;
        } else {
            @panic("can not get TermSize");
        }
        var temp: [10]u8 = undefined;
        const nextLineBuf = try cursor.beginOfNextLines(&temp, self.size.h);
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
