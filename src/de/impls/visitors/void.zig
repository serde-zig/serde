const de = @import("../../../lib.zig").de;

const Self = @This();

const Value = void;

/// Implements `getty.de.Visitor`.
pub fn visitor(self: *Self) V {
    return .{ .context = self };
}

const V = de.Visitor(
    *Self,
    Value,
    visitBool,
    visitFloat,
    visitInt,
    visitMap,
    visitNull,
    visitSequence,
    visitSome,
    visitString,
    visitVariant,
    visitVoid,
);

fn visitBool(self: *Self, comptime Error: type, input: bool) Error!Value {
    _ = self;
    _ = input;

    @panic("Unsupported");
}

fn visitInt(self: *Self, comptime Error: type, input: anytype) Error!Value {
    _ = self;
    _ = input;

    @panic("Unsupported");
}

fn visitFloat(self: *Self, comptime Error: type, input: anytype) Error!Value {
    _ = self;
    _ = input;

    @panic("Unsupported");
}

fn visitMap(self: *Self, mapAccess: anytype) @TypeOf(mapAccess).Error!Value {
    _ = self;

    @panic("Unsupported");
}

fn visitNull(self: *Self, comptime Error: type) Error!Value {
    _ = self;

    @panic("Unsupported");
}

fn visitSequence(self: *Self, sequenceAccess: anytype) @TypeOf(sequenceAccess).Error!Value {
    _ = self;

    @panic("Unsupported");
}

fn visitSome(self: *Self, deserializer: anytype) @TypeOf(deserializer).Error!Value {
    _ = self;

    @panic("Unsupported");
}

fn visitString(self: *Self, comptime Error: type, input: anytype) Error!Value {
    _ = self;
    _ = input;

    @panic("Unsupported");
}

fn visitVariant(self: *Self, comptime Error: type, input: anytype) Error!Value {
    _ = self;
    _ = input;

    @panic("Unsupported");
}

fn visitVoid(self: *Self, comptime Error: type) Error!Value {
    _ = self;

    return {};
}
