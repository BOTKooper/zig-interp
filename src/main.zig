const std = @import("std");

const TokenType = enum {
    ILLEGAL,
    EOF,

    // Identifiers + literals,
    IDENT,
    INT,
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
};


var keywordsMapper = std.StringHashMap(TokenType).init(std.heap.page_allocator);

const Token = struct {
    Type: TokenType,
    Literal: []const u8,
};

var charToTokenMapper = std.StringHashMap(TokenType).init(std.heap.page_allocator);

fn saturateMaps() !void {
    try keywordsMapper.put("fn", TokenType.FUNCTION);
    try keywordsMapper.put("let", TokenType.LET);
    try keywordsMapper.put("if", TokenType.IF);
    try keywordsMapper.put("else", TokenType.ELSE);
    try keywordsMapper.put("return", TokenType.RETURN);
    try keywordsMapper.put("true", TokenType.TRUE);
    try keywordsMapper.put("false", TokenType.FALSE);

    try charToTokenMapper.put("=", TokenType.ASSIGN);
    try charToTokenMapper.put("+", TokenType.PLUS);
    try charToTokenMapper.put("-", TokenType.MINUS);
    try charToTokenMapper.put("!", TokenType.BANG);
    try charToTokenMapper.put("*", TokenType.ASTERISK);
    try charToTokenMapper.put("/", TokenType.SLASH);
    try charToTokenMapper.put("<", TokenType.LT);
    try charToTokenMapper.put(">", TokenType.GT);
    try charToTokenMapper.put("(", TokenType.LPAREN);
    try charToTokenMapper.put(")", TokenType.RPAREN);
    try charToTokenMapper.put("{", TokenType.LBRACE);
    try charToTokenMapper.put("}", TokenType.RBRACE);
    try charToTokenMapper.put(",", TokenType.COMMA);
    try charToTokenMapper.put(";", TokenType.SEMICOLON);
    try charToTokenMapper.put("&", TokenType.BITWISE_AND);
    try charToTokenMapper.put("|", TokenType.BITWISE_OR);
}

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    // try saturateMaps();

    // const input = "=+(){},;";
    // var lexer = getLexer(input);

    // const expectedTokens = [_]Token{
    //     Token{ .Type = TokenType.ASSIGN, .Literal = "=" },
    //     Token{ .Type = TokenType.PLUS, .Literal = "+" },
    //     Token{ .Type = TokenType.LPAREN, .Literal = "(" },
    //     Token{ .Type = TokenType.RPAREN, .Literal = ")" },
    //     Token{ .Type = TokenType.LBRACE, .Literal = "{" },
    //     Token{ .Type = TokenType.RBRACE, .Literal = "}" },
    //     Token{ .Type = TokenType.COMMA, .Literal = "," },
    //     Token{ .Type = TokenType.SEMICOLON, .Literal = ";" },
    // };

    // for (expectedTokens) |_| {
    //     const token = lexer.nextToken();
    //     std.debug.print("GOT -> {} : {s}", .{token.Type, token.Literal});
    //     // try std.testing.expectEqual(@as(i32, 42), list.pop());
    //     // try std.testing.expectEqual(token.Type, expectedToken.Type);
    //     // try std.testing.expectEqual(token.Literal, expectedToken.Literal);
    // }
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
        var token: Token = undefined;

        l.skipWhitespace();

        std.debug.print("token -> {c}\n\n", .{l.ch});
        std.debug.print("isPeekable -> {}\n\n", .{isPeekable(l.ch)});
        if (isPeekable(l.ch)) {
            const peek = l.peekChar();
            const combo  = [_] u8{ l.ch, peek };
            std.debug.print("peek -> {c}\n\n", .{peek});
            std.debug.print("combo -> {s}\n\n", .{combo});
            if (peek != 0 and charToTokenMapper.contains(&combo)) {
                std.debug.print("FUCK", .{});
                const tokenType = charToTokenMapper.get(&combo) orelse TokenType.ILLEGAL;
                l.readChar();
                l.readChar();
                return Token{
                    .Type = tokenType,
                    .Literal = &combo,
                };
            }
        }

        const combo = [1] u8{ l.ch };
        std.debug.print("charToTokenMapper -> {}\n\n", .{charToTokenMapper.contains(&combo)});
        if(charToTokenMapper.contains(&combo)) {
            const tokenType = charToTokenMapper.get(&combo) orelse TokenType.ILLEGAL;
            std.debug.print("tType -> {}\n", .{tokenType});
            std.debug.print("combo -> {s}\n\n", .{combo});
            l.readChar();
            return Token{
                .Type = tokenType,
                .Literal = &combo,
            };
        }

        std.debug.print("isValidIdentifierChar -> {}\n\n", .{isValidIdentifierChar(l.ch)});
        if (isValidIdentifierChar(l.ch)) {
            const identifier = l.readIdentifier();
            const tokenType = getTokenTypeForIdentifier(identifier);
            return Token{
                .Type = tokenType,
                .Literal = identifier,
            };
        }

        std.debug.print("isDigit -> {}\n\n", .{isDigit(l.ch)});
        if (isDigit(l.ch)) {
            const number = l.readNumber();
            return Token{
                .Type = TokenType.INT,
                .Literal = number,
            };
        }

        std.debug.print("CYKA\n\n", .{});
        token = Token{
            .Type = TokenType.ILLEGAL,
            .Literal = &([_]u8 {l.ch}),
        };
        l.readChar();
        return token;
    }
};

