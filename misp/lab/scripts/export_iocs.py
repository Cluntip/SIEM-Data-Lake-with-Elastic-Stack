#!/usr/bin/env python3
"""Export a MISP event as JSON or CSV through the REST API."""

from __future__ import annotations

import argparse
import csv
import json
import os
import ssl
import sys
import urllib.request
from pathlib import Path


def request_json(url: str, api_key: str, insecure: bool = True) -> dict:
    request = urllib.request.Request(
        url,
        headers={"Authorization": api_key, "Accept": "application/json"},
        method="GET",
    )
    context = ssl._create_unverified_context() if insecure else None
    with urllib.request.urlopen(request, context=context) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("event_id", type=int)
    parser.add_argument("--base-url", default=os.environ.get("BASE_URL", "https://localhost:8444"))
    parser.add_argument("--api-key", default=os.environ.get("MISP_API_KEY", ""))
    parser.add_argument("--csv-out")
    parser.add_argument("--json-out")
    args = parser.parse_args()

    if not args.api_key:
        print("MISP API key is required via --api-key or MISP_API_KEY.", file=sys.stderr)
        return 2

    payload = request_json(f"{args.base_url}/events/view/{args.event_id}", args.api_key)
    if args.json_out:
        Path(args.json_out).write_text(json.dumps(payload, indent=2), encoding="utf-8")

    attributes = payload.get("Event", {}).get("Attribute", [])
    if args.csv_out:
        with Path(args.csv_out).open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=["category", "type", "value", "comment", "to_ids", "distribution"])
            writer.writeheader()
            for attribute in attributes:
                writer.writerow(
                    {
                        "category": attribute.get("category", ""),
                        "type": attribute.get("type", ""),
                        "value": attribute.get("value", ""),
                        "comment": attribute.get("comment", ""),
                        "to_ids": attribute.get("to_ids", ""),
                        "distribution": attribute.get("distribution", ""),
                    }
                )

    print(f"Exported {len(attributes)} attributes from event {args.event_id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
