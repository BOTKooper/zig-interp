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
        while (isLetterOrUnderscore(l.ch)) {
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

        var token: ?Token = null;

        switch (l.ch) {
            '=' => {
                if (l.peekChar() == '=') {
                    l.readChar();

                    token = Token.EQ;
                } else {
                    token = Token.ASSIGN;
                }
            },
            '+' => token = Token.PLUS,
            '-' => token = Token.MINUS,
            '!' => {
                if (l.peekChar() == '=') {
                    l.readChar();
                    token = Token.NOT_EQ;
                } else {
                    token = Token.BANG;
                }
            },
            '*' => token = Token.ASTERISK,
            '/' => token = Token.SLASH,
            '(' => token = Token.LPAREN,
            ')' => token = Token.RPAREN,
            '{' => token = Token.LBRACE,
            '}' => token = Token.RBRACE,
            ',' => token = Token.COMMA,
            ';' => token = Token.SEMICOLON,
            '&' => {
                if (l.peekChar() == '&') {
                    l.readChar();
                    token = Token.AND;
                } else {
                    token = Token.BITWISE_AND;
                }
            },
            '|' => {
                if (l.peekChar() == '|') {
                    l.readChar();
                    token = Token.OR;
                } else {
                    token = Token.BITWISE_OR;
                }
            },
            '<' => {
                if (l.peekChar() == '=') {
                    const ch = l.ch;
                    _ = ch;
                    l.readChar();
                    token = Token.LTE;
                } else {
                    token = Token.LT;
                }
            },
            '>' => {
                if (l.peekChar() == '=') {
                    l.readChar();
                    token = Token.GTE;
                } else {
                    token = Token.GT;
                }
            },
            0 => token = Token.EOF,
            else => {},
        }

        if (token == null and isLetterOrUnderscore(l.ch)) {
            const literal = l.readIdentifier();

            token = if (std.mem.eql(u8, "fn", literal))
                Token.FUNCTION
            else if (std.mem.eql(u8, "let", literal))
                Token.LET
            else if (std.mem.eql(u8, "if", literal))
                Token.IF
            else if (std.mem.eql(u8, "else", literal))
                Token.ELSE
            else if (std.mem.eql(u8, "return", literal))
                Token.RETURN
            else if (std.mem.eql(u8, "true", literal))
                Token.TRUE
            else if (std.mem.eql(u8, "false", literal))
                Token.FALSE
            else
                Token{ .IDENT = literal };

            return token.?;
        }

        if (token == null and isDigit(l.ch)) {
            const literal = l.readNumber();
            token = Token{ .INT = literal };
            return token.?;
        }

        defer l.readChar();
        return token orelse Token{ .ILLEGAL = &([1]u8{l.ch}) };
    }
};

pub fn getLexer(input: []const u8) Lexer {
    var l = Lexer{
        .input = input,
        .position = 0,
        .readPosition = 0,
        .ch = ' ',
    };
    l.readChar();
    return l;
}
