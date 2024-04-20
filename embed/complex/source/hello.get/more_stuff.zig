const std = @import("std");

pub fn print_more() !void {
    std.debug.print("HELLO\n", .{});
}
