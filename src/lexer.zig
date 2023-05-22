const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Tokens = @import("./tokens.zig");
const TokenType = Tokens.TokenType;
const Token = Tokens.Token;

var keywordsMapper = std.StringHashMap(TokenType).init(std.heap.page_allocator);
var alreadySaturated = false;

fn saturateMaps() !void {
    if (alreadySaturated) {
        return;
    }
    try keywordsMapper.put("fn", TokenType.FUNCTION);
    try keywordsMapper.put("let", TokenType.LET);
    try keywordsMapper.put("if", TokenType.IF);
    try keywordsMapper.put("else", TokenType.ELSE);
    try keywordsMapper.put("return", TokenType.RETURN);
    try keywordsMapper.put("true", TokenType.TRUE);
    try keywordsMapper.put("false", TokenType.FALSE);
    alreadySaturated = true;
}

fn isPeekable(ch: u8) bool {
    return (ch == '=' or
        ch == '!' or
        ch == '<' or
        ch == '>' or
        ch == '&' or
        ch == '|');
}

fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

fn isValidIdentifierChar(ch: u8) bool {
    return ((ch >= 'a' and ch <= 'z') or
        (ch >= 'A' and ch <= 'Z') or
        ch == '_');
}

fn getTokenTypeForIdentifier(identifier: []const u8) TokenType {
    return keywordsMapper.get(identifier) orelse TokenType.IDENT;
}

const Lexer = struct {
    input: []const u8,
    position: usize,
    readPosition: usize,
    ch: u8,

    pub fn readChar(l: *Lexer) void {
        if (l.readPosition >= l.input.len) {
            l.ch = 0;
        } else {
            l.ch = l.input[l.readPosition];
        }
        l.position = l.readPosition;
        l.readPosition += 1;
    }

    fn peekChar(l: *Lexer) u8 {
        if (l.readPosition >= l.input.len) {
            return 0;
        } else {
            return l.input[l.readPosition];
        }
    }

    fn readNumber(l: *Lexer) []const u8 {
        var position = l.position;
        while (isDigit(l.ch)) {
            l.readChar();
        }
        return l.input[position..l.position];
    }

    fn readIdentifier(l: *Lexer) []const u8 {
        var position = l.position;
        while (isValidIdentifierChar(l.ch)) {
            l.readChar();
        }
        return l.input[position..l.position];
    }

    fn skipWhitespace(l: *Lexer) void {
        while (l.ch == ' ' or l.ch == '\t' or l.ch == '\n' or l.ch == '\r') {
            l.readChar();
        }
    }

    pub fn nextToken(l: *Lexer) Token {
        l.skipWhitespace();

        var token: Token = undefined;

        switch (l.ch) {
            '=' => {
                if (l.peekChar() == '=') {
                    l.readChar();

                    token = Token{
                        .Type = TokenType.EQ,
                        .Literal = "==",
                    };
                } else {
                    token = Token{ .Type = TokenType.ASSIGN, .Literal = "=" };
                }
            },
            '+' => token = Token{ .Type = TokenType.PLUS, .Literal = "+" },
            '-' => token = Token{ .Type = TokenType.MINUS, .Literal = "-" },
            '!' => {
                if (l.peekChar() == '=') {
                    l.readChar();
                    token = Token{
                        .Type = TokenType.NOT_EQ,
                        .Literal = "!=",
                    };
                } else {
                    token = Token{ .Type = TokenType.BANG, .Literal = "!" };
                }
            },
            '*' => token = Token{ .Type = TokenType.ASTERISK, .Literal = "*" },
            '/' => token = Token{ .Type = TokenType.SLASH, .Literal = "/" },
            '(' => token = Token{ .Type = TokenType.LPAREN, .Literal = "(" },
            ')' => token = Token{ .Type = TokenType.RPAREN, .Literal = ")" },
            '{' => token = Token{ .Type = TokenType.LBRACE, .Literal = "{" },
            '}' => token = Token{ .Type = TokenType.RBRACE, .Literal = "}" },
            ',' => token = Token{ .Type = TokenType.COMMA, .Literal = "," },
            ';' => token = Token{
                .Type = TokenType.SEMICOLON,
                .Literal = ";",
            },
            '&' => {
                if (l.peekChar() == '&') {
                    l.readChar();
                    token = Token{
                        .Type = TokenType.AND,
                        .Literal = "&&",
                    };
                } else {
                    token = Token{
                        .Type = TokenType.ILLEGAL,
                        .Literal = "&",
                    };
                }
            },
            '|' => {
                if (l.peekChar() == '|') {
                    l.readChar();
                    token = Token{
                        .Type = TokenType.OR,
                        .Literal = "||",
                    };
                } else {
                    token = Token{
                        .Type = TokenType.ILLEGAL,
                        .Literal = "|",
                    };
                }
            },
            '<' => {
                if (l.peekChar() == '=') {
                    const ch = l.ch;
                    _ = ch;
                    l.readChar();
                    token = Token{
                        .Type = TokenType.LTE,
                        .Literal = "<=",
                    };
                } else {
                    token = Token{
                        .Type = TokenType.LT,
                        .Literal = "<",
                    };
                }
            },
            '>' => {
                if (l.peekChar() == '=') {
                    const ch = l.ch;
                    _ = ch;
                    l.readChar();
                    token = Token{
                        .Type = TokenType.GTE,
                        .Literal = ">=",
                    };
                } else {
                    token = Token{
                        .Type = TokenType.GT,
                        .Literal = ">",
                    };
                }
            },
            0 => token = Token{
                .Type = TokenType.EOF,
                .Literal = "",
            },
            else => {
                if (isValidIdentifierChar(l.ch)) {
                    const literal = l.readIdentifier();
                    const tokenType = getTokenTypeForIdentifier(literal);
                    token = Token{
                        .Type = tokenType,
                        .Literal = literal,
                    };
                    return token;
                } else if (isDigit(l.ch)) {
                    const literal = l.readNumber();
                    token = Token{
                        .Type = TokenType.INT,
                        .Literal = literal,
                    };
                    return token;
                } else {
                    token = Tokens.buildToken(TokenType.ILLEGAL, l.ch, null);
                }
            },
        }

        l.readChar();

        return token;
    }
};

