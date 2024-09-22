const std = @import("std");
const raylib = @import("raylib.zig");
const Level = @import("Level.zig");
const Tilemap = @import("Tilemap.zig");
const Actor = @import("Actor.zig");
const Tileset = @import("Tileset.zig");
const Vector = @import("Vector.zig");
const Rect = @import("Rect.zig").Rect;
const Inputs = @import("Inputs.zig");
const Globals = @import("Globals.zig");

const Vector2 = Vector.Vector2;

const game_name = "Zig Dungeon";
const window_width = 960;
const window_height = 540;
const target_fps = 60;
const background_color = raylib.BLACK;

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    
    Globals.random = prng.random();
    
    const window_rect = Rect(f32).init(0, 0, window_width, window_height);

    raylib.InitWindow(window_width, window_height, game_name);
    raylib.SetTargetFPS(target_fps);

    defer raylib.CloseWindow();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var character = try Actor.init("sprites/character/Character.png", Vector2(i16).One(), Actor.ActorType.Character, allocator);
    var enemy = try Actor.init("sprites/character/Enemy.png", Vector2(i16).init(2, 1), Actor.ActorType.Enemy, allocator);

    var level = try Level.init("Levels/Level1.png", "sprites/tilesets/Biome1Tileset.png", allocator);
    try level.addActor(&character);
    try level.addActor(&enemy);

    level.tilemap.center(window_rect);

    // Setup the render texture, where the whole game is going to be drawn to
    const render_texture = raylib.LoadRenderTexture(window_width, window_height);
    defer raylib.UnloadRenderTexture(render_texture);

    while (!raylib.WindowShouldClose()) {

        // Inputs handeling
        const inputs = Inputs.read();

        level.input(&inputs) catch {
            std.debug.print("Cannot go this way\n", .{});
        };

        // Rendering
        raylib.BeginTextureMode(render_texture);
        raylib.ClearBackground(background_color);
        try level.draw();
        raylib.EndTextureMode();

        raylib.BeginDrawing();
        raylib.DrawTexturePro(
            render_texture.texture,
            window_rect.flipRectY().toRaylib(),
            window_rect.toRaylib(),
            Vector2(f32).Zero().toRaylib(),
            0.0,
            raylib.WHITE,
        );
        raylib.EndDrawing();
    }
}
