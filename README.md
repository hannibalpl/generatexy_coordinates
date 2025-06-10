[Zobacz polskie readme](README.PL.md)

[PL] & [EN]! 

2 language versions! Polish (native) and english (if you need).

**AutoLISP script for extracting XY coordinates from CAD drawings in Autocad/ZWCad/etc. programs**

This script extracts XY coordinates from lines and polylines in your current drawing and saves them to a `.txt` file in the same folder as the DWG. It’s designed to simplify geodetic work and generate coordinate tables ready for Polish government systems such as **WebEWID**.

Additionally, from the selected lines in the same command it creates a second file containing the lengths of these lines and their summary - sorted by layers. Useful for cost estimates.

---

## ✨ Features

- Extracts XY coordinates from selected **lines** and **polylines**
- Saves data to a `.txt` file formatted for upload to **WebEWID**
- Generates a separate report file with **line lengths**, sorted by layer – ideal for cost estimations
- Output is **Excel-friendly**: open the file in Notepad, copy, and paste into Excel for further processing
- Should work in most CAD programs supporting **AutoLISP** (AutoCAD, ZWCAD, BricsCAD, etc.)

---

## 📦 Example WebEWID-ready output:


1 5587252.76 6528306.52
2 5587253.20 6528306.48

Just remove extra columns if needed — the script gives you both raw and enriched output for flexibility.

---

## 🚀 How to use

1. **Load the script**  
   Drag the `.lsp` file into your CAD program or use the `APPLOAD` command.

2. **Run the command**  
   - Use `GENERATEXY` to export coordinates from selected lines/polylines  
   - Use `GENERATEXY-ALL` to export coordinates from **all lines** in the drawing

3. **Check the folder**  
   The generated `.txt` files will appear in the folder of your current drawing.

---

## ☕ Like it?

If this script made your work easier, saved you from Excel hell, or just saved your deadline — consider supporting me:

👉 [Buy me a coffee](https://www.buymeacoffee.com/michalkrawczuk)

---

## 📜 License

This project is licensed under the terms of the **GNU General Public License v3.0**.  
You are free to use, modify, and share this code, as long as any derived works remain **open and licensed the same way**.

See [LICENSE](LICENSE) for full terms.

---

## 🛠️ Author

**Michał Krawczuk**  
Gdańsk, 2025  
