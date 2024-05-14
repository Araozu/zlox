const std = @import("std");
const chunk = @import("./chunk.zig");
const OpCode = chunk.OpCode;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    var mem = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = mem.allocator();

    var c = try chunk.Chunk.init(alloc);
    defer c.deinit();

    try c.write(@intFromEnum(chunk.OpCode.OP_RETURN));

    const constant_idx = try c.add_constant(1.2);
    try c.write(@intFromEnum(OpCode.OP_CONSTANT));
    try c.write(@truncate(constant_idx));

    c.dissasemble_chunk("test chunk");
}

test "chunk test" {
    var c = try chunk.Chunk.init(std.testing.allocator);
    defer c.deinit();

    try c.write('a');
    try c.write('b');
    try c.free_chunck();
    try c.write('J');
    try c.write('H');
}