pub fn getLexer(input: []const u8) !Lexer {
    try saturateMaps();
    var l = Lexer{
        .input = input,
        .position = 0,
        .readPosition = 0,
        .ch = ' ',
    };
    l.readChar();
    return l;
}

test "simple test" {
    const input = "=+(){},;";
    var lexer = try getLexer(input);

    const expectedTokens = [_]Token{
        Token{ .Type = TokenType.ASSIGN, .Literal = "=" },
        Token{ .Type = TokenType.PLUS, .Literal = "+" },
        Token{ .Type = TokenType.LPAREN, .Literal = "(" },
        Token{ .Type = TokenType.RPAREN, .Literal = ")" },
        Token{ .Type = TokenType.LBRACE, .Literal = "{" },
        Token{ .Type = TokenType.RBRACE, .Literal = "}" },
        Token{ .Type = TokenType.COMMA, .Literal = "," },
        Token{ .Type = TokenType.SEMICOLON, .Literal = ";" },
        Token{ .Type = TokenType.EOF, .Literal = "" },
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();

        try std.testing.expectEqual(token.Type, expectedToken.Type);
        try std.testing.expectEqualStrings(token.Literal, expectedToken.Literal);
    }
}

test "doubled" {
    const input = "10 == 10 != 9 && false || 5 <= 10 >= 5;";
    var lexer = try getLexer(input);

    const expectedTokens = [_]Token{
        Token{ .Type = TokenType.INT, .Literal = &([_]u8{ '1', '0' }) },
        Token{ .Type = TokenType.EQ, .Literal = "==" },
        Token{ .Type = TokenType.INT, .Literal = "10" },
        Token{ .Type = TokenType.NOT_EQ, .Literal = "!=" },
        Token{ .Type = TokenType.INT, .Literal = "9" },
        Token{ .Type = TokenType.AND, .Literal = "&&" },
        Token{ .Type = TokenType.FALSE, .Literal = "false" },
        Token{ .Type = TokenType.OR, .Literal = "||" },
        Token{ .Type = TokenType.INT, .Literal = "5" },
        Token{ .Type = TokenType.LTE, .Literal = "<=" },
        Token{ .Type = TokenType.INT, .Literal = "10" },
        Token{ .Type = TokenType.GTE, .Literal = &([_]u8{ '>', '=' }) },
        Token{ .Type = TokenType.INT, .Literal = "5" },
        Token{ .Type = TokenType.SEMICOLON, .Literal = ";" },
        Token{ .Type = TokenType.EOF, .Literal = "" },
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();

        try std.testing.expectEqual(token.Type, expectedToken.Type);
        try std.testing.expectEqualStrings(token.Literal, expectedToken.Literal);
    }
}
