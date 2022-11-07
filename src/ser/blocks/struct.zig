//! The default Serialization Block for struct values.

const std = @import("std");

const ser = @import("../../ser.zig");

pub fn is(comptime T: type) bool {
    return @typeInfo(T) == .Struct and !@typeInfo(T).Struct.is_tuple;
}

pub fn serialize(value: anytype, serializer: anytype) @TypeOf(serializer).Error!@TypeOf(serializer).Ok {
    const T = @TypeOf(value);
    const fields = std.meta.fields(T);
    const attributes = comptime ser.ser.getAttributes(T, @TypeOf(serializer));

    var s = try serializer.serializeStruct(@typeName(T), fields.len);
    const st = s.structure();

    inline for (fields) |field| {
        if (field.field_type != void) {
            comptime var name: []const u8 = field.name;

            if (attributes) |attrs| {
                if (@hasField(@TypeOf(attrs), field.name)) {
                    const attr = @field(attrs, field.name);

                    if (@hasField(@TypeOf(attr), "skip") and attr.skip) {
                        continue;
                    }

                    if (@hasField(@TypeOf(attr), "rename")) {
                        name = attr.rename;
                    }
                }
            }

            try st.serializeField(name, @field(value, field.name));
        }
    }

    return try st.end();
}
