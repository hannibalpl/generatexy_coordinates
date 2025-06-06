# GENERATEXY.lsp
🇬🇧 [English version](README.md)

# GENERATEXY.lsp

**AutoLISP — skrypt do wyciągania współrzędnych XY z rysunków CAD**

Ten skrypt pozwala automatycznie wyciągnąć współrzędne XY z linii i polilinii znajdujących się w rysunku, i zapisuje je do pliku `.txt` w tym samym katalogu, w którym znajduje się rysunek. Format wyjściowy jest zgodny (lub bliski) wymaganiom polskich urzędów geodezyjnych — np. systemu **WebEWID**.

---

## ✨ Co robi skrypt?

- Eksportuje współrzędne XY z **zaznaczonych** linii i polilinii,
- Tworzy plik `.txt` gotowy do wczytania do geodezyjnych systemów typu WebEWID (np. kolumny: nr, X, Y),
- Tworzy **drugi plik** z długościami wszystkich przetworzonych linii, **posortowanymi według warstw** — przydatne np. do kosztorysów,
- Pliki wynikowe są **przyjazne dla Excela** — kopiuj z Notatnika, wklejaj do arkusza, sortuj i przeliczaj.

---

## 📄 Przykład formatu (dla WebEWID):


1 5587252.76 6528306.52
2 5587253.20 6528306.48


Usuń kolumny dodatkowe, jeśli są — sedno to tylko numeracja i współrzędne. Reszta to ozdoba (dla Pań w urzędach, które "potrzebują pliku .txt").

---

## 🧭 Jak używać?

1. **Załaduj skrypt**  
   Przeciągnij plik `.lsp` do programu CAD lub użyj polecenia `APPLOAD`.

2. **Uruchom polecenie**  
   - `GENERATEXY` — eksportuje dane ze wskazanych linii i polilinii,
   - `GENERATEXY-ALL` — eksportuje dane ze **wszystkich linii** w rysunku.

3. **Sprawdź pliki**  
   Pliki `.txt` pojawią się w tym samym folderze, w którym zapisany jest rysunek.

---

## ☕ Działa? Oszczędziło Ci roboty?

Możesz postawić mi wirtualną kawę – będzie mi bardzo miło :)

👉 [Buy me a coffee](https://www.buymeacoffee.com/michalkrawczuk)

---

## 📜 Licencja

Projekt udostępniony na licencji **GNU General Public License v3.0**.  
Możesz swobodnie korzystać, modyfikować i udostępniać ten kod, ale **każda pochodna wersja również musi pozostać otwarta i objęta tą samą licencją**.

Zobacz plik [LICENSE](LICENSE), aby poznać pełne warunki.

---

## 🛠️ Autor

**Michał Krawczuk**  
Gdańsk, 2025
