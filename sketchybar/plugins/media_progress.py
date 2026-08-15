#!/usr/bin/env python3
import json
import os
import subprocess
import time

STATE = "/tmp/sb_media_progress"
STALE = 60.0  # freeze if no real push for this long (non-Spotify fallback)


def read_media():
    try:
        out = subprocess.check_output(
            ["nowplaying-cli", "get-raw"], stderr=subprocess.DEVNULL
        )
        return json.loads(out.decode())
    except Exception:
        return None


def spotify_state():
    try:
        out = subprocess.check_output(
            [
                "osascript",
                "-e",
                "tell application \"Spotify\" to {player state, player position, duration of current track}",
            ],
            stderr=subprocess.DEVNULL,
        )
        parts = [p.strip() for p in out.decode().strip().split(",")]
        if len(parts) < 3:
            return None
        st, pos, dur = parts[0], parts[1], parts[2]
        return {"state": st, "pos": float(pos), "dur": float(dur) / 1000.0}
    except Exception:
        return None


def load_state():
    default = {"el": 0.0, "ts": time.time(), "rate": 0.0, "du": 0.0, "pts": time.time()}
    if not os.path.exists(STATE):
        return default
    try:
        with open(STATE) as f:
            el, ts, rate, du, pts = f.read().split()
        return {
            "el": float(el),
            "ts": float(ts),
            "rate": float(rate),
            "du": float(du),
            "pts": float(pts),
        }
    except Exception:
        return default


def main():
    d = read_media()
    client = ""
    if d is not None:
        client = d.get("kMRMediaRemoteNowPlayingInfoClientBundleIdentifier") or ""

    if client == "com.spotify.client":
        s = spotify_state()
        if s is None:
            print(0)
            return
        if s["state"] == "paused" or s["state"] == "stopped" or s["dur"] <= 0:
            pct = int(s["pos"] * 100 / s["dur"]) if s["dur"] > 0 else 0
            print(max(0, min(100, pct)))
            return
        pct = int(s["pos"] * 100 / s["dur"]) if s["dur"] > 0 else 0
        print(max(0, min(100, pct)))
        return

    if d is None:
        try:
            os.unlink(STATE)
        except FileNotFoundError:
            pass
        print(0)
        return

    el = d.get("kMRMediaRemoteNowPlayingInfoElapsedTime")
    du = d.get("kMRMediaRemoteNowPlayingInfoDuration")
    rate = d.get("kMRMediaRemoteNowPlayingInfoPlaybackRate") or 0.0
    now = time.time()

    if not du:
        print(0)
        return

    prev = load_state()
    fresh_push = el is not None and el != prev["el"]
    rate_changed = rate != prev["rate"]

    if du != prev["du"] or (fresh_push and not prev["el"]):
        prev = {"el": 0.0, "ts": now, "rate": rate, "du": float(du), "pts": now}

    if rate_changed:
        prev["pts"] = now

    extrap = prev["el"] + (now - prev["ts"]) * prev["rate"]

    if rate > 0:
        if el and (el >= extrap - 0.5 or extrap - el > 30):
            cur = el
            prev = {"el": el, "ts": now, "rate": rate, "du": float(du), "pts": now}
        elif now - prev["pts"] < STALE:
            cur = extrap
        else:
            cur = prev["el"]
        prev["rate"] = rate
    else:
        cur = el if el else prev["el"]
        prev["rate"] = 0.0

    cur = max(0.0, min(cur, float(du)))
    pct = max(0, min(100, int(cur * 100 / du)))

    with open(STATE, "w") as f:
        f.write(f"{cur} {now} {prev['rate']} {du} {prev['pts']}")

    print(pct)


if __name__ == "__main__":
    main()