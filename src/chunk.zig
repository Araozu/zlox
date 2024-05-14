const std = @import("std");
const print = std.debug.print;
const value = @import("./value.zig");
const ValueArray = value.ValueArray;

pub const OpCode = enum(u8) {
    OP_RETURN,
};

pub const Chunk = struct {
    code: []u8,
    count: usize,
    capacity: usize,
    constants: ValueArray,
    allocator: std.mem.Allocator,

    /// Initializes a new Chunk
    pub fn init(allocator: std.mem.Allocator) !Chunk {
        return .{
            .count = 0,
            .capacity = 0,
            .allocator = allocator,
            .code = try allocator.alloc(u8, 0),
            .constants = try ValueArray.init(allocator),
        };
    }

    /// Writes a byte to this chunk
    pub fn write(self: *Chunk, byte: u8) !void {
        // If the code slice is full
        if (self.count == self.capacity) {
            const old_capacity = self.capacity;
            self.capacity = grow_capacity(old_capacity);
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

    /// Prints the current state of the chunk to stderr
    pub fn dissasemble_chunk(self: *Chunk, name: []const u8) void {
        print("== {s} ==\n", .{name});

        var offset: usize = 0;
        while (offset < self.count) {
            offset = dissasemble_instruction(self, offset);
        }
    }

    /// Prints the value of a single instruction
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

    pub fn add_constant(self: *Chunk, v: value.Value) !usize {
        return try self.constants.add_constant(v);
    }

    /// Destroys this chunk
    pub fn deinit(self: Chunk) void {
        self.allocator.free(self.code);
        self.constants.deinit();
    }
};

fn simple_instruction(comptime name: []const u8, offset: usize) usize {
    print("{s}\n", .{name});
    return offset + 1;
}

inline fn grow_capacity(old: usize) usize {
    return if (old < 8) 8 else old * 2;
}
