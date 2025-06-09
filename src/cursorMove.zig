const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const Seq = enum(u8) {
    ESC = 27,
    SquareBracket = 91,
};

const Dirc = enum(u8) {
    Up = 65, //A
    Down = 66, //B
    Right = 67,
    Left = 68,
    BeginOfNextLine = 69,
};

pub fn MoveBgeinOfNextLine(allocator: Allocator) !void {
    try Move(allocator, Dirc.BeginOfNextLine, 1);
}

pub fn MoveUp(allocator: Allocator, num: u16) !void {
    try Move(allocator, Dirc.Up, num);
}

pub fn MoveDown(allocator: Allocator, num: u16) !void {
    try Move(allocator, Dirc.Down, num);
}

pub fn MoveLeft(allocator: Allocator, num: u16) !void {
    try Move(allocator, Dirc.Left, num);
}

pub fn MoveRight(allocator: Allocator, num: u16) !void {
    try Move(allocator, Dirc.Right, num);
}

fn Move(allocator: Allocator, dirc: Dirc, num: u16) !void {
    const str = try std.fmt.allocPrint(allocator, "{}", .{num});
    defer allocator.free(str);

    var result = try allocator.alloc(u8, str.len + 3);
    defer allocator.free(result);
    result[0] = @intFromEnum(Seq.ESC);
    result[1] = @intFromEnum(Seq.SquareBracket);

    var index: usize = 2;
    for (str) |c| {
        result[index] = c;
        index += 1;
    }

    result[index] = @intFromEnum(dirc);
    print("{s}", .{result});
}
