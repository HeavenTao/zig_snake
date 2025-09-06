const std = @import("std");
const cursor = @import("move_cursor.zig");
const erase = @import("erase.zig");
pub const Playground = struct {
    stdOut: std.fs.File = std.io.getStdOut(),

    pub fn init() Playground {
        return .{};
    }

    pub fn start(self: *Playground) !void {
        try self.enableRaw();
        try self.hideCursor();

        const writer = self.stdOut.writer();
        const reader = std.io.getStdIn().reader();
        var readerBuf: [10]u8 = undefined;
        // var writerBuf: [30]u8 = undefined;

        while (true) {
            const size = try reader.read(&readerBuf);
            _ = try writer.write(erase.screenStartToCursor);
            _ = try writer.write(cursor.home);
            std.debug.print("you input {s}\n", .{readerBuf[0..size]});
        }
    }

    fn hideCursor(self: *Playground) !void {
        var writer = self.stdOut.writer();
        _ = try writer.write(cursor.hide);
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
