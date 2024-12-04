const std = @import("std");

fn err_exit() noreturn {
	std.posix.exit(1);
}

fn usage() noreturn {
	std.io.getStdErr().writeAll(
		"Usage:\n    kime-to ko\n    kime-to en\n"
	) catch {};
	err_exit();
}

fn get_kime_sock_path(alloc: std.mem.Allocator) ![]const u8 {
	const getenv = std.posix.getenv;
	const concat = std.mem.concat;

	const filename = "kime-indicator.sock";
	const base = getenv("XDG_RUNTIME_DIR") orelse "";

	if (base.len > 0) {
		if (base[base.len - 1] != '/') {
			return concat(alloc, u8, &[_][]const u8{ base, "/", filename });
		} else {
			return concat(alloc, u8, &[_][]const u8{ base, filename });
		}
	} else {
		const uid = getenv("UID") orelse "";
		if (uid.len > 0) {
			return concat(
				alloc, u8, &[_][]const u8{ "/tmp/kime-", uid, "/", filename }
			);
		} else {
			return concat(alloc, u8, &[_][]const u8{ "/tmp/", filename });
		}
	}
}

pub fn main() !void {
	const argv = std.os.argv;
	const len = argv.len;
	if (len < 2) {
		usage();
	}
	var arg = argv[len - 1][0];
	if (arg < 'a') {
		arg += 'a' - 'A';
	}

	const request: u8 = switch (arg) {
		'h', 'k' => 1,
		'l', 'e' => 0,
		else => 255,
	};
	if (request > 1) {
		usage();
	}

	var buffer: [512]u8 = undefined;
	var fba = std.heap.FixedBufferAllocator.init(&buffer);
	const alloc = fba.allocator();
	const path = get_kime_sock_path(alloc) catch {
		err_exit();
	};
	var stream = std.net.connectUnixSocket(path) catch {
		std.io.getStdErr().writeAll(
			"Failed to connect to kime. Is kime running?\n"
		) catch {};
		err_exit();
	};
	try stream.writeAll(&[1]u8{request});
	stream.close();
}
