const std = @import("std");
const handlerStruct = @import("~/@perun/core/handler.struct.zig").handler;

fn main(handler: *handlerStruct) !bool {
    if (handler.headers.get("global_key")) |charapter| if (std.mem.eql(u8, charapter, "some-good-pass")) return true;
    return false;
}
