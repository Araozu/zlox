const std = @import("std");

pub const Value = f64;

pub const ValueArray = struct {
    capacity: usize,
    count: usize,
    values: []Value,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !ValueArray {
        return .{ .capacity = 0, .count = 0, .values = try allocator.alloc(Value, 0), .allocator = allocator };
    }

    pub fn write(self: *ValueArray, value: Value) !void {
        if (self.count == self.capacity) {
            const old = self.capacity;
            self.capacity = if (old < 8) 8 else old * 2;
            self.values = try self.allocator.realloc(self.values, self.capacity);
        }

        self.values[self.count] = value;
        self.count += 1;
    }

    pub fn add_constant(self: *ValueArray, value: Value) !usize {
        try self.write(value);
        return self.count - 1;
    }

    pub fn deinit(self: ValueArray) void {
        self.allocator.free(self.values);
    }
};