fn getLexer(input: []const u8) Lexer {
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
    try saturateMaps();

    const input = "=+(){},;";
    var lexer = getLexer(input);

    const expectedTokens = [_]Token{
        Token{ .Type = TokenType.ASSIGN, .Literal = "=" },
        Token{ .Type = TokenType.PLUS, .Literal = "+" },
        Token{ .Type = TokenType.LPAREN, .Literal = "(" },
        Token{ .Type = TokenType.RPAREN, .Literal = ")" },
        Token{ .Type = TokenType.LBRACE, .Literal = "{" },
        Token{ .Type = TokenType.RBRACE, .Literal = "}" },
        Token{ .Type = TokenType.COMMA, .Literal = "," },
        Token{ .Type = TokenType.SEMICOLON, .Literal = ";" },
    };

    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        std.debug.print("__{s}__{s}__\n", .{token.Literal, expectedToken.Literal});
        std.debug.print("__{}__{}__\n", .{token.Literal.len, expectedToken.Literal.len});
        try std.testing.expectEqual(token.Type, expectedToken.Type);
        std.debug.print("tokens are equal\n"    , .{});
        // try std.testing.expectEqualStrings(token.Literal, expectedToken.Literal);
        // std.debug.print("literals are equal\n"    , .{});
    }
}

// const input = `10 == 10 != 9 && false || 5 <= 10 >= 5;`;

// 		const expectedTokens = [
// 			[TokenType.INT, "10"],
// 			[TokenType.EQ, "=="],
// 			[TokenType.INT, "10"],
// 			[TokenType.NOT_EQ, "!="],
// 			[TokenType.INT, "9"],
// 			[TokenType.AND, "&&"],
// 			[TokenType.FALSE, "false"],
// 			[TokenType.OR, "||"],
// 			[TokenType.INT, "5"],
// 			[TokenType.LTE, "<="],
// 			[TokenType.INT, "10"],
// 			[TokenType.GTE, ">="],
// 			[TokenType.INT, "5"],
// 			[TokenType.SEMICOLON, ";"],
// 			[TokenType.EOF, ""]
// 		];

// 		const lexer = new Lexer(input);

// 		expectedTokens.forEach(([expectedType, expectedLiteral]) => {
// 			const tok = lexer.nextToken();

// 			expect(tok.type).toEqual(expectedType);
// 			expect(tok.literal).toEqual(expectedLiteral);
// 		});
test "doubled" {
    const input = "10 == 10 != 9 && false || 5 <= 10 >= 5;";
    var lexer = getLexer(input);

    const expectedTokens = [_]Token{
        Token{ .Type = TokenType.INT, .Literal = "10" },
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
        Token{ .Type = TokenType.GTE, .Literal = ">=" },
        Token{ .Type = TokenType.INT, .Literal = "5" },
        Token{ .Type = TokenType.SEMICOLON, .Literal = ";" },
        Token{ .Type = TokenType.EOF, .Literal = "" },
    };
    
    for (expectedTokens) |expectedToken| {
        const token = lexer.nextToken();
        std.debug.print("__{s}__{s}__\n", .{token.Literal, expectedToken.Literal});
        std.debug.print("__{}__{}__\n", .{token.Literal.len, expectedToken.Literal.len});
        try std.testing.expectEqual(token.Type, expectedToken.Type);
        std.debug.print("tokens are equal\n"    , .{});
        // try std.testing.expectEqualStrings(token.Literal, expectedToken.Literal);
        // std.debug.print("literals are equal\n"    , .{});
    }
}