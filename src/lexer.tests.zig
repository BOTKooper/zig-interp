const std = @import("std");
const Lexer = @import("./lexer.zig");
const Token = @import("./tokens.zig").Token;

test "simple test" {
    const input = "=+(){},;";
    var lexer = Lexer.init(input);
 
    const expectedTokens = [_]Token{
        .ASSIGN,
        .PLUS,
        .LPAREN,
        .RPAREN,
        .LBRACE,
        .RBRACE,
        .COMMA,
        .SEMICOLON,
        .EOF,
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
        .LET,
        .{ .IDENT = "five" },
        .ASSIGN,
        .{ .INT = "5" },
        .SEMICOLON,
        .LET,
        .{ .IDENT = "ten" },
        .ASSIGN,
        .{ .INT = "10" },
        .SEMICOLON,
        .LET,
        .{ .IDENT = "add" },
        .ASSIGN,
        .FUNCTION,
        .LPAREN,
        .{ .IDENT = "x" },
        .COMMA,
        .{ .IDENT = "y" },
        .RPAREN,
        .LBRACE,
        .{ .IDENT = "x" },
        .PLUS,
        .{ .IDENT = "y" },
        .SEMICOLON,
        .RBRACE,
        .SEMICOLON,
        .LET,
        .{ .IDENT = "result" },
        .ASSIGN,
        .{ .IDENT = "add" },
        .LPAREN,
        .{ .IDENT = "five" },
        .COMMA,
        .{ .IDENT = "ten" },
        .RPAREN,
        .SEMICOLON,
        .EOF,
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
        .{ .INT = "10" },
        .EQ,
        .{ .INT = "10" },
        .NOT_EQ,
        .{ .INT = "9" },
        .AND,
        .FALSE,
        .OR,
        .{ .INT = "5" },
        .LTE,
        .{ .INT = "10" },
        .GTE,
        .{ .INT = "5" },
        .SEMICOLON,
        .EOF,
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
        .{ .ILLEGAL = "?" },
        .{ .ILLEGAL = "?" },
        .{ .INT = "10" },
        .EQ,
        .{ .INT = "10" },
        .NOT_EQ,
        .{ .INT = "9" },
        .AND,
        .FALSE,
        .OR,
        .{ .INT = "5" },
        .LTE,
        .{ .INT = "10" },
        .GTE,
        .{ .INT = "5" },
        .SEMICOLON,
        .{ .ILLEGAL = "?" },
        .EOF,
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        try std.testing.expectEqualDeep(token, expectedToken);
    }
}


test "asd" {
    const input = "?? 10 == 10 != 9 && false || 5 <= 10 >= 5;?";
    var lexer = Lexer.init(input);

    const expectedTokens = [_]Token{
        .{ .ILLEGAL = "?" },
        .{ .ILLEGAL = "?" },
        .{ .INT = "10" },
        .EQ,
        .{ .INT = "10" },
        .NOT_EQ,
        .{ .INT = "9" },
        .AND,
        .FALSE,
        .OR,
        .{ .INT = "5" },
        .LTE,
        .{ .INT = "10" },
        .GTE,
        .{ .INT = "5" },
        .SEMICOLON,
        .{ .ILLEGAL = "?" },
        .EOF,
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        try std.testing.expectEqualDeep(token, expectedToken);
    }
}
