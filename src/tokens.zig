const std = @import("std");

pub const Token = union(enum) {
    ILLEGAL: []const u8,
    EOF,

    // Identifiers + literals,
    IDENT: []const u8,
    INT: []const u8,
    TRUE,
    FALSE,

    // Operators,
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,

    SLASH,
    LT,
    GT,

    EQ,
    NOT_EQ,
    AND,
    OR,
    GTE,
    LTE,
    BITWISE_AND,
    BITWISE_OR,

    // Delimiters,
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    // Keywords,
    FUNCTION,
    LET,
    IF,
    ELSE,
    RETURN,

    pub fn buildForLiteral(literal: []const u8) Token {
        const map = std.ComptimeStringMap(Token, .{
            .{ "let", .LET },
            .{ "fn", .FUNCTION },
            .{ "if", .IF },
            .{ "else", .ELSE },
            .{ "return", .RETURN },
            .{ "true", .TRUE },
            .{ "false", .FALSE },
        });
        return map.get(literal) orelse Token{ .IDENT = literal };
    }
};
