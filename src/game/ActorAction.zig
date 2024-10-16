const std = @import("std");
const engine = @import("../engine/engine.zig");
const Actor = @import("Actor.zig");
const Level = @import("Level.zig");
const ActionPreview = @import("ActionPreview.zig");
const CellTransform = @import("CellTransform.zig");

const ActorAction = @This();

const Allocator = std.mem.Allocator;
const ActionType = Actor.ActionType;
const Vector2 = engine.maths.Vector.Vector2;

allocator: Allocator,
level: *Level,
caster: *Actor,
action_type: ActionType,
preview: ?*ActionPreview = null,
target_cell: ?Vector2(i16) = null,

pub fn init(allocator: Allocator, level: *Level, caster: *Actor, action_type: ActionType, cell: Vector2(i16)) !*ActorAction {
    const ptr = try allocator.create(ActorAction);

    ptr.* = .{
        .level = level,
        .caster = caster,
        .action_type = action_type,
        .allocator = allocator,
        .target_cell = cell,
    };

    ptr.*.preview = try ActionPreview.init(allocator, cell, ptr, level.tilemap);

    return ptr;
}

pub fn deinit(self: *const ActorAction) !void {
    if (self.preview) |prw| {
        try prw.deinit();
    }
    self.allocator.destroy(self);
}

pub fn resolve(self: *const ActorAction) !void {
    const cell = self.target_cell.?;

    switch (self.action_type) {
        ActionType.Move => {
            if (self.level.getActorOnCell(cell)) |target| {
                try self.caster.attack(target);
            } else if (try self.level.isCellWalkable(cell)) {
                self.caster.move(cell);
            } else {
                return;
            }
        },
        ActionType.Attack => {
            if (self.level.getActorOnCell(cell)) |target| {
                try self.caster.attack(target);
            }
        },
    }
}
