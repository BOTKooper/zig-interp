const std = @import("std");
const Lexer = @import("./lexer.zig");
const Token = @import("./tokens.zig").Token;

test "simple test" {
    const input = "=+(){},;";
    var lexer = Lexer.init(input);

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

test "simple test 2" {
    const input =
        \\let five = 5;
        \\	let ten = 10;
        \\	let add = fn(x, y) {
        \\	x + y;
        \\	};
        \\	let result = add(five, ten);
    ;
    var lexer = Lexer.init(input);

    const expectedTokens = [_]Token{
        Token.LET,
        Token{ .IDENT = "five" },
        Token.ASSIGN,
        Token{ .INT = "5" },
        Token.SEMICOLON,
        Token.LET,
        Token{ .IDENT = "ten" },
        Token.ASSIGN,
        Token{ .INT = "10" },
        Token.SEMICOLON,
        Token.LET,
        Token{ .IDENT = "add" },
        Token.ASSIGN,
        Token.FUNCTION,
        Token.LPAREN,
        Token{ .IDENT = "x" },
        Token.COMMA,
        Token{ .IDENT = "y" },
        Token.RPAREN,
        Token.LBRACE,
        Token{ .IDENT = "x" },
        Token.PLUS,
        Token{ .IDENT = "y" },
        Token.SEMICOLON,
        Token.RBRACE,
        Token.SEMICOLON,
        Token.LET,
        Token{ .IDENT = "result" },
        Token.ASSIGN,
        Token{ .IDENT = "add" },
        Token.LPAREN,
        Token{ .IDENT = "five" },
        Token.COMMA,
        Token{ .IDENT = "ten" },
        Token.RPAREN,
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
    var lexer = Lexer.init(input);

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
    var lexer = Lexer.init(input);

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
