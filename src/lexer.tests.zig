const std = @import("std");
const getLexer = @import("./lexer.zig").getLexer;
const Token = @import("./tokens.zig").Token;

test "simple test" {
    const input = "=+(){},;";
    var lexer = getLexer(input);

    const expectedTokens = [_]Token{
        Token.ASSIGN,
        Token.PLUS,
        Token.LPAREN,
        Token.RPAREN,
        Token.LBRACE,
        Token.RBRACE,
        Token.COMMA,
        Token.SEMICOLON,
        Token.EOF,
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        try std.testing.expectEqualDeep(token, expectedToken);
    }
}

test "doubled" {
    const input = "10 == 10 != 9 && false || 5 <= 10 >= 5;";
    var lexer = getLexer(input);

    const expectedTokens = [_]Token{
        Token{ .INT = "10" },
        Token.EQ,
        Token{ .INT = "10" },
        Token.NOT_EQ,
        Token{ .INT = "9" },
        Token.AND,
        Token.FALSE,
        Token.OR,
        Token{ .INT = "5" },
        Token.LTE,
        Token{ .INT = "10" },
        Token.GTE,
        Token{ .INT = "5" },
        Token.SEMICOLON,
        Token.EOF,
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        try std.testing.expectEqualDeep(token, expectedToken);
    }
}

test "illegal" {
    const input = "?? 10 == 10 != 9 && false || 5 <= 10 >= 5;?";
    var lexer = getLexer(input);

    const expectedTokens = [_]Token{
        Token{ .ILLEGAL = "?" },
        Token{ .ILLEGAL = "?" },
        Token{ .INT = "10" },
        Token.EQ,
        Token{ .INT = "10" },
        Token.NOT_EQ,
        Token{ .INT = "9" },
        Token.AND,
        Token.FALSE,
        Token.OR,
        Token{ .INT = "5" },
        Token.LTE,
        Token{ .INT = "10" },
        Token.GTE,
        Token{ .INT = "5" },
        Token.SEMICOLON,
        Token{ .ILLEGAL = "?" },
        Token.EOF,
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        try std.testing.expectEqualDeep(token, expectedToken);
    }
}
