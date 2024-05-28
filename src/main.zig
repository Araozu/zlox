const std = @import("std");
const config = @import("config");

const chunk = @import("./chunk.zig");
const OpCode = chunk.OpCode;
const VM = @import("./vm.zig").VM;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    if (config.tracing) {
        std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    }

    var mem = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = mem.allocator();

    var c = try chunk.Chunk.init(alloc);
    defer c.deinit();

    const constant_idx = try c.add_constant(1.2);
    try c.write(@intFromEnum(OpCode.OP_CONSTANT), 1);
    try c.write(@truncate(constant_idx), 1);

    try c.write(@intFromEnum(chunk.OpCode.OP_RETURN), 1);

    c.dissasemble_chunk("test chunk");

    std.debug.print("\n=== end of chunk creation ===\n\n", .{});

    var vm = VM.init(alloc, &c);
    defer vm.deinit();

    _ = vm.run();
}

test "chunk test" {
    var c = try chunk.Chunk.init(std.testing.allocator);
    defer c.deinit();

    const constant_idx = try c.add_constant(1.2);
    try c.write(@intFromEnum(OpCode.OP_CONSTANT), 1);
    try c.write(@truncate(constant_idx), 1);

    try c.write(@intFromEnum(chunk.OpCode.OP_RETURN), 1);

    try c.write('a', 0);
    try c.write('b', 1);
    try c.write('J', 2);
    try c.write('H', 3);
}
