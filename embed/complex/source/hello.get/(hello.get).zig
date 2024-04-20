const std = @import("std");
const handlerStruct = @import("~/@perun/core/handler.struct.zig").handler;
const more_stuff = @import("~/source/hello.get/more_stuff.zig");

fn main(handler: *handlerStruct) !void {
    try more_stuff.print_more();
    try handler.response(200, "Content-Type: text/html", "<h1>HELLO</h1>");
}
