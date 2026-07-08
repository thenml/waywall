import struct
import zlib
import binascii
import math
import json
import os
import sys
import re
import requests


def load_config():
	path = sys.argv[1] if len(sys.argv) > 1 else None

	if not path or not os.path.exists(path):
		if path: print(f"file {path} not found")
		return

	with open(path, "r") as f:
		return json.load(f)


def save_config(cfg, path="generated.json"):
	with open(path, "w") as f:
		json.dump(cfg, f, indent=2)


def get(cfg, key, cast=None, default=None):
	v = cfg["get"](key, default)
	if v is None:
		return default
	return cast(v) if cast else v


def prompt(label, cast=str):
	s = input(f"\n{label} > ")
	if s.strip().lower() == "":
		return
	return cast(s)


def chunk(t, d):
	c = binascii.crc32(t + d) & 0xFFFFFFFF
	return struct.pack(">I", len(d)) + t + d + struct.pack(">I", c)


def clamp(x, a=0.0, b=1.0):
	return a if x < a else b if x > b else x


def parse_color(s):
	s = s.strip().lstrip("#")
	if len(s) != 6:
		raise ValueError("Color must be in RRGGBB format.")
	return bytes.fromhex(s)


def make_border(w, h, border, rgb, out, left_right=True, topbottom=True):
	rows = bytearray()

	for y in range(h):
		rows.append(0)

		for x in range(w):
			if (topbottom and (y < border or y >= h - border)) or (left_right and (x < border or x >= w - border)):
				rows.extend(rgb + b"\xff")
			else:
				rows.extend(b"\x00\x00\x00\x00")

	ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)  # RGBA

	png = bytearray(b"\x89PNG\r\n\x1a\n")
	png += chunk(b"IHDR", ihdr)
	png += chunk(b"IDAT", zlib.compress(bytes(rows)))
	png += chunk(b"IEND", b"")

	with open(out, "wb") as f:
		f.write(png)


def make_circle(size, border, scale, rgb, out):
	c = size / 2

	r_outer = c * scale
	r_inner = (c - border) * scale
	if border < 0:
		r_outer -= -border / 2
		r_inner = -1

	rows = bytearray()

	for y in range(size):
		rows.append(0)

		dy = y + 0.5 - c

		for x in range(size):
			dx = x + 0.5 - c
			d = math.hypot(dx, dy)

			outer = 1.0 - clamp(d - r_outer + 0.5)
			inner = clamp(d - r_inner + 0.5)

			coverage = clamp(outer * inner)

			if coverage <= 0.0:
				rows.extend(b"\x00\x00\x00\x00")
			else:
				aa = int(255 * coverage)
				rows.extend(rgb + bytes([aa]))

	ihdr = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)

	png = bytearray(b"\x89PNG\r\n\x1a\n")
	png += chunk(b"IHDR", ihdr)
	png += chunk(b"IDAT", zlib.compress(bytes(rows)))
	png += chunk(b"IEND", b"")

	with open(out, "wb") as f:
		f.write(png)


def download(repo, file_pattern, download_dir):
    url = f"https://api.github.com/repos/{repo}/releases/latest"

    response = requests.get(url)
    response.raise_for_status()

    release = response.json()

    for asset in release["assets"]:
        if re.match(file_pattern, asset["name"]):
            file_name = asset["name"]
            output_path = os.path.join(download_dir, file_name)

            os.makedirs(download_dir, exist_ok=True)

            print(f"Downloading {file_name}...")
            with requests.get(asset["browser_download_url"], stream=True) as r:
                r.raise_for_status()

                with open(output_path, "wb") as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        f.write(chunk)

            print(f"Saved to {output_path}")
            return output_path

    raise FileNotFoundError(
        f"No release asset matching '{file_pattern}' found."
    )


