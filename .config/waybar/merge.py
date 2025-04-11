#!/usr/bin/env python

import argparse
import json

def merge(file1: str, file2: str):
  try:
    with open(file1, "r") as file:
      json1 = json.load(file)

    with open(file2, "r") as file:
      json2 = json.load(file)
  except Exception as error:
    exit(f"\x1b[31;1merror:\x1b[0m {error}")

  if not isinstance(json1, dict) or not isinstance(json2, dict):
    exit(f"\x1b[31;1merror:\x1b[0m Cannot merge non-objects.")

  merged = json1.copy()
  merged.update(json2)
  return merged

def main():
  parser = argparse.ArgumentParser(
    description="Merge two JSON files."
  )

  parser.add_argument(
    "file1",
    help="Path to the first JSON file."
  )

  parser.add_argument(
    "file2",
    help="Path to the second JSON file.",
  )

  parser.add_argument(
    "-o", "--output",
    help="Path to the output JSON file."
  )

  args = parser.parse_args()
  merged = merge(args.file1, args.file2)
  merged_str = json.dumps(merged, indent=2)

  if args.output:
    try:
      with open(args.output, "w") as file:
        file.write(merged_str)
    except Exception as error:
      exit(f"\x1b[31;1merror:\x1b[0m: {error}")
  else:
    print(merged_str)

if __name__ == "__main__":
  main()
