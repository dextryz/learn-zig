// aos_vs_soa.zig — run with: zig run -O ReleaseFast aos_vs_soa.zig

const std = @import("std");

const GateKind = enum(u8) { x, y, z, cz, measure, reset, barrier };

// The "obvious" record type. 1 + 4 + 8 = 13 bytes of data,
// but alignment pads it to 16 — 3 dead bytes in EVERY element.
const Gate = struct {
    tag: GateKind, // 1 byte
    qubit: u32, // 4 bytes
    angle: f64, // 8 bytes
};

const n = 2_000_000;

// AoS scan: to read each 1-byte tag, the CPU must pull the whole
// 16-byte record through the cache. 15/16 of the traffic is waste.
fn countCzAos(gates: []const Gate) usize {
    var count: usize = 0;
    for (gates) |g| count += @intFromBool(g.tag == .cz);
    return count;
}

// SoA scan: tags are contiguous. Every 64-byte cache line delivers
// 64 useful tags, and the loop auto-vectorizes cleanly.
fn countCzSoa(tags: []const GateKind) usize {
    var count: usize = 0;
    for (tags) |t| count += @intFromBool(t == .cz);
    return count;
}

pub fn main(init: std.process.Init) !void {
    std.debug.print("@sizeOf(Gate) = {d} bytes (13 data + {d} padding)\n\n", .{
        @sizeOf(Gate), @sizeOf(Gate) - 13,
    });

    // ----- Layout 1: AoS — array of whole structs -----------------------
    const aos = try init.gpa.alloc(Gate, n);
    defer init.gpa.free(aos);

    for (aos, 0..) |*g, i| {
        g.* = .{
            .tag = @enumFromInt(i % 5),
            .qubit = @intCast(i & 0xffff),
            .angle = 0.25,
        };
    }

    // ----- Layout 2: SoA — MultiArrayList splits fields into columns ----
    // Same element type, same append API; storage becomes three arrays:
    //   tags:   [t t t t ...]   (1 B each, tightly packed — padding gone)
    //   qubits: [q q q q ...]
    //   angles: [a a a a ...]
    var soa: std.MultiArrayList(Gate) = .empty;
    defer soa.deinit(init.gpa);
    try soa.ensureTotalCapacity(init.gpa, n);

    for (0..n) |i| {
        soa.appendAssumeCapacity(.{
            .tag = @enumFromInt(i % 5),
            .qubit = @intCast(i & 0xffff),
            .angle = 0.25,
        });
    }

    // ----- Same query over both layouts, best of 3 ----------------------
    var best_aos: f64 = std.math.inf(f64);
    var count_aos: usize = 0;
    for (0..3) |_| {
        const t0 = std.Io.Clock.now(.awake, init.io);
        count_aos = countCzAos(aos);
        std.mem.doNotOptimizeAway(count_aos);
        const t1 = std.Io.Clock.now(.awake, init.io);
        const ms = @as(f64, @floatFromInt(t0.durationTo(t1).toNanoseconds())) / 1e6;
        best_aos = @min(best_aos, ms);
    }

    const tags = soa.items(.tag); // borrow ONLY the tag column
    var best_soa: f64 = std.math.inf(f64);
    var count_soa: usize = 0;
    for (0..3) |_| {
        const t0 = std.Io.Clock.now(.awake, init.io);
        count_soa = countCzSoa(tags);
        std.mem.doNotOptimizeAway(count_soa);
        const t1 = std.Io.Clock.now(.awake, init.io);
        const ms = @as(f64, @floatFromInt(t0.durationTo(t1).toNanoseconds())) / 1e6;
        best_soa = @min(best_soa, ms);
    }

    std.debug.print("counting CZ gates among {d} ops:\n", .{n});
    std.debug.print("  AoS: {d:>7.2} ms   ({d} MB streamed to inspect {d} MB of tags)\n", .{
        best_aos, n * @sizeOf(Gate) >> 20, n >> 20,
    });
    std.debug.print("  SoA: {d:>7.2} ms   ({d} MB streamed — the tag column alone)\n", .{
        best_soa, n >> 20,
    });
    std.debug.print("  same answer: {d} == {d}\n\n", .{ count_aos, count_soa });
}