def main():
	cfg = load_config()

	if not cfg:
		print("Type in your value and press enter to submit")
		print("Submitting an empty value uses the [default]\n")
		
		cfg = {}
		cfg["screen_width"] = prompt("Set your screen width\n[1920]", eval) or 1920
		cfg["screen_height"] = prompt("Set your screen height\n[1080]", eval) or 1080

		thin_w = max(340, int(cfg["screen_height"] * (340/1080)))
		wide_h = max(340, int(cfg["screen_width"] / (1920/340)))
		cfg["thin_w"] = prompt(f"Thin resolution width\n[recommended: {thin_w}]", eval) or thin_w
		cfg["thin_h"] = prompt(f"Thin resolution height (% relative to screen or absolute)\n[100%]") or "100%"
		cfg["wide_w"] = prompt(f"Wide resolution width (% relative to screen or absolute)\n[100%]") or "100%"
		cfg["wide_h"] = prompt(f"Wide resolution height\n[recommended: {wide_h}]", eval) or wide_h

		if cfg["thin_h"].endswith("%"):
			cfg["thin_h"] = int(cfg["screen_height"] * int(cfg["thin_h"][:-1]) / 100)
		else:
			cfg["thin_h"] = int(cfg["thin_h"])
		if cfg["wide_w"].endswith("%"):
			cfg["wide_w"] = int(cfg["screen_width"] * int(cfg["wide_w"][:-1]) / 100)
		else:
			cfg["wide_w"] = int(cfg["wide_w"])

		cfg["border"] = prompt("Border size\n[5]", eval) or 5

		cfg["overlay_w"] = prompt("Measuring overlay width in pixels / % width of the side\n[100%]") or "100%"
		cfg["overlay_h"] = prompt(f"Measuring overlay height\n[recommended: {thin_w + cfg['border'] * 2}]", eval) or (thin_w + cfg["border"] * 2)

		if cfg["overlay_w"].endswith("%"):
			cfg["overlay_w"] = int((cfg["screen_width"] - cfg["thin_w"]) / 2 * int(cfg["overlay_w"][:-1]) / 100)
		else:
			cfg["overlay_w"] = int(cfg["overlay_w"])

		cfg["color"] = prompt("Border color\n[#c292e2]") or "#c292e2"

		cfg["pie_d"] = prompt("Pie mirror width / diameter\n[200]", eval) or 200
		cfg["pie_bg"] = prompt("Pie mirror background\n[#000000]") or "#000000"
		
		tools_path = input("Put a path to save your tools in (Ninjabrain Bot, Paceman, etc)\n[~/.config/waywall/tools/] > ~/").strip() or ".config/waywall/tools/"
		if not tools_path.endswith("/"): tools_path = tools_path + "/"
		cfg["tools_path"] = f'os.getenv("HOME") .. "/{tools_path}"'

		cfg["images"] = (prompt("Generate images for these sizes?\n[Y]/n") or "y") == "y"
		cfg["autogen"] = (prompt("Modify options.lua with these changes?\n[Y]/n") or "y") == "y"

		if prompt("Download tools? y/[N]") == "y":
			tools_path = os.path.join(os.path.expanduser("~"), tools_path)
			if prompt("Download Ninjabrain Bot?\ny/[N]"): download("Ninjabrain1/Ninjabrain-Bot", r"^Ninjabrain-Bot-(\d+\.)+jar$", tools_path)
			if prompt("Download PaceMan Tracker?\ny/[N]"): download("PaceMan-MCSR/PaceMan-Tracker", r"^paceman-tracker-(\d+\.)+jar$", tools_path)
			if prompt("Download ModCheck?\ny/[N]"): download("tildejustin/modcheck", r"^modcheck-(\d+\.)+jar$", tools_path)
			print("\nmake sure the versions in options.lua match those downloaded!!!\n")

		save_config(cfg)
		print("\nconfig saved as generated.json")
		print("you can apply it again by calling [python3 setup.py generated.json]\n")

	color = parse_color(cfg["color"])
	pie_bg = parse_color(cfg["pie_bg"])

	if cfg["images"]:
		print("creating images")
		make_border(cfg["wide_w"] + cfg["border"] * 2, cfg["wide_h"] + cfg["border"] * 2, cfg["border"], color, "images/x_border.png", cfg["wide_w"] != cfg["screen_width"], True)
		make_border(cfg["thin_w"] + cfg["border"] * 2, cfg["thin_h"] + cfg["border"] * 2, cfg["border"], color, "images/y_border.png", True, cfg["thin_h"] != cfg["screen_height"])
		make_border(cfg["thin_w"] + cfg["border"] * 2, cfg["screen_height"], cfg["border"], color, "images/tall_border.png", True, False)
		make_border(cfg["overlay_w"], cfg["overlay_h"], cfg["border"], color, "images/overlay_border.png", cfg["overlay_w"] != int((cfg["screen_width"] - cfg["thin_w"]) / 2), True)
		make_circle(cfg["pie_d"], -cfg["border"], 0.95, pie_bg, "images/pie.png")
		make_circle(cfg["pie_d"], cfg["border"], 0.95, color, "images/pie_border.png")

	if cfg["autogen"]:
		print("modifying options.lua")

		with open("options.lua", "r", encoding="utf-8") as f:
			text = f.read()
		with open("options.lua.bak", "w", encoding="utf-8") as f:
			f.write(text)

		for name, value in cfg.items():
			if name not in ["tools_path", "screen_width", "screen_height", "thin_w", "thin_h", "wide_w", "wide_h", "overlay_w", "overlay_h", "pie_d", "border"]:
				continue

			pat = rf"(^local\s+{re.escape(name)}\s*=\s*).*$"
			text, count = re.subn(pat, rf"\g<1>{value}", text, flags=re.MULTILINE)

			if count == 0:
				print(f"replacement failed for {name}")

		with open("options.lua", "w", encoding="utf-8") as f:
			f.write(text)
	
	print("done!")


if __name__ == "__main__":
	main()