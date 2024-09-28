const std = @import("std");
const engine = @import("engine/engine.zig");
const Level = @import("Level.zig");
const Actor = @import("Actor.zig");
const Tileset = engine.tiles.Tileset;
const Tilemap = engine.tiles.Tilemap;
const Vector2 = engine.maths.Vector.Vector2;
const project_settings = engine.core.project_settings;

const game_name = "Zig Dungeon";

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var character = try Actor.init("sprites/character/Character.png", Vector2(i16).One(), Actor.ActorType.Character, allocator);
    var enemy = try Actor.init("sprites/character/Enemy.png", Vector2(i16).init(2, 1), Actor.ActorType.Enemy, allocator);

    var level = try Level.init("Levels/Level1.png", "sprites/tilesets/Biome1Tileset.png", allocator);
    try level.addActor(&character);
    try level.addActor(&enemy);

    level.tilemap.center(project_settings.window_rect);
}
