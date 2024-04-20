const std = @import("std");
const parseStruct = @import("parse.struct.zig").parse;

pub const handler = struct {
    body: []const u8,
    headers: *std.StringHashMap([]const u8),
    connection: *const std.net.Server.Connection,

    pub fn parse_json(self: *handler, comptime blueprint: type) !blueprint {
        const data = std.json.parseFromSlice(blueprint, std.heap.page_allocator, self.body, .{}) catch {
            self.response(400, null, null);
        };
        return data.value;
    }
    pub fn parse_files(self: *handler) !*std.ArrayList([]const u8) {
        var parse_file_by: []const u8 = undefined;
        if (self.headers.get("content-type")) |content_type| {
            var parseType = std.mem.split(u8, content_type, "; ");
            while (parseType.next()) |value_type| {
                var parseTypeBoundary = std.mem.split(u8, value_type, "boundary=");
                _ = parseTypeBoundary.next();
                if (parseTypeBoundary.next()) |value_type_boundry| {
                    parse_file_by = value_type_boundry;
                }
            }
        }
        return parseStruct.parse_files(self.body, parse_file_by);
    }
    pub fn response(
        self: *handler,
        code: u9,
        header: ?[]const u8,
        data: ?[]const u8,
    ) !void {
        var codeHeader: []const u8 = undefined;
        switch (code) {
            100 => {
                codeHeader = "HTTP/1.1 100 Continue";
            },
            101 => {
                codeHeader = "HTTP/1.1 101 Switching Protocols";
            },
            102 => {
                codeHeader = "HTTP/1.1 102 Processing";
            },
            103 => {
                codeHeader = "HTTP/1.1 103 Early Hints";
            },
            200 => {
                codeHeader = "HTTP/1.1 200 OK";
            },
            201 => {
                codeHeader = "HTTP/1.1 201 Created";
            },
            202 => {
                codeHeader = "HTTP/1.1 202 Accepted";
            },
            203 => {
                codeHeader = "HTTP/1.1 203 Non-Authoritative Information";
            },
            204 => {
                codeHeader = "HTTP/1.1 204 No Content";
            },
            205 => {
                codeHeader = "HTTP/1.1 205 Reset Content";
            },
            206 => {
                codeHeader = "HTTP/1.1 206 Partial Content";
            },
            207 => {
                codeHeader = "HTTP/1.1 207 Multi-Status";
            },
            208 => {
                codeHeader = "HTTP/1.1 208 Already Reported";
            },
            226 => {
                codeHeader = "HTTP/1.1 226 IM Used";
            },
            300 => {
                codeHeader = "HTTP/1.1 300 Multiple Choices";
            },
            301 => {
                codeHeader = "HTTP/1.1 301 Moved Permanently";
            },
            302 => {
                codeHeader = "HTTP/1.1 302 Found";
            },
            303 => {
                codeHeader = "HTTP/1.1 303 See Other";
            },
            304 => {
                codeHeader = "HTTP/1.1 304 Not Modified";
            },
            305 => {
                codeHeader = "HTTP/1.1 305 Use Proxy";
            },
            307 => {
                codeHeader = "HTTP/1.1 307 Temporary Redirect";
            },
            308 => {
                codeHeader = "HTTP/1.1 308 Permanent Redirect";
            },
            400 => {
                codeHeader = "HTTP/1.1 400 Bad Request";
            },
            401 => {
                codeHeader = "HTTP/1.1 401 Unauthorized";
            },
            402 => {
                codeHeader = "HTTP/1.1 402 Payment Required";
            },
            403 => {
                codeHeader = "HTTP/1.1 403 Forbidden";
            },
            404 => {
                codeHeader = "HTTP/1.1 404 Not Found";
            },
            405 => {
                codeHeader = "HTTP/1.1 405 Method Not Allowed";
            },
            406 => {
                codeHeader = "HTTP/1.1 406 Not Acceptable";
            },
            407 => {
                codeHeader = "HTTP/1.1 407 Proxy Authentication Required";
            },
            408 => {
                codeHeader = "HTTP/1.1 408 Request Timeout";
            },
            409 => {
                codeHeader = "HTTP/1.1 409 Conflict";
            },
            410 => {
                codeHeader = "HTTP/1.1 410 Gone";
            },
            411 => {
                codeHeader = "HTTP/1.1 411 Length Required";
            },
            412 => {
                codeHeader = "HTTP/1.1 412 Precondition Failed";
            },
            413 => {
                codeHeader = "HTTP/1.1 413 Payload Too Large";
            },
            414 => {
                codeHeader = "HTTP/1.1 414 URI Too Long";
            },
            415 => {
                codeHeader = "HTTP/1.1 415 Unsupported Media Type";
            },
            416 => {
                codeHeader = "HTTP/1.1 416 Range Not Satisfiable";
            },
            417 => {
                codeHeader = "HTTP/1.1 417 Expectation Failed";
            },
            418 => {
                codeHeader = "HTTP/1.1 418 I'm a teapot";
            },
            421 => {
                codeHeader = "HTTP/1.1 421 Misdirected Request";
            },
            422 => {
                codeHeader = "HTTP/1.1 422 Unprocessable Entity";
            },
            423 => {
                codeHeader = "HTTP/1.1 423 Locked";
            },
            424 => {
                codeHeader = "HTTP/1.1 424 Failed Dependency";
            },
            425 => {
                codeHeader = "HTTP/1.1 425 Too Early";
            },
            426 => {
                codeHeader = "HTTP/1.1 426 Upgrade Required";
            },
            428 => {
                codeHeader = "HTTP/1.1 428 Precondition Required";
            },
            429 => {
                codeHeader = "HTTP/1.1 429 Too Many Requests";
            },
            431 => {
                codeHeader = "HTTP/1.1 431 Request Header Fields Too Large";
            },
            451 => {
                codeHeader = "HTTP/1.1 451 Unavailable For Legal Reasons";
            },
            500 => {
                codeHeader = "HTTP/1.1 500 Internal Server Error";
            },
            501 => {
                codeHeader = "HTTP/1.1 501 Unauthorized";
            },
            502 => {
                codeHeader = "HTTP/1.1 502 Bad Gateway";
            },
            503 => {
                codeHeader = "HTTP/1.1 503 Service Unavailable";
            },
            504 => {
                codeHeader = "HTTP/1.1 504 Gateway Timeout";
            },
            505 => {
                codeHeader = "HTTP/1.1 505 HTTP Version Not Supported";
            },
            506 => {
                codeHeader = "HTTP/1.1 506 Variant Also Negotiates";
            },
            507 => {
                codeHeader = "HTTP/1.1 507 Insufficient Storage";
            },
            508 => {
                codeHeader = "HTTP/1.1 508 Loop Detected";
            },
            510 => {
                codeHeader = "HTTP/1.1 510 Not Extended";
            },
            511 => {
                codeHeader = "HTTP/1.1 511 Network Authentication Required";
            },
            else => {
                codeHeader = "HTTP/1.1 418 I'm a teapot";
            },
        }

        if (header) |header_value| {
            if (data) |data_value| {
                var dataValueLenghtBuffer: [24]u8 = undefined;
                try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, header_value, try std.mem.join(std.heap.page_allocator, " ", &[_][]const u8{ "Content-Length:", try std.fmt.bufPrint(&dataValueLenghtBuffer, "{d}", .{data_value.len}) }), "", data_value }));
            } else try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, header_value, "Content-Length: 0", "", "" }));
        } else {
            if (data) |data_value| {
                var dataValueLenghtBuffer: [24]u8 = undefined;
                try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, try std.mem.join(std.heap.page_allocator, " ", &[_][]const u8{ "Content-Length:", try std.fmt.bufPrint(&dataValueLenghtBuffer, "{d}", .{data_value.len}) }), "", data_value }));
            } else try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, "Content-Length: 0", "", "" }));
        }

        self.connection.stream.close();
    }
    pub fn responseJSON(self: *handler, code: u9, jsonStruct: anytype, header: ?[]const u8) !void {
        var codeHeader: []const u8 = undefined;
        switch (code) {
            100 => {
                codeHeader = "HTTP/1.1 100 Continue";
            },
            101 => {
                codeHeader = "HTTP/1.1 101 Switching Protocols";
            },
            102 => {
                codeHeader = "HTTP/1.1 102 Processing";
            },
            103 => {
                codeHeader = "HTTP/1.1 103 Early Hints";
            },
            200 => {
                codeHeader = "HTTP/1.1 200 OK";
            },
            201 => {
                codeHeader = "HTTP/1.1 201 Created";
            },
            202 => {
                codeHeader = "HTTP/1.1 202 Accepted";
            },
            203 => {
                codeHeader = "HTTP/1.1 203 Non-Authoritative Information";
            },
            204 => {
                codeHeader = "HTTP/1.1 204 No Content";
            },
            205 => {
                codeHeader = "HTTP/1.1 205 Reset Content";
            },
            206 => {
                codeHeader = "HTTP/1.1 206 Partial Content";
            },
            207 => {
                codeHeader = "HTTP/1.1 207 Multi-Status";
            },
            208 => {
                codeHeader = "HTTP/1.1 208 Already Reported";
            },
            226 => {
                codeHeader = "HTTP/1.1 226 IM Used";
            },
            300 => {
                codeHeader = "HTTP/1.1 300 Multiple Choices";
            },
            301 => {
                codeHeader = "HTTP/1.1 301 Moved Permanently";
            },
            302 => {
                codeHeader = "HTTP/1.1 302 Found";
            },
            303 => {
                codeHeader = "HTTP/1.1 303 See Other";
            },
            304 => {
                codeHeader = "HTTP/1.1 304 Not Modified";
            },
            305 => {
                codeHeader = "HTTP/1.1 305 Use Proxy";
            },
            307 => {
                codeHeader = "HTTP/1.1 307 Temporary Redirect";
            },
            308 => {
                codeHeader = "HTTP/1.1 308 Permanent Redirect";
            },
            400 => {
                codeHeader = "HTTP/1.1 400 Bad Request";
            },
            401 => {
                codeHeader = "HTTP/1.1 401 Unauthorized";
            },
            402 => {
                codeHeader = "HTTP/1.1 402 Payment Required";
            },
            403 => {
                codeHeader = "HTTP/1.1 403 Forbidden";
            },
            404 => {
                codeHeader = "HTTP/1.1 404 Not Found";
            },
            405 => {
                codeHeader = "HTTP/1.1 405 Method Not Allowed";
            },
            406 => {
                codeHeader = "HTTP/1.1 406 Not Acceptable";
            },
            407 => {
                codeHeader = "HTTP/1.1 407 Proxy Authentication Required";
            },
            408 => {
                codeHeader = "HTTP/1.1 408 Request Timeout";
            },
            409 => {
                codeHeader = "HTTP/1.1 409 Conflict";
            },
            410 => {
                codeHeader = "HTTP/1.1 410 Gone";
            },
            411 => {
                codeHeader = "HTTP/1.1 411 Length Required";
            },
            412 => {
                codeHeader = "HTTP/1.1 412 Precondition Failed";
            },
            413 => {
                codeHeader = "HTTP/1.1 413 Payload Too Large";
            },
            414 => {
                codeHeader = "HTTP/1.1 414 URI Too Long";
            },
            415 => {
                codeHeader = "HTTP/1.1 415 Unsupported Media Type";
            },
            416 => {
                codeHeader = "HTTP/1.1 416 Range Not Satisfiable";
            },
            417 => {
                codeHeader = "HTTP/1.1 417 Expectation Failed";
            },
            418 => {
                codeHeader = "HTTP/1.1 418 I'm a teapot";
            },
            421 => {
                codeHeader = "HTTP/1.1 421 Misdirected Request";
            },
            422 => {
                codeHeader = "HTTP/1.1 422 Unprocessable Entity";
            },
            423 => {
                codeHeader = "HTTP/1.1 423 Locked";
            },
            424 => {
                codeHeader = "HTTP/1.1 424 Failed Dependency";
            },
            425 => {
                codeHeader = "HTTP/1.1 425 Too Early";
            },
            426 => {
                codeHeader = "HTTP/1.1 426 Upgrade Required";
            },
            428 => {
                codeHeader = "HTTP/1.1 428 Precondition Required";
            },
            429 => {
                codeHeader = "HTTP/1.1 429 Too Many Requests";
            },
            431 => {
                codeHeader = "HTTP/1.1 431 Request Header Fields Too Large";
            },
            451 => {
                codeHeader = "HTTP/1.1 451 Unavailable For Legal Reasons";
            },
            500 => {
                codeHeader = "HTTP/1.1 500 Internal Server Error";
            },
            501 => {
                codeHeader = "HTTP/1.1 501 Unauthorized";
            },
            502 => {
                codeHeader = "HTTP/1.1 502 Bad Gateway";
            },
            503 => {
                codeHeader = "HTTP/1.1 503 Service Unavailable";
            },
            504 => {
                codeHeader = "HTTP/1.1 504 Gateway Timeout";
            },
            505 => {
                codeHeader = "HTTP/1.1 505 HTTP Version Not Supported";
            },
            506 => {
                codeHeader = "HTTP/1.1 506 Variant Also Negotiates";
            },
            507 => {
                codeHeader = "HTTP/1.1 507 Insufficient Storage";
            },
            508 => {
                codeHeader = "HTTP/1.1 508 Loop Detected";
            },
            510 => {
                codeHeader = "HTTP/1.1 510 Not Extended";
            },
            511 => {
                codeHeader = "HTTP/1.1 511 Network Authentication Required";
            },
            else => {
                codeHeader = "HTTP/1.1 418 I'm a teapot";
            },
        }

        if (header) |header_value| {
            if (jsonStruct) |json_value| {
                var dataValueLenghtBuffer: [24]u8 = undefined;
                var out = std.ArrayList(u8).init(std.heap.page_allocator);
                defer out.deinit();
                try std.json.stringify(json_value, .{}, out.writer());
                try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, "Content-Type: application/json", header_value, try std.mem.join(std.heap.page_allocator, " ", &[_][]const u8{ "Content-Length:", try std.fmt.bufPrint(&dataValueLenghtBuffer, "{d}", .{out.items.len}) }), "", out.items }));
            } else try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, "Content-Type: application/json", header_value }));
        } else {
            if (jsonStruct) |json_value| {
                var dataValueLenghtBuffer: [24]u8 = undefined;
                var out = std.ArrayList(u8).init(std.heap.page_allocator);
                defer out.deinit();
                try std.json.stringify(json_value, .{}, out.writer());
                try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, "Content-Type: application/json", try std.mem.join(std.heap.page_allocator, " ", &[_][]const u8{ "Content-Length:", try std.fmt.bufPrint(&dataValueLenghtBuffer, "{d}", .{out.items.len}) }), "", out.items }));
            } else try self.connection.stream.writeAll(try std.mem.join(std.heap.page_allocator, "\r\n", &[_][]const u8{ codeHeader, "Content-Type: application/json" }));
        }
    }
};
