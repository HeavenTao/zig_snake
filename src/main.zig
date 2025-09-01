const std = @import("std");
const getTermSize = @import("termSize.zig").getTermSize;
const cursor = @import("move_cursor.zig");
const print = std.debug.print;

pub fn main() !void {
    try enableRaw(std.io.getStdOut().handle);

    const size = getTermSize();
    if (size == null) {
        @panic("no term size");
    }

    const writer = std.io.getStdOut().writer();
    try writer.print("hello world", .{});

    var buf: [10]u8 = undefined;

    const result = try cursor.toColumns(15, &buf);

    _ = try writer.write(result);

    try writer.print("and so on\n", .{});

    const posBuf = try cursor.getPosition(&buf);

    _ = try writer.write(posBuf);

    const reader = std.io.getStdIn().reader();

    var readBuf: [20]u8 = undefined;
    const readSize = try reader.read(&readBuf);

    print("{any}", .{readBuf[0..readSize]});
}

fn enableRaw(fd_t: std.posix.fd_t) !void {
    var old_termios = try std.posix.tcgetattr(fd_t);

    //回显输入关闭
    old_termios.lflag.ECHO = false;
    //关闭回车输入
    old_termios.lflag.ICANON = false;

    try std.posix.tcsetattr(fd_t, std.posix.TCSA.FLUSH, old_termios);
}
