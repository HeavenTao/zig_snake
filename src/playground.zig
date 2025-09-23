const std = @import("std");
const cursor = @import("move_cursor.zig");
const erase = @import("erase.zig");
const drawer = @import("drawer.zig");
const getTermSize = @import("termSize.zig").getTermSize;
const Size = @import("termSize.zig").Size;
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");

const Rect = struct { x: u16, y: u16, w: u16, h: u16 };

const Point = struct { x: u16, y: u16 };

const Egg = struct {
    position: Point,

    fn init() Egg {
        return .{ .position = .{ .x = 0, .y = 0 } };
    }

    fn resetPosition(self: *Egg, w: u16, h: u16) void {
        const r: u64 = @intCast(std.time.nanoTimestamp());
        var prng = std.Random.DefaultPrng.init(r);
        var random = prng.random();
        const eggX = random.uintLessThan(u16, w);
        const eggY = random.uintLessThan(u16, h);
        self.position = .{ .x = eggX, .y = eggY };
    }
};

const Snake = struct {
    allocator: Allocator,
    body: std.ArrayList(Point),
    dir: u8 = 'd',

    fn init(allocator: Allocator) !Snake {
        var body = try std.ArrayList(Point).initCapacity(allocator, 10);
        try body.append(allocator, .{ .x = 10, .y = 3 });
        try body.append(allocator, .{ .x = 9, .y = 3 });
        try body.append(allocator, .{ .x = 8, .y = 3 });

        return .{ .allocator = allocator, .body = body };
    }

    pub fn eat(self: *Snake, egg: *Egg) !void {
        const eggPosition = egg.position;

        try self.body.append(self.allocator, .{ .x = eggPosition.x, .y = eggPosition.y });
    }

    fn bodyMove(self: *Snake) void {
        for (1..self.body.items.len) |idx| {
            const curIdx = self.body.items.len - idx;
            const pre = &self.body.items[curIdx - 1];
            const cur = &self.body.items[curIdx];

            cur.x = pre.x;
            cur.y = pre.y;
        }
    }

    pub fn moveLeft(self: *Snake) void {
        self.dir = 'a';
        self.bodyMove();
        const head = &self.body.items[0];
        head.x -= 1;
    }
    pub fn moveRight(self: *Snake) void {
        self.dir = 'd';
        self.bodyMove();
        const head = &self.body.items[0];
        head.x += 1;
    }

    pub fn moveUp(self: *Snake) void {
        self.dir = 'w';
        self.bodyMove();
        const head = &self.body.items[0];
        head.y -= 1;
    }

    pub fn moveDown(self: *Snake) void {
        self.dir = 's';
        self.bodyMove();
        const head = &self.body.items[0];
        head.y += 1;
    }
};

pub const Playground = struct {
    allocator: Allocator,
    size: Size = .{ .h = 0, .w = 0 },
    wall: Rect = .{ .x = 1, .y = 1, .w = 0, .h = 0 },
    snake: Snake,
    egg: Egg,

    pub fn init(allocator: Allocator) !Playground {
        return .{ .allocator = allocator, .snake = try Snake.init(allocator), .egg = Egg.init() };
    }

    pub fn start(self: *Playground) !void {
        try enableRaw();
        try hideCursor();
        try self.initSize();

        _ = try std.Thread.spawn(.{}, startDrawThread, .{self});

        try self.startInputThread();
    }

    fn startDrawThread(self: *Playground) !void {
        var buf: [1024]u8 = undefined;
        var stdout_writer = std.fs.File.stdout().writer(&buf);
        var stdout = &stdout_writer.interface;

        const base_allocator = std.heap.page_allocator;
        var gpa = std.heap.ArenaAllocator.init(base_allocator);
        defer gpa.deinit();

        const allocator = gpa.allocator();

        while (true) {
            defer _ = gpa.reset(.retain_capacity);

            _ = try stdout.write(erase.entireScreen);

            //draw walls
            {
                _ = try stdout.write(try drawer.drawRect(allocator, self.wall.x, self.wall.y, self.wall.w, self.wall.h));
            }

            //draw snakes
            {
                for (0..self.snake.body.items.len) |idx| {
                    const p = &self.snake.body.items[idx];
                    _ = try stdout.write(try drawer.drawPoint(allocator, p.x, p.y, 64));
                }
            }

            //draw egg
            {
                _ = try stdout.write(try drawer.drawPoint(allocator, self.egg.position.x, self.egg.position.y, null));
            }

            _ = try stdout.write(cursor.home);

            try stdout.flush();

            std.Thread.sleep(std.time.ns_per_ms * 100);
        }
    }

    fn startInputThread(self: *Playground) !void {
        var stdin_buf: [10]u8 = undefined;
        var stdin_reader = std.fs.File.stdin().reader(&stdin_buf);
        var stdin = &stdin_reader.interface;

        while (stdin.takeByte()) |byte| {
            if (byte == 'q') {
                break;
            }

            if (byte == 'd') {
                self.snake.moveRight();
            } else if (byte == 'a') {
                self.snake.moveLeft();
            } else if (byte == 'w') {
                self.snake.moveUp();
            } else if (byte == 's') {
                self.snake.moveDown();
            }

            //check wall
            if (!self.checkWall()) {
                break;
            }

            if (self.checkEgg()) {
                self.egg.resetPosition(self.size.w, self.size.h);
                try self.snake.eat(&self.egg);
            }
        } else |err| {
            std.debug.print("err,{}", .{err});
        }
    }

    fn checkWall(self: *Playground) bool {
        const snake_head = self.snake.body.items[0];
        if (snake_head.x == self.wall.x) {
            return false;
        } else if (snake_head.y == self.wall.y) {
            return false;
        } else if (snake_head.x == (self.wall.x + self.wall.w - 1)) {
            return false;
        } else if (snake_head.y == (self.wall.y + self.wall.h - 1)) {
            return false;
        }
        return true;
    }

    fn checkEgg(self: *Playground) bool {
        const snake_head = self.snake.body.items[0];
        if (snake_head.x == self.egg.position.x and snake_head.y == self.egg.position.y) {
            return true;
        } else {
            return false;
        }
    }

    fn initSize(self: *Playground) !void {
        const size = getTermSize();
        if (size) |val| {
            self.size = val;
        } else {
            @panic("can not get TermSize");
        }

        self.wall = .{
            .x = 1,
            .y = 1,
            .w = self.size.w,
            .h = self.size.h,
        };

        self.egg.resetPosition(self.size.w, self.size.h);
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
