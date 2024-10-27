const std = @import("std");
const engine = @import("../engine/engine.zig");
const Actor = @import("Actor.zig");
const Level = @import("Level.zig");
const CellTransform = @import("CellTransform.zig");
const Sprite = engine.sprites.Sprite;
const trigo = engine.maths.trigo;
const Color = engine.Color;
const Tilemap = engine.tiles.Tilemap;
const Vector2 = engine.maths.Vector2;
const Allocator = std.mem.Allocator;

const arrow_texture_path = "sprites/ui/EnemyActions/Arrow.png";

pub const ActorAction = union(enum) {
    move: MoveAction,

    pub fn resolve(self: ActorAction) !void {
        switch (self) {
            inline else => |case| try case.resolve(),
        }
    }

    pub fn preview(self: ActorAction, allocator: Allocator) !ActionPreview {
        return switch (self) {
            inline else => |case| try case.preview(allocator),
        };
    }
};

pub const ActionPreview = union(enum) {
    move: *MoveActionPreview,

    pub fn deinit(self: ActionPreview) !void {
        switch (self) {
            inline else => |case| try case.deinit(),
        }
    }
};

/// Action Preview struct. Draw the preview of an actor's action on the map.
pub const MoveActionPreview = struct {
    allocator: Allocator,
    cell_transform: CellTransform,
    sprite: *Sprite,

    pub fn init(allocator: Allocator, direction: Vector2(i16), cell: Vector2(i16), tilemap: *Tilemap) !*MoveActionPreview {
        const ptr = try allocator.create(MoveActionPreview);

        ptr.* = .{
            .allocator = allocator,
            .cell_transform = CellTransform.init(cell, &tilemap.transform),
            .sprite = try Sprite.init(
                allocator,
                arrow_texture_path,
                &ptr.cell_transform.transform,
                2,
                Color.red,
            ),
        };

        const dir = direction.floatFromInt(f32);
        ptr.cell_transform.transform.rotation = trigo.radToDeg(f32, dir.angle());
        ptr.sprite.render_trait.tint = Color.red.toRaylib();
        ptr.sprite.pivot = Vector2(f32).initOneValue(16);

        return ptr;
    }

    pub fn deinit(self: *const MoveActionPreview) !void {
        try self.sprite.deinit();
        self.allocator.destroy(self);
    }
};

pub const MoveAction = struct {
    caster: *Actor,
    to: Vector2(i16),
    level: *Level,

    pub fn resolve(self: *const MoveAction) !void {
        self.caster.move(self.to);
    }

    pub fn preview(self: *const MoveAction, allocator: Allocator) !ActionPreview {
        const dir: Vector2(i16) = self.to.minus(self.caster.cell_transform.cell);
        return ActionPreview{ .move = try MoveActionPreview.init(allocator, dir, self.to, self.level.tilemap) };
    }
};
