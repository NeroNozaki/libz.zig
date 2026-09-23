const std = @import("std");
const gpa = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        capacity:usize,
        size:usize,
        elems:[]T,

        fn push(element:T) void {
            if (Self.capacity == Self.size) {
                Self.capacity *= 2;
                if (Self.capacity < 16) Self.capacity = 16;
                Self.elems = gpa.realloc(gpa, Self.elems, Self.size * @sizeOf(T));
            }
            Self.size+=1;
            Self.elems[Self.size]=element;
        }
        fn pop() type {
            if (Self.size > 0) {
                defer Self.size-=1;
                return Self.elems[Self.size];
            }
            unreachable;
        }
        fn empty() bool {
            return !Self.size;
        }

        fn init() void {
            Self.elems = gpa.alloc(gpa, T, @sizeOf(T));
        }
    };
}

// fn void Stack.push(Stack* this, Type element) {
// if (this.capacity == this.size) {
// this.capacity *= 2;
// if (this.capacity < 16) this.capacity = 16;
// this.elems = realloc(this.elems, Type.sizeof * this.capacity);
// }
// this.elems[this.size++] = element;
// }

// fn Type Stack.pop(Stack* this) {
// assert(this.size > 0);
// return this.elems[--this.size];
// }

// fn bool Stack.empty(Stack* this) {
// return !this.size;
// }
