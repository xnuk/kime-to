#![cfg(unix)]
use std::io::Write;
use std::os::unix::ffi::OsStrExt;
use std::os::unix::net::UnixStream;
use std::path::PathBuf;
use std::process::ExitCode;
use std::time::Duration;

#[inline]
fn socket_path() -> PathBuf {
	kime_run_dir::get_run_dir_impl().join("kime-indicator.sock")
}

#[inline]
fn parse_args() -> Option<u8> {
	let lang =
		std::env::args_os().skip(1).last()?.as_bytes()[0].to_ascii_lowercase();

	match lang {
		// "ko" | "hangul"
		b'k' | b'h' => Some(1),
		// "en" | "latin"
		b'e' | b'l' => Some(0),
		_ => None,
	}
}

const BIN_NAME: &str = env!("CARGO_BIN_NAME");

fn main() -> ExitCode {
	let Some(input) = parse_args() else {
		eprintln!("Usage:  `{BIN_NAME} hangul`  or  `{BIN_NAME} latin`");
		return ExitCode::FAILURE;
	};

	let Ok(mut sock) = UnixStream::connect(socket_path()) else {
		eprintln!("Failed to connect to kime. Is kime running?");
		return ExitCode::FAILURE;
	};

	sock.set_read_timeout(Some(Duration::from_secs(0))).ok();
	sock.set_write_timeout(Some(Duration::from_secs(2))).ok();
	sock.write_all(&[input]).unwrap();

	ExitCode::SUCCESS
}
