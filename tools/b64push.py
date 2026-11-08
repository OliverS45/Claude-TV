#!/usr/bin/env python3
"""Fallback file transfer: send a file to the TV as base64 chunks through plain shell commands.

Usage: b64push.py <local file> <remote path>
"""
import base64
import hashlib
import os
import shlex
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tv  # noqa: E402

CHUNK = 48 * 1024  # raw bytes per shell command (base64 grows it by 4/3)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: b64push.py <local file> <remote path>")
    local, remote = sys.argv[1], sys.argv[2]
    data = open(local, "rb").read()
    want = hashlib.md5(data).hexdigest()
    dev = tv.connect()
    tmp = remote + ".b64"
    q_remote, q_tmp = shlex.quote(remote), shlex.quote(tmp)
    dev.shell(f"rm -f {q_remote} {q_tmp}")
    n = (len(data) + CHUNK - 1) // CHUNK
    got = ""
    try:
        for i in range(n):
            part = base64.b64encode(data[i * CHUNK:(i + 1) * CHUNK]).decode()
            out = dev.shell(f"echo '{part}' >> {q_tmp} && echo ok{i}", read_timeout_s=60.0)
            if f"ok{i}" not in out:
                print(f"chunk {i} failed: {out}")
                return 1
            print(f"\rchunk {i + 1}/{n}", end="", flush=True)
        print()
        out = dev.shell(f"base64 -d {q_tmp} > {q_remote} && md5sum {q_remote}", read_timeout_s=120.0)
        got = out.split()[0] if out.strip() else ""
        print("md5 remote:", got, "local:", want, "MATCH" if got == want else "MISMATCH")
        return 0 if got == want else 1
    finally:
        # Never leave the partial upload behind; drop a corrupt copy too.
        try:
            dev.shell(f"rm -f {q_tmp}" if got == want else f"rm -f {q_tmp} {q_remote}")
        finally:
            dev.close()


if __name__ == "__main__":
    sys.exit(main())
