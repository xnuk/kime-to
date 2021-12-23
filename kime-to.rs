#![cfg(unix)]
use std::io::Write;
use std::os::unix::net::UnixStream;
use std::path::PathBuf;
use std::time::Duration;

#[inline]
fn socket_path() -> PathBuf {
	kime_run_dir::get_run_dir().join("kime-indicator.sock")
}

#[inline]
fn parse_args() -> Option<u8> {
	let lang = std::env::args_os()
		.skip(1)
		.last()?
		.to_str()?
		.to_ascii_lowercase()
		.trim()
		.to_owned();

	match lang.as_str() {
		"ko" | "korean" | "ko-kr" | "han" | "hangul" | "hangeul" => Some(1),
		"en" | "eng" | "english" | "latin" => Some(0),
		_ => None,
	}
}

const BIN_NAME: &str = env!("CARGO_BIN_NAME");

fn main() -> anyhow::Result<()> {
	let input = match parse_args() {
		None => {
			return Err(anyhow::anyhow!(
				"Usage:  `{BIN_NAME} hangul`  or  `{BIN_NAME} latin`"
			));
		}
		Some(x) => x,
	};

	let mut sock = UnixStream::connect(socket_path())?;
	sock.set_read_timeout(Some(Duration::from_secs(0))).ok();
	sock.set_write_timeout(Some(Duration::from_secs(2))).ok();
	sock.write_all(&[input])?;

	Ok(())
}
