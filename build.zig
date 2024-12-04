const std = @import("std");
pub fn build(b: *std.Build) void {
	const exe = b.addExecutable(.{
		.name = "kime-to",
		.root_source_file = b.path("main.zig"),
		.target = b.standardTargetOptions(.{}),
		.optimize = .ReleaseSmall,
		.single_threaded = true,
		.strip = true,
	});
	b.installArtifact(exe);
}
