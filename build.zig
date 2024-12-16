const std = @import("std");
const zig_version = @import("builtin").zig_version;

comptime {
	// 0.13.x
	if (!(zig_version.major == 0 and zig_version.minor == 13)) {
		@compileError("Your zig version is not compatible with 0.13.x");
	}
}

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
