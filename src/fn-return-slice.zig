///! https://blog.orhun.dev/zig-bits-01/
const std = @import("std");

fn stack(slice: []u8) void {
    const msg = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    @memcpy(slice, &msg);
}

fn heap(gpa: std.mem.Allocator) ![]u8 {
    const msg = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    return gpa.dupe(u8, &msg);
}

pub fn main(init: std.process.Init) !void {
    var msg_stack: [5]u8 = undefined;
    stack(&msg_stack);
    std.debug.print("\n* Stack\n", .{});
    std.debug.print("{s}\n", .{msg_stack});

    const msg_heap = try heap(init.gpa);
    defer init.gpa.free(msg_heap);
    std.debug.print("\n* Heap\n", .{});
    std.debug.print("{s}\n", .{msg_heap});
}
