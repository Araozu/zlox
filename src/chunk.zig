const std = @import("std");
const print = std.debug.print;

pub const OpCode = enum(u8) {
    OP_RETURN,
};

pub const Chunk = struct {
    code: []u8,
    count: usize,
    capacity: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Chunk {
        return .{
            .count = 0,
            .capacity = 0,
            .allocator = allocator,
            .code = try allocator.alloc(u8, 0),
        };
    }

    pub fn write_chunck(self: *Chunk, byte: u8) !void {
        // If the code slice is full
        if (self.count == self.capacity) {
            const old_capacity = self.capacity;
            self.capacity = if (old_capacity < 8) 8 else old_capacity * 2;
            self.code = try self.allocator.realloc(self.code, self.capacity);
        }

        self.code[self.count] = byte;
        self.count += 1;
    }

    /// Reinitializes the state of the chunk.
    pub fn free_chunck(self: *Chunk) !void {
        self.count = 0;
        self.capacity = 0;
        self.code = try self.allocator.realloc(self.code, 0);
    }

    pub fn dissasemble_chunk(self: *Chunk, name: []const u8) void {
        print("== {s} ==\n", .{name});

        var offset: usize = 0;
        while (offset < self.count) {
            offset = dissasemble_instruction(self, offset);
        }
    }

    fn dissasemble_instruction(self: *Chunk, offset: usize) usize {
        print("{d:0>4} ", .{offset});

        const instruction = self.code[offset];
        switch (instruction) {
            @intFromEnum(OpCode.OP_RETURN) => return simple_instruction("OP_RETURN", offset),
            else => {
                print("unknown opcode {d}\n", .{instruction});
                return offset + 1;
            },
        }
    }

    pub fn deinit(self: Chunk) void {
        self.allocator.free(self.code);
    }
};

fn simple_instruction(comptime name: []const u8, offset: usize) usize {
    print("{s}\n", .{name});
    return offset + 1;
}
