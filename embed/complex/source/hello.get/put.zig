const std = @import("std");
const handlerStruct = @import("~/@perun/core/handler.struct.zig").handler;

fn main(handler: *handlerStruct) !void {
    const c = struct {
        c: u8,
    };
    const data = try std.json.parseFromSlice(c, std.heap.page_allocator, handler.body, .{});
    std.debug.print("{any}\n", .{data.value});
    std.heap.page_allocator.free(data);
    try handler.response(200, "Content-Type: text/html", "<h1>HELLO_PUT</h1>");
}
