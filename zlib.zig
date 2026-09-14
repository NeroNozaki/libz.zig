const std = @import("std");
const linux = std.os.linux;

pub fn getchar() ?u8 {
    var byte: [1]u8 = undefined;

    const result = linux.read(0, &byte, 1);

    if (result == 1) return byte[0];
    return null;
}

pub fn putchar(c:u8) usize {
    return linux.write(1, @ptrCast(&c), 1);
}

pub fn print(fmt:[]const u8, args:anytype) usize {
    var arg_index:usize = 0;
    var in_field:bool = false;
    var specifier:u8 = undefined;

    for (fmt) |c| {
        if (c == '{') {
            in_field = true;
            continue;
        }
        if (c == '}') {
            in_field = false;

            inline for (args, 0..) |arg, i| {
                if (i == arg_index) {
                    // do something
                    switch (specifier) {
                        'd' => {
                            return print_int(arg);
                        },
                        'c' => {
                            return putchar(arg);
                        },
                        'f' => {
                            // print argument as a float
                        },
                        's' => {
                            // print argument as a string
                        },
                        else => {
                            return 0;
                        },
                    }
                    arg_index+=1;
                    break;
                }
            }
            continue;
        }

        if (in_field) {
            specifier = c;
        } else {
            return putchar(c);
        }
    }
}

fn int_to_string(int:i32) [32]u8 {
    var string:[32]u8 = undefined;
    if (int == 0) {
        string[0] = '0';
    }
    var i = string.len;
    var x = int;
    while (x > 0) {
        i -= 1;
        string[i] = '0' + @as(u8, @intCast(@mod(x, 10)));
        x = @divFloor(x, 10);
    }
    return string;
}
pub fn print_int(int:anytype) usize {
    var buf:[32]u8 = undefined;
    var i = buf.len;
    switch(@typeInfo(@TypeOf(int))) {
        .int => |info| {
            if (int == 0) {
                return linux.write(1, "0", 1);
            }
            if (info.signedness == .signed) {
                var x:u64 = if (int < 0) @abs(int) else @intCast(int);
                    
                while (x > 0) {
                    i -= 1;
                    buf[i] = '0' + @as(u8, @intCast(x % 10));
                    x /= 10;
                }
                i-=1;
                buf[i] = '-';
                return linux.write(1, @ptrCast(&buf[i]), buf.len - i);
            } else {
                var x = int;
                while (x > 0) {
                    i -= 1;
                    buf[i] = '0' + @as(u8, @intCast(x % 10));
                    x /= 10;
                }
                return linux.write(1, @ptrCast(&buf[i]), buf.len - i);
            }
        },
        .comptime_int => {
            if (int < 0) {
                return print_int(@as(i64, int));
            } else {
                return print_int(@as(u64, int));
            }
        },
        .bool => {
            if (int) {
                return putchar('1');
            } else {
                return putchar('0');
            }
        },
        else => unreachable
    }
}
