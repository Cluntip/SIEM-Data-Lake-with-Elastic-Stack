#!/usr/bin/env python3
"""Submit a JSON alert payload to TheHive."""

from __future__ import annotations

import argparse
import json
import os
import ssl
import sys
import urllib.request
from pathlib import Path


def post_json(url: str, api_key: str, payload: dict, insecure: bool = True) -> dict:
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": api_key,
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        method="POST",
    )
    context = ssl._create_unverified_context() if insecure else None
    with urllib.request.urlopen(request, context=context) as response:
        body = response.read().decode("utf-8")
    return json.loads(body)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default=os.environ.get("THEHIVE_URL", "http://localhost:9000"))
    parser.add_argument("--api-key", default=os.environ.get("THEHIVE_API_KEY", ""))
    parser.add_argument("--endpoint", default=os.environ.get("THEHIVE_ALERT_ENDPOINT", "/api/v1/alert"))
    parser.add_argument("--json-file", default="data/sample_alert.json")
    args = parser.parse_args()

    if not args.api_key:
        print("TheHive API key is required via --api-key or THEHIVE_API_KEY.", file=sys.stderr)
        return 2

    payload = json.loads(Path(args.json_file).read_text(encoding="utf-8"))
    response = post_json(f"{args.base_url}{args.endpoint}", args.api_key, payload)
    print(json.dumps(response, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
