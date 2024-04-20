const std = @import("std");
const serverStruct = @import("~/@perun/core/server.struct.zig").server;

const main = serverStruct{ .env = ".env", .options = .{
    .port = 8080,
    .kernel_backlog = 2_147_483_647,
    .max_http_headers_size = 8_192,
    .max_request_body_size = 1_048_576,
} };
