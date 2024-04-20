const std = @import("std");
const handlerStruct = @import("~/@perun/core/handler.struct.zig").handler;

fn main(handler: *handlerStruct) !bool {
    if (handler.headers.get("post_key")) |charapter| if (std.mem.eql(u8, charapter, "some-more-good-pass")) return true;
    return false;
}
