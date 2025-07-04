const std = @import("std");

pub fn init(writer: std.fs.File.Writer) CursorOp {
    return .{ .writer = writer };
}

pub const CursorOp = struct {
    writer: std.fs.File.Writer,

    pub fn Backspace(self: CursorOp) !void {
        try self.writer.print("\x08", .{});
    }

    pub fn Bell(self: CursorOp) !void {
        try self.writer.print("\x07", .{});
    }

    pub fn HorizontalTab(self: CursorOp) !void {
        try self.writer.print("\x09", .{});
    }

    pub fn Newline(self: CursorOp) !void {
        try self.writer.print("\x0A", .{});
    }

    pub fn Return(self: CursorOp) !void {
        try self.writer.print("\x0D", .{});
    }

    pub fn Delete(self: CursorOp) !void {
        try self.writer.print("\x7F", .{});
    }

    pub fn Esc(self: CursorOp) !void {
        try self.writer.print("\x1B", .{});
    }

    pub fn Home(self: CursorOp) !void {
        try self.Esc();
        try self.LeftSquare();
        try self.writer.print("H", .{});
    }

    pub fn LeftSquare(self: CursorOp) !void {
        try self.writer.print("[", .{});
    }

    pub fn Down(self: CursorOp, lines: u16) !void {
        try self.moveCursor("B", lines);
    }

    pub fn Up(self: CursorOp, lines: u16) !void {
        try self.moveCursor("A", lines);
    }

    pub fn Left(self: CursorOp, lines: u16) !void {
        try self.moveCursor("D", lines);
    }

    pub fn Right(self: CursorOp, lines: u16) !void {
        try self.moveCursor("C", lines);
    }

    pub fn BeginOfNextLine(self: CursorOp, lines: u16) !void {
        var buf: [5]u8 = undefined;
        const numStr = try toString(lines, &buf);
        try self.Esc();
        try self.LeftSquare();
        try self.writer.print("{s}", .{numStr});
        try self.writer.print("E", .{});
    }

    fn moveCursor(self: CursorOp, dire: *const [1:0]u8, num: u16) !void {
        var buf: [5]u8 = undefined;
        const numStr = try toString(num, &buf);
        try self.Esc();
        try self.LeftSquare();
        try self.writer.print("{s}", .{numStr});
        try self.writer.print("{s}", .{dire});
    }

    fn toString(num: u16, buf: *[5]u8) ![]u8 {
        const numStr = try std.fmt.bufPrint(buf, "{}", .{num});
        return numStr;
    }
};
