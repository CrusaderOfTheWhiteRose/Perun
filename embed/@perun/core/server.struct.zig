const std = @import("std");

pub const server = struct { env: ?[]const u8, options: ?struct {
    port: ?comptime_int,
    kernel_backlog: ?u31,
    max_http_headers_size: ?comptime_int,
    max_request_body_size: ?comptime_int,
} };
