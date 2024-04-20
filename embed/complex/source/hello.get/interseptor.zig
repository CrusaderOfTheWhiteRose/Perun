const std = @import("std");
const handlerStruct = @import("~/@perun/core/handler.struct.zig").handler;

const main = struct {
    fn @"_"() !void {
        var timer = try std.time.Timer.start();
        const timer_ptr: *std.time.Timer = &timer;
        var times: u4 = 0;
        const times_ptr: *u4 = &times;
        _ = timer_ptr;
        _ = times_ptr;
    }
    fn @">"(times_ptr: *u4) !void {
        times_ptr.* += 1;
    }
    fn @"<"(times_ptr: *u4, timer_ptr: *std.time.Timer) !void {
        times_ptr.* += 1;
        std.debug.print("INTERSEPTOR times {d} time {any}\n", .{ times_ptr.*, (timer_ptr.lap() / 100000) });
    }
};
