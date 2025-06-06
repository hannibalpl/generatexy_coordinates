;; --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; 	Skrypt wyciąga współrzędne XY punktów z linii oraz polilinii i zapisuje je do pliku .txt w katalogu bieżącego rysunku.
;;
;;  Forma pliku wyjściowego została wstępnie przygotowana pod upload do polskich urzędów geodezyjnych. Dla WebEWID zostaw tylko 3 kolumny:
;;  [nr] [wsp_x] [wsp_y], np.: 
;;	1 5587252.76 6528306.52
;;  2 5587253.20 6528306.48
;;  Reszta to miłe dodatki - przydatne jeżeli Pani z urzędu żąda od Ciebie pliku .txt ze współrzędnymi a projekt jest duży :)
;;
;;  Dodatkowo, na potrzeby kosztorysów, skrypt tworzy osobny plik z długościami wszystkich przetworzonych linii, posortowanymi według warstw.
;;  Jeśli pracujesz na warstwach — chwała Ci.
;;	Skrypt powinien działać poprawnie w większości programów CAD obsługujących AutoLISP. Jeżeli coś nie gra - napisz problem na githubie:
;;	https://github.com/hannibalpl/generatexy_coordinates/issues
;; [EXCEL] Pliki wyjściowe są przyjazne dla Excela — wystarczy skopiować dane z notatnika i wkleić do arkusza. Obrabiaj, sortuj, przeliczaj — co dusza zapragnie.
;;
;; Jak używać:
;; 	1. 	Przeciągnij plik .lsp do programu CAD lub załaduj go poleceniem APPLOAD.
;; 	2. 	Zaznacz linie/polilinie i wpisz: GENERATEXY, lub użyj GENERATEXY-ALL, aby wygenerować współrzędne dla wszystkich linii w rysunku.
;; 	3. 	Jeżeli jakimś cudem lurknąłeś do skryptu a nie widziałeś readme.md z githuba, ułatwiłem Ci żmudną robotę i chciałbyś mi postawić za to kawę: 
;;   	https://www.buymeacoffee.com/michalkrawczuk - z góry dzięki!
;;
;; --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;; v1.0 - 2025
;; Autor: Michał Krawczuk

