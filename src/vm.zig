const std = @import("std");
const chunk_mod = @import("./chunk.zig");
const Chunk = chunk_mod.Chunk;
const OpCode = chunk_mod.OpCode;
const print = std.debug.print;

const InterpretResult = enum {
    Ok,
    CompileError,
    RuntimeError,
};

pub const VM = struct {
    chunk: *Chunk,
    ip: [*]const u8,
    allocator: std.mem.Allocator,

    // Takes ownership of the passed Chunk. This chunk will be deinitialized
    // when this VM is deinitialized
    pub fn init(allocator: std.mem.Allocator, chunk: *Chunk) VM {
        return .{
            .allocator = allocator,
            .chunk = chunk,
            .ip = chunk.code.ptr,
        };
    }

    // Executes the instructions in the bytecode
    pub fn run(self: *VM) InterpretResult {
        while (true) {
            const next = self.ip[0];
            self.ip += 1;
            switch (next) {
                @intFromEnum(OpCode.OP_RETURN) => {
                    return InterpretResult.Ok;
                },
                @intFromEnum(OpCode.OP_CONSTANT) => {
                    const constant = self.chunk.constants.values[self.ip[0]];
                    self.ip += 1;
                    chunk_mod.print_value(constant);
                    print("\n", .{});
                },
                else => {
                    std.debug.print("Not implemented!\n", .{});
                    unreachable;
                },
            }
        }

        return null;
    }

    pub fn deinit(self: VM) void {
        _ = self;
    }
};
