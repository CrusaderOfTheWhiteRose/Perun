const std = @import("std");
const handlerStruct = @import("~/@perun/core/handler.struct.zig").handler;
const environmentStruct = @import("~/@perun/modules/environment.build.zig").environment;

fn main(handler: *handlerStruct) !void {
    try handler.response(200, "Content-Type: text/html", environmentStruct.map.get("SOME_ENVIRONMENT_VARIABLE"));
}
