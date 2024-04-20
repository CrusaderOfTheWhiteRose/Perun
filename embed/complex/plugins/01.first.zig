const std = @import("std");
const utilities = @import("../utilities/odd.zig");

pub const main = struct {
    var out: u8 = undefined;
    pub fn init(allocator: std.mem.Allocator) !void {
        _ = allocator;
        out = 0;
    }
    pub fn count() bool {
        return utilities.odd(out);
    }
};
