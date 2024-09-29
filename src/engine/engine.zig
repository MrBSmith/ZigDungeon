const std = @import("std");
pub const core = @import("core/core.zig");
pub const maths = @import("maths/maths.zig");
pub const sprites = @import("sprites/sprites.zig");
pub const events = @import("events/events.zig");
pub const tiles = @import("tiles/tiles.zig");
pub const traits = @import("traits/traits.zig");
pub const raylib = core.raylib;
const engine_events = events.engine_events;

const program_start_timestamp = std.time.milliTimestamp();
var last_timestamp = 0;
var current_timestamp = program_start_timestamp;

pub var random: std.Random = undefined;
pub var process_time: f32 = 0.0;
pub var delta: f32 = 0.0;

pub fn init() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try core.globals.init();
    try events.engine_events.init(allocator);
    try core.renderer.init();

    while (!raylib.WindowShouldClose()) {
        try mainLoop();
    }

    defer raylib.CloseWindow();
}

pub fn mainLoop() !void {
    // Call global process event
    try engine_events.event_emitter.emit(engine_events.EngineEvents.Process);

    // Read input events
    const inputs = core.inputs.read();

    // Call global inputs event
    try engine_events.event_emitter.emitWithContext(engine_events.EngineEvents.Inputs, &inputs);

    // Render the game frame
    try core.renderer.render();
}

pub fn process() !void {
    last_timestamp = current_timestamp;
    current_timestamp = std.time.milliTimestamp();
}

/// Returns the amount of ms the game has been running for
pub fn gameStartMs() i64 {
    return std.time.milliTimestamp() - program_start_timestamp;
}