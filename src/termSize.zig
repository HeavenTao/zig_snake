const std = @import("std");

pub const Size = struct {
    w: u16,
    h: u16,
};

pub fn getTermSize() ?Size {
    const file = std.io.getStdOut();
    var buf: std.posix.winsize = undefined;
    const result = std.posix.system.ioctl(file.handle, std.posix.T.IOCGWINSZ, @intFromPtr(&buf));
    if (result == 0) {
        return Size{ .w = buf.col, .h = buf.row };
    } else {
        return null;
    }
}

const TermSize = @This();
