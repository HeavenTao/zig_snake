const std = @import("std");
const getTermSize = @import("termSize.zig").getTermSize;
const cursor = @import("move_cursor.zig");
const print = std.debug.print;
const erase = @import("erase.zig");

pub fn main() !void {
    try enableRaw(std.io.getStdOut().handle);

    const size = getTermSize();
    if (size == null) {
        @panic("no term size");
    }

    // var bigBuf: [1024]u8 = undefined;
    // var cur: usize = 0;
    // const helloWorld = "he";
    //
    // @memcpy(bigBuf[0..helloWorld.len], helloWorld);
    // cur += helloWorld.len;
    //
    // var buf: [10]u8 = undefined;
    // const homeBuf = try cursor.left(2, &buf);
    //
    // @memcpy(bigBuf[cur..(cur + homeBuf.len)], homeBuf);
    // cur = cur + homeBuf.len;
    //
    // const number = "2";
    // @memcpy(bigBuf[cur..(cur + number.len)], number);
    // cur += number.len;
    //
    const writer = std.io.getStdOut().writer();
    try writer.print("helloWorld1\nhelloworld2", .{});

    const eraseBuf: [4]u8 = try erase.entireScreen();
    _ = try writer.write(&eraseBuf);

    const reader = std.io.getStdIn().reader();
    var readerBuf: [10]u8 = undefined;
    _ = try reader.read(&readerBuf);
}

fn enableRaw(fd_t: std.posix.fd_t) !void {
    var old_termios = try std.posix.tcgetattr(fd_t);

    //回显输入关闭
    old_termios.lflag.ECHO = false;
    //关闭回车输入
    old_termios.lflag.ICANON = false;

    try std.posix.tcsetattr(fd_t, std.posix.TCSA.FLUSH, old_termios);
}