(defun c:GENERATEXY (/ ss ent entdata enttype filename file i pt counter obj-counter 
                            pt1 pt2 total-objects current-time date-str time-str length-file length-filename
                            obj-length total-length year month day hour minute second
                            layer-name layer-list layer-objects layer-length current-layer
                            sorted-entities layer-counter)
  (setvar "CMDECHO" 0)
  
  (if (setq ss (ssget "_I"))
    (progn
      (princ (strcat "\nWykryto zaznaczenie: " (itoa (sslength ss)) " obiekt(ów)."))
    )
    (progn
      (princ "\nWybierz linie i/lub polilinie (możesz wybrać wiele obiektów): ")
      (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
    )
  )
  
  (if ss
    (progn
      (setq current-time (getvar "CDATE"))
      (setq current-time (rtos (getvar "CDATE") 2 6)
            year (substr current-time 1 4)
            month (substr current-time 5 2)  
            day (substr current-time 7 2)
            hour (substr current-time 10 2)
            minute (substr current-time 12 2)
            second (substr current-time 14 2))
      (setq date-str (strcat year "-" month "-" day)
            time-str (strcat hour ":" minute ":" second)
            filename (strcat (getvar "DWGPREFIX") 
                           (vl-string-subst "" ".dwg" (getvar "DWGNAME")) 
                           "_wspolrzedne_" year "-" month "-" day "_" hour "-" minute "-" second ".txt")
            length-filename (strcat (getvar "DWGPREFIX") 
                                  (vl-string-subst "" ".dwg" (getvar "DWGNAME")) 
                                  "_dlugosci_" year "-" month "-" day "_" hour "-" minute "-" second ".txt")
            file (open filename "w")
            length-file (open length-filename "w")
            counter 1
            total-objects (sslength ss)
            total-length 0.0
            layer-list '()
            sorted-entities '())
      (setq obj-counter 0)
      (repeat total-objects
        (setq ent (ssname ss obj-counter)
              entdata (entget ent)
              layer-name (cdr (assoc 8 entdata)))
        (if (not (member layer-name layer-list))
          (setq layer-list (append layer-list (list layer-name))))
        (setq sorted-entities (append sorted-entities (list (list ent layer-name))))
        (setq obj-counter (1+ obj-counter)))
      (setq layer-list (vl-sort layer-list '<))
      (write-line ";=== WSPÓŁRZĘDNE PUNKTÓW CHARAKTERYSTYCZNYCH ===" file)
      (write-line (strcat ";Plik: " (getvar "DWGNAME")) file)
      (write-line (strcat ";Data utworzenia: " date-str " " time-str) file)
      (write-line ";Układ współrzędnych: [do uzupełnienia - 1992/2000]" file)
      (write-line (strcat ";Liczba warstw: " (itoa (length layer-list))) file)
      (write-line ";Format: Nr_punktu X[m] Y[m] Typ_obiektu Warstwa" file)
      (write-line ";" file)
      (write-line "Nr_punktu\tX\tY\tTyp_obiektu\tWarstwa" file)
      (write-line ";=== ZESTAWIENIE DŁUGOŚCI OBIEKTÓW WG WARSTW ===" length-file)
      (write-line (strcat ";Plik: " (getvar "DWGNAME")) length-file)
      (write-line (strcat ";Data utworzenia: " date-str " " time-str) length-file)
      (write-line ";Jednostka: metry [m]" length-file)
      (write-line (strcat ";Liczba warstw: " (itoa (length layer-list))) length-file)
      (write-line ";" length-file)
      (write-line "Nr_obiektu\tWarstwa\tTyp\tDlugosc[m]\tUwagi" length-file)
      (setq obj-counter 0)
      (foreach current-layer layer-list
        (setq layer-length 0.0
              layer-objects 0)
        (write-line (strcat ";=== WARSTWA: " current-layer " ===") file)
        (write-line (strcat ";--- WARSTWA: " current-layer " ---") length-file)
        (foreach entity-info sorted-entities
          (if (= (cadr entity-info) current-layer)
            (progn
              (setq ent (car entity-info)
                    entdata (entget ent)
                    enttype (cdr (assoc 0 entdata))
                    obj-counter (1+ obj-counter)
                    layer-objects (1+ layer-objects))
              
              (cond
                ((= enttype "LINE")
                 (setq pt1 (cdr (assoc 10 entdata))
                       pt2 (cdr (assoc 11 entdata))
                       obj-length (distance pt1 pt2))
                 (write-line (strcat (itoa obj-counter) "\t" 
                                   current-layer "\t"
                                   "LINIA" "\t" 
                                   (rtos obj-length 2 3) "\t" 
                                   "Linia prosta") length-file)
                 (setq layer-length (+ layer-length obj-length))
                 (write-line (strcat (itoa counter) "\t" 
                                   (rtos (car pt1) 2 3) "\t" 
                                   (rtos (cadr pt1) 2 3) "\t" 
                                   "LINIA_POCZ" "\t"
                                   current-layer) file)
                 (setq counter (1+ counter))
                 (write-line (strcat (itoa counter) "\t" 
                                   (rtos (car pt2) 2 3) "\t" 
                                   (rtos (cadr pt2) 2 3) "\t" 
                                   "LINIA_KON" "\t"
                                   current-layer) file)
                 (setq counter (1+ counter)))
                ((or (= enttype "LWPOLYLINE") (= enttype "POLYLINE"))
                 (setq closed-flag (if (= 1 (logand 1 (cdr (assoc 70 entdata)))) "ZAMKN" "OTWAR"))
                 (setq obj-length 0.0)
                 (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vlax-curve-getEndParam (list ent))))
                   (setq obj-length (vlax-curve-getDistAtParam ent (vlax-curve-getEndParam ent)))
                   (progn
                     (setq vertex-list '()
                           dxf-data entdata)
                     (while dxf-data
                       (if (= 10 (car (car dxf-data)))
                         (setq vertex-list (append vertex-list (list (cdr (car dxf-data))))))
                       (setq dxf-data (cdr dxf-data)))
                     (if (> (length vertex-list) 1)
                       (progn
                         (setq i 0)
                         (repeat (1- (length vertex-list))
                           (setq obj-length (+ obj-length 
                                             (distance (nth i vertex-list) (nth (1+ i) vertex-list))))
                           (setq i (1+ i)))))))
                 (write-line (strcat (itoa obj-counter) "\t" 
                                   current-layer "\t"
                                   "POLILINIA" "\t" 
                                   (rtos obj-length 2 3) "\t" 
                                   (strcat "Polilinia " closed-flag)) length-file)
                 (setq layer-length (+ layer-length obj-length))
                 (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vlax-curve-getEndParam (list ent))))
                   (progn
                     (setq i 0)
                     (repeat (fix (1+ (vlax-curve-getEndParam ent)))
                       (setq pt (vlax-curve-getPointAtParam ent (float i)))
                       (write-line (strcat (itoa counter) "\t" 
                                         (rtos (car pt) 2 3) "\t" 
                                         (rtos (cadr pt) 2 3) "\t" 
                                         (strcat "POLI_" closed-flag "_" (itoa (1+ i))) "\t"
                                         current-layer) file)
                       (setq counter (1+ counter)
                             i (1+ i))))
                   (progn
                     (setq vertex-list '()
                           dxf-data entdata
                           vertex-counter 1)
                     (while dxf-data
                       (if (= 10 (car (car dxf-data)))
                         (setq vertex-list (append vertex-list (list (cdr (car dxf-data))))))
                       (setq dxf-data (cdr dxf-data)))
                     (foreach vertex vertex-list
                       (write-line (strcat (itoa counter) "\t" 
                                         (rtos (car vertex) 2 3) "\t" 
                                         (rtos (cadr vertex) 2 3) "\t" 
                                         (strcat "POLI_" closed-flag "_" (itoa vertex-counter)) "\t"
                                         current-layer) file)
                       (setq counter (1+ counter)
                             vertex-counter (1+ vertex-counter))))))
                (t 
                 (write-line (strcat ";BŁĄD: Nieobsługiwany typ obiektu - " enttype " na warstwie " current-layer) file)
                 (write-line (strcat (itoa obj-counter) "\t" 
                                   current-layer "\t"
                                   enttype "\t" 
                                   "0.000" "\t" 
                                   "BŁĄD - nieobsługiwany typ") length-file))))))
        (write-line (strcat ";Warstwa " current-layer ": " (itoa layer-objects) " obiekt(ów), długość: " (rtos layer-length 2 3) " m") length-file)
        (write-line ";" length-file)
        (setq total-length (+ total-length layer-length)))
      (write-line ";" file)
      (write-line (strcat ";Łączna liczba punktów: " (itoa (1- counter))) file)
      (write-line ";Koniec pliku" file)
      (write-line ";=== PODSUMOWANIE KOŃCOWE ===" length-file)
      (write-line (strcat ";Łączna długość wszystkich warstw: " (rtos total-length 2 3) " m") length-file)
      (write-line ";Koniec pliku" length-file)
      
      (close file)
      (close length-file)
      (princ (strcat "\n*** RAPORT ***"
                   "\nData i czas: " date-str " " time-str
                   "\nLiczba warstw: " (itoa (length layer-list))
                   "\nPrzetworzono obiektów: " (itoa total-objects)
                   "\nWygenerowano punktów: " (itoa (1- counter))
                   "\nŁączna długość: " (rtos total-length 2 3) " m"
                   "\n\nPLIKI:"
                   "\nWspółrzędne: " filename
                   "\nDługości: " length-filename
                   "\n\nUWAGA: Uzupełnij informację o układzie współrzędnych w pliku!")))
    (princ "\nNie wybrano żadnych obiektów."))
  (princ))

(defun c:GENERATEXY-ALL (/ ss)
  (princ "\nWybieranie wszystkich linii i polilinii z rysunku...")
  (setq ss (ssget "X" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if ss
    (progn
      (sssetfirst nil ss)
      (c:GENERATEXY))
    (princ "\nNie znaleziono żadnych linii ani polilinii w rysunku."))
  (princ))
