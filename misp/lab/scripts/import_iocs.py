#!/usr/bin/env python3
"""Import IOC rows from CSV into a MISP event via the REST API."""

from __future__ import annotations

import argparse
import csv
import json
import os
import ssl
import sys
import urllib.request
from pathlib import Path


def request_json(url: str, api_key: str, payload: dict | None = None, method: str = "GET", insecure: bool = True) -> dict:
    data = None
    headers = {
        "Authorization": api_key,
        "Accept": "application/json",
        "Content-Type": "application/json",
    }
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    context = ssl._create_unverified_context() if insecure else None
    with urllib.request.urlopen(request, context=context) as response:
        body = response.read().decode("utf-8")
    return json.loads(body)


def load_rows(csv_path: Path) -> list[dict[str, str]]:
    with csv_path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def build_event_payload(info: str, distribution: int, threat_level_id: int, analysis: int) -> dict:
    return {
        "Event": {
            "info": info,
            "distribution": distribution,
            "threat_level_id": threat_level_id,
            "analysis": analysis,
        }
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default=os.environ.get("BASE_URL", "https://localhost:8444"))
    parser.add_argument("--api-key", default=os.environ.get("MISP_API_KEY", ""))
    parser.add_argument("--csv", dest="csv_path", default="data/iocs.csv")
    parser.add_argument("--event-id", type=int)
    parser.add_argument("--create-event", action="store_true")
    parser.add_argument("--event-info", default="SIEM lab IOC import")
    args = parser.parse_args()

    if not args.api_key:
        print("MISP API key is required via --api-key or MISP_API_KEY.", file=sys.stderr)
        return 2

    rows = load_rows(Path(args.csv_path))
    event_id = args.event_id

    if args.create_event:
        event = request_json(
            f"{args.base_url}/events/add",
            args.api_key,
            build_event_payload(args.event_info, distribution=0, threat_level_id=2, analysis=1),
            method="POST",
        )
        event_id = int(event.get("Event", {}).get("id") or event.get("response", {}).get("Event", {}).get("id"))

    if not event_id:
        print("Provide --event-id or use --create-event.", file=sys.stderr)
        return 2

    imported = 0
    for row in rows:
        attribute = {
            "Attribute": {
                "type": row["type"],
                "category": row.get("category", "Network activity"),
                "value": row["value"],
                "to_ids": row.get("to_ids", "true").lower() == "true",
                "comment": row.get("comment", ""),
                "distribution": int(row.get("distribution", "3")),
            }
        }
        request_json(f"{args.base_url}/attributes/add/{event_id}", args.api_key, attribute, method="POST")
        imported += 1

    print(f"Imported {imported} attributes into event {event_id}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
