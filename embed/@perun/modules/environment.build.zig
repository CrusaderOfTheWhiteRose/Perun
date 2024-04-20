const std = @import("std");

pub const environment = struct {
    pub var map = std.StringHashMap([]const u8).init(std.heap.page_allocator);
};
