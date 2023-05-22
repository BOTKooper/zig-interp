pub const TokenType = enum {
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

pub const Token = struct {
    Type: TokenType,
    Literal: []const u8,
};

pub fn buildToken(tokenType: TokenType, ch: u8, ch2: ?u8) Token {
    if (ch2 == null) {
        return Token{
            .Type = tokenType,
            .Literal = &([_]u8{ch}),
        };
    }

    return Token{
        .Type = tokenType,
        .Literal = &([_]u8{ ch, ch2.? }),
    };
}
