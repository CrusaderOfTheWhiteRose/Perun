const std = @import("std");

pub const parse = struct {
    pub fn parse_files(body: []const u8, boundary: []const u8) !*std.ArrayList([]const u8) {
        var bodyParsed = std.mem.split(u8, body, boundary);
        var files = std.ArrayList([]const u8).init(std.heap.page_allocator);
        var i: u4 = 0;
        while (bodyParsed.next()) |parsed| {
            if (parsed[2] == 45 or parsed[0] == 45) continue;

            var lineNumber: u3 = 0;
            var byteNumber: u9 = 0;
            while (true) {
                if (parsed[byteNumber] == 13) lineNumber += 1;
                if (lineNumber == 4) break;
                byteNumber += 1;
            }

            var basicContentTypeParse = std.mem.split(u8, parsed[0..byteNumber], "Content-Type:");
            _ = basicContentTypeParse.next();
            var advanceContentTypeParse = std.mem.split(u8, basicContentTypeParse.next().?, "\n");
            var valueContentTypeParse = advanceContentTypeParse.next().?;
            if (valueContentTypeParse[0] == 32) {
                valueContentTypeParse = valueContentTypeParse[1..(valueContentTypeParse.len - 1)];
            }
            var typeExtension = std.mem.split(u8, valueContentTypeParse, "/");
            _ = typeExtension.next().?;

            try files.append(typeExtension.next().?);
            try files.append(parsed[(byteNumber + 2)..]);
            i += 1;
        }
        return &files;
    }
    pub fn upload_files(files: *std.ArrayList([]const u8), path: []const u8) !void {
        var index: u8 = 0;
        var extension: [4]u8 = undefined;
        for (files.items) |item| {
            switch (item[0]) {
                106 => {
                    // jpeg
                    extension = [_]u8{ 106, 112, 101, 103 };
                },
                112 => {
                    // png
                    extension = [_]u8{ 112, 110, 103, 32 };
                },
                103 => {
                    // gif
                    extension = [_]u8{ 103, 105, 102, 32 };
                },
                119 => {
                    // webp
                    extension = [_]u8{ 119, 101, 98, 112 };
                },
                97 => {
                    // avif
                    extension = [_]u8{ 97, 118, 105, 102 };
                },
                111 => {
                    // opus
                    extension = [_]u8{ 111, 112, 117, 115 };
                },
                109 => {
                    if (item[2] == 101) {
                        // mp3
                        extension = [_]u8{ 111, 112, 51, 32 };
                        // mp4
                    } else extension = [_]u8{ 111, 112, 52, 32 };
                },
                else => {
                    var pathBuffer: [2]u8 = undefined;
                    const theFileNumber = try std.fmt.bufPrint(&pathBuffer, "{d}", .{index});
                    var dir = try std.fs.cwd().openDir(path, .{});
                    if (extension[3] == 32) {
                        const file = try std.fs.cwd().createFile(try std.mem.join(std.heap.page_allocator, "", &[_][]const u8{ path, "/", theFileNumber, ".", extension[0..2] }), .{});
                        try file.writer().writeAll(item);
                    } else {
                        const file = try std.fs.cwd().createFile(try std.mem.join(std.heap.page_allocator, "", &[_][]const u8{ path, "/", theFileNumber, ".", extension[0..] }), .{});
                        try file.writer().writeAll(item);
                    }
                    dir.close();
                    index += 1;
                },
            }
        }
    }
};
