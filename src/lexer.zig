const std = @import("std");
const Token = @import("./tokens.zig").Token;

fn isDigit(ch: u8) bool {
    return ch >= '0' and ch <= '9';
}

fn isLetterOrUnderscore(ch: u8) bool {
    return ((ch >= 'a' and ch <= 'z') or
        (ch >= 'A' and ch <= 'Z') or
        ch == '_');
}

const Lexer = struct {
    input: []const u8,
    position: usize,
    readPosition: usize,
    ch: u8,

    pub fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.position = self.readPosition;
        self.readPosition += 1;
    }

    fn peekChar(self: *Lexer) u8 {
        if (self.readPosition >= self.input.len) {
            return 0;
        } else {
            return self.input[self.readPosition];
        }
    }

    fn readNumber(self: *Lexer) []const u8 {
        var position = self.position;
        while (isDigit(self.ch) and isDigit(self.peekChar())) {
            self.readChar();
        }
        return self.input[position .. self.position + 1];
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        var position = self.position;
        while (isLetterOrUnderscore(self.ch) and isLetterOrUnderscore(self.peekChar())) {
            self.readChar();
        }
        return self.input[position .. self.position + 1];
    }

    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();

        var token: ?Token = switch (self.ch) {
            '+' => .PLUS,
            '-' => .MINUS,
            '*' => .ASTERISK,
            '/' => .SLASH,
            '(' => .LPAREN,
            ')' => .RPAREN,
            '{' => .LBRACE,
            '}' => .RBRACE,
            ',' => .COMMA,
            ';' => .SEMICOLON,
            '!' => self.ifPeekIs('=', .NOT_EQ, .BANG),
            '=' => self.ifPeekIs('=', .EQ, .ASSIGN),
            '&' => self.ifPeekIs('&', .AND, .BITWISE_AND),
            '|' => self.ifPeekIs('|', .OR, .BITWISE_OR),
            '<' => self.ifPeekIs('=', .LTE, .LT),
            '>' => self.ifPeekIs('=', .GTE, .GT),
            0 => .EOF,
            else => null,
        };

        if (token == null and isLetterOrUnderscore(self.ch)) {
            token = Token.buildForLiteral(self.readIdentifier());
        }

        if (token == null and isDigit(self.ch)) {
            token = .{ .INT = self.readNumber() };
        }

        const tok = token orelse Token{ .ILLEGAL = &([1]u8{self.ch}) };
        self.readChar();
        return tok;
    }

    fn ifPeekIs(self: *Lexer, expected: u8, then: Token, otherwise: Token) Token {
        if (self.peekChar() == expected) {
            self.readChar();
            return then;
        } else {
            return otherwise;
        }
    }

};

pub fn init(input: []const u8) Lexer {
    var l = Lexer{
        .input = input,
        .position = 0,
        .readPosition = 0,
        .ch = ' ',
    };
    l.readChar();
    return l;
}
