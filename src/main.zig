const std = @import("std");
const Lexer = @import("./lexer.zig");

pub fn main() !void {
    const lexer = Lexer.init("1 > 2");
    std.log.info("Hello, world!", .{});
    _ = lexer;
}
