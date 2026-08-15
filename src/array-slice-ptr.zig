///! https://levin405.neocities.org/blog/2025-02-20-zig-arrays-slices-pointers/
///! https://blog.orhun.dev/zig-bits-01/
const std = @import("std");

pub fn main() !void {
    var array = [5]u64{ 1, 2, 3, 4, 5 };
    std.debug.print("\n> 1\n", .{});
    std.debug.print("{any}\n", .{array});

    var slice: []u64 = &array;

    // Update the value. Will fail if `const array`
    slice[1] = 4;
    std.debug.print("\n> 2\n", .{});
    std.debug.print("{any}\n", .{slice.ptr});
    std.debug.print("{any}\n", .{slice});

    // Most the pointer 1 array item forward
    slice.ptr += 1;
    std.debug.print("\n> 3\n", .{});
    std.debug.print("{any}\n", .{slice.ptr});
    std.debug.print("{any}\n", .{slice});

    // Most the pointer 2 array item backwards.
    // Cycling the array from behind.
    slice.ptr -= 2;
    std.debug.print("\n> 4\n", .{});
    std.debug.print("{any}\n", .{slice.ptr});
    std.debug.print("{any}\n", .{slice});

    // many-item pointer
    const mip: [*]u64 = &array;
    std.debug.print("\n> 5\n", .{});
    std.debug.print("{any}\n", .{mip});

    // sentinel-terminated array
    var sta = [5:0]u64{ 1, 2, 3, 4, 5 };
    std.debug.print("\n> 6\n", .{});
    std.debug.print("{any}\n", .{sta});
    std.debug.print("Has a 6th element that terminates the array\n", .{});
    std.debug.print("{any}\n", .{sta[5]});

    // sentinel-terminated pointer
    const stp: [*:0]u64 = &sta;
    std.debug.print("\n> 7\n", .{});
    std.debug.print("{any}\n", .{stp});

    // sentinel-terminated slice
    var sts: [:0]u64 = &sta;
    sts[2] = 8;
    std.debug.print("\n> 8\n", .{});
    std.debug.print("{any}\n", .{sts});
    sts.ptr += 1;
    std.debug.print("{any}\n", .{sts});
}
