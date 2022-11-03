const std = @import("std");

pub fn is_sbt(comptime sbt: anytype) bool {
    comptime {
        const SBT = @TypeOf(sbt);

        switch (SBT == type) {
            true => {
                const info = @typeInfo(sbt);

                // Check SB is a namespace.
                if (info != .Struct or info.Struct.is_tuple) {
                    return false;
                }

                // Check number of fields.
                if (info.Struct.fields.len != 0) {
                    return false;
                }

                // Check number of declarations.
                var num_decls = 0;
                for (info.Struct.decls) |decl| {
                    if (decl.is_pub) {
                        num_decls += 1;
                    }
                }
                if (num_decls != 2) {
                    return false;
                }

                // Check functions.
                //
                // We've already checked that there are only two declarations, so
                // we don't need to check that only `serialize` or `attributes` is
                // declared. Checking that either one of them exists is good enough
                // as the other declaration must be `is`.
                if (!std.meta.trait.hasFunctions(sbt, .{"is"})) {
                    return false;
                }

                if (!std.meta.trait.hasFunctions(sbt, .{"serialize"}) and !@hasDecl(sbt, "attributes")) {
                    return false;
                }

                if (@hasDecl(sbt, "attributes")) {
                    const attr_info = @typeInfo(@TypeOf(@field(sbt, "attributes")));
                    if (attr_info != .Struct or attr_info.Struct.is_tuple) {
                        return false;
                    }
                }
            },
            false => {
                const info = @typeInfo(SBT);

                // Check that the ST is a tuple.
                if (info == .Struct and info.Struct.is_tuple) {
                    // Check each SB in the ST.
                    for (std.meta.fields(SBT)) |field| {
                        if (!is_sbt(@field(sbt, field.name))) {
                            return false;
                        }
                    }
                } else {
                    // Check that the ST contains only types.
                    return false;
                }
            },
        }

        return true;
    }
}

test "SB" {
    // Not a type.
    try std.testing.expect(!is_sbt(1));
    try std.testing.expect(!is_sbt("foo"));
    try std.testing.expect(!is_sbt(.{ 1, 2, 3 }));
    try std.testing.expect(!is_sbt(.{ .x = 1, .serialize = 2 }));

    // Not a POD struct type.
    try std.testing.expect(!is_sbt(i32));
    try std.testing.expect(!is_sbt([]u8));
    try std.testing.expect(!is_sbt(*struct {}));
    try std.testing.expect(!is_sbt(std.meta.Tuple(&.{ i32, i32 })));

    // Non-zero number of fields.
    try std.testing.expect(!is_sbt(struct { x: i32 }));
    try std.testing.expect(!is_sbt(struct { x: i32, y: i32 }));

    // Incorrect number of declarations.
    try std.testing.expect(!is_sbt(struct {
        pub const x: i32 = 0;
    }));

    try std.testing.expect(!is_sbt(struct {
        pub fn foo() void {
            unreachable;
        }
    }));

    try std.testing.expect(!is_sbt(struct {
        pub fn is() void {
            unreachable;
        }

        pub fn serialize() void {
            unreachable;
        }

        pub const attributes = .{};
    }));

    // Incorrect functions.
    try std.testing.expect(!is_sbt(struct {
        pub fn foo() void {
            unreachable;
        }

        pub fn bar() void {
            unreachable;
        }
    }));

    // Success
    try std.testing.expect(is_sbt(struct {
        pub fn is() void {
            unreachable;
        }

        pub fn serialize() void {
            unreachable;
        }
    }));

    try std.testing.expect(is_sbt(struct {
        pub fn is() void {
            unreachable;
        }

        pub const attributes = .{};
    }));
}

test "ST" {
    // Not a type.
    try std.testing.expect(!is_sbt(.{1}));
    try std.testing.expect(!is_sbt(.{"foo"}));
    try std.testing.expect(!is_sbt(.{.{ 1, 2, 3 }}));
    try std.testing.expect(!is_sbt(.{.{ .x = 1, .serialize = 2 }}));

    // Not a POD struct type.
    try std.testing.expect(!is_sbt(.{i32}));
    try std.testing.expect(!is_sbt(.{[]u8}));
    try std.testing.expect(!is_sbt(.{*struct {}}));
    try std.testing.expect(!is_sbt(.{std.meta.Tuple(&.{ i32, i32 })}));

    // Non-zero number of fields.
    try std.testing.expect(!is_sbt(.{struct { x: i32 }}));
    try std.testing.expect(!is_sbt(.{struct { x: i32, y: i32 }}));

    // Incorrect number of declarations.
    try std.testing.expect(!is_sbt(.{struct {
        pub const x: i32 = 0;
    }}));

    try std.testing.expect(!is_sbt(.{struct {
        pub fn foo() void {
            unreachable;
        }
    }}));

    try std.testing.expect(!is_sbt(.{struct {
        pub fn is() void {
            unreachable;
        }

        pub fn serialize() void {
            unreachable;
        }

        pub const attributes = .{};
    }}));

    // Incorrect functions.
    try std.testing.expect(!is_sbt(.{struct {
        pub fn foo() void {
            unreachable;
        }

        pub fn bar() void {
            unreachable;
        }
    }}));

    // Success
    try std.testing.expect(is_sbt(.{struct {
        pub fn is() void {
            unreachable;
        }

        pub fn serialize() void {
            unreachable;
        }
    }}));

    try std.testing.expect(is_sbt(.{struct {
        pub fn is() void {
            unreachable;
        }

        pub const attributes = .{};
    }}));
}
