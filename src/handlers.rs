use axum::body::Bytes;
use axum::extract::ConnectInfo;
use axum::http::{HeaderMap, Method, Uri, Version};
use std::net::SocketAddr;

pub async fn echo(
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
    method: Method,
    uri: Uri,
    version: Version,
    headers: HeaderMap,
    body: Bytes,
) -> String {
    let mut out = String::new();
    out.push_str(&format!("{method}, {uri}, {version:?}\n"));

    out.push_str(&format!("From: {addr:?}\n"));
    out.push_str("Headers:\n");
    for (key, value) in headers.iter() {
        out.push_str(&format!("  {key}: {value:?}\n"));
    }
    out.push_str("Body:\n");
    out.push_str(&format!("  {}\n", String::from_utf8_lossy(&body)));

    println!("\n{out}");

    out
}
