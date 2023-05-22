const std = @import("std");
const Lexer = @import("./lexer.zig");

pub fn main() !void {
    const lexer = try Lexer.getLexer("1 > 2");
    std.log.info("Hello, world!", .{});
    _ = lexer;
}
