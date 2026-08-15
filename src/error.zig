///! https://levin405.neocities.org/blog/2025-03-05-zig-error-handling/
const std = @import("std");

const MathError = error{
    DivisionByZero,
    IntegerOverflow,
};

fn divide(a: i8, b: i8) MathError!i8 {
    if (b == 0) return MathError.DivisionByZero;
    if (a == -128 and b == -1) return MathError.IntegerOverflow;
    return @divTrunc(a, b);
}

fn divideB(a: i8, b: i8) !i8 {
    if (b == 0) return error.DivisionByZero;
    if (a == -128 and b == -1) return error.IntegerOverflow;
    return @divTrunc(a, b);
}

pub fn main() !void {
    //std.debug.print("{}\n", .{try divide(-128, -1)});
    //std.debug.print("{}\n", .{try divideB(-128, -1)});

    const x: i8 = -128;
    var y: i8 = 1;

    // --- 1
    //    if (divide(x, y)) |n| {
    //        std.debug.print("{} / {} = {}\n", .{ x, y, n });
    //    } else |err| {
    //        std.debug.print("err: {}\n", .{err});
    //    }

    // --- 2
    //    while (divide(x, y)) |value| {
    //        std.debug.print("val: {}\n", .{value});
    //        y = -1;
    //    } else |err| {
    //        std.debug.print("err: {}\n", .{err});
    //    }

    // --- 3
    //    y = -1;
    //    const n = divide(x, y) catch 0;
    //    std.debug.print("{}\n", .{n});

    //    y = -1;
    //    const n = divide(x, y) catch {
    //        std.debug.print("err\n", .{});
    //        std.process.exit(1);
    //    };
    //    std.debug.print("{}\n", .{n});

    // --- 4
    //    y = -1;
    //    const n = try divide(x, y);
    //    std.debug.print("{}\n", .{n});

    // --- 5
    //    y = -1;
    //    const n = divide(x, y) catch |err| return err;
    //    std.debug.print("{}\n", .{n});

    //    const n = divide(-128, -1) catch unreachable;
    //    std.debug.print("{}\n", .{n});
}
