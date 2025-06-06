;; --------------------------------------------------------------------------------------------------------------------------------------
;; 	The script extracts XY coordinates of points from lines and polylines and saves them to a .txt file in the current drawing's directory.
;;
;;  The output file format is preliminarily prepared for upload to Polish geodetic offices. For WebEWID, keep only 3 columns:
;;  [no] [coord_x] [coord_y], e.g.:
;;	1 5587252.76 6528306.52
;;  2 5587253.20 6528306.48
;;  The rest are nice extras – useful if a clerk demands a .txt file with coordinates and the project is large :)
;;
;;  Additionally, for cost estimate purposes, the script creates a separate file with the lengths of all processed lines, sorted by layers.
;;  If you're working with layers — kudos to you.
;;	The script should work correctly in most CAD programs supporting AutoLISP. If something's off — report an issue on GitHub:
;;
;; [EXCEL] Output files are Excel-friendly — just copy the data from Notepad
;;         and paste it into a spreadsheet. Process, sort, recalculate — whatever you like.
;;
;; How to use:
;; 1. Drag the .lsp file into your CAD program or load it using the APPLOAD command.
;; 2. Select lines/polylines and type: GENERATEXY, or use GENERATEXY-ALL
;;    to generate coordinates for all lines in the drawing.
;; 3. If by some miracle you found yourself here without getting the file from GitHub and this helped your work —
;;    buy me a coffee:
;;    https://www.buymeacoffee.com/michalkrawczuk
;;
;; ------------------------------------------------------------------------------------------------------------------------------
;; v1.0 - 2025
;; Author: Michał Krawczuk
(defun c:GENERATEXY (/ ss ent entdata enttype filename file i pt counter obj-counter 
                            pt1 pt2 total-objects current-time date-str time-str length-file length-filename
                            obj-length total-length year month day hour minute second
                            layer-name layer-list layer-objects layer-length current-layer
                            sorted-entities layer-counter)
  (setvar "CMDECHO" 0)
  
  (if (setq ss (ssget "_I"))
    (progn
      (princ (strcat "\nSelection detected: " (itoa (sslength ss)) " object(s)."))
    )
    (progn
      (princ "\nSelect lines and/or polylines (you can select multiple objects): ")
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
                           "_coordinates_" year "-" month "-" day "_" hour "-" minute "-" second ".txt")
            length-filename (strcat (getvar "DWGPREFIX") 
                                  (vl-string-subst "" ".dwg" (getvar "DWGNAME")) 
                                  "_lengths_" year "-" month "-" day "_" hour "-" minute "-" second ".txt")
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
      (write-line ";=== COORDINATES OF CHARACTERISTIC POINTS ===" file)
      (write-line (strcat ";File: " (getvar "DWGNAME")) file)
      (write-line (strcat ";Creation date: " date-str " " time-str) file)
      (write-line ";Coordinate system: [to be completed - 1992/2000]" file)
      (write-line (strcat ";Number of layers: " (itoa (length layer-list))) file)
      (write-line ";Format: Point_number X[m] Y[m] Object_type Layer" file)
      (write-line ";" file)
      (write-line "Point_number\tX\tY\tObject_type\tLayer" file)
      (write-line ";=== SUMMARY OF OBJECT LENGTHS BY LAYER ===" length-file)
      (write-line (strcat ";File: " (getvar "DWGNAME")) length-file)
      (write-line (strcat ";Creation date: " date-str " " time-str) length-file)
      (write-line ";Unit: meters [m]" length-file)
      (write-line (strcat ";Number of layers: " (itoa (length layer-list))) length-file)
      (write-line ";" length-file)
      (write-line "Object_number\tLayer\tType\tLength[m]\tNotes" length-file)
      (setq obj-counter 0)
      (foreach current-layer layer-list
        (setq layer-length 0.0
              layer-objects 0)
        (write-line (strcat ";=== LAYER: " current-layer " ===") file)
        (write-line (strcat ";--- LAYER: " current-layer " ---") length-file)
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
                                   "LINE" "\t" 
                                   (rtos obj-length 2 3) "\t" 
                                   "Straight line") length-file)
                 (setq layer-length (+ layer-length obj-length))
                 (write-line (strcat (itoa counter) "\t" 
                                   (rtos (car pt1) 2 3) "\t" 
                                   (rtos (cadr pt1) 2 3) "\t" 
                                   "LINE_START" "\t"
                                   current-layer) file)
                 (setq counter (1+ counter))
                 (write-line (strcat (itoa counter) "\t" 
                                   (rtos (car pt2) 2 3) "\t" 
                                   (rtos (cadr pt2) 2 3) "\t" 
                                   "LINE_END" "\t"
                                   current-layer) file)
                 (setq counter (1+ counter)))
                ((or (= enttype "LWPOLYLINE") (= enttype "POLYLINE"))
                 (setq closed-flag (if (= 1 (logand 1 (cdr (assoc 70 entdata)))) "CLOSED" "OPEN"))
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
                                   "POLYLINE" "\t" 
                                   (rtos obj-length 2 3) "\t" 
                                   (strcat "Polyline " closed-flag)) length-file)
                 (setq layer-length (+ layer-length obj-length))
                 (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vlax-curve-getEndParam (list ent))))
                   (progn
                     (setq i 0)
                     (repeat (fix (1+ (vlax-curve-getEndParam ent)))
                       (setq pt (vlax-curve-getPointAtParam ent (float i)))
                       (write-line (strcat (itoa counter) "\t" 
                                         (rtos (car pt) 2 3) "\t" 
                                         (rtos (cadr pt) 2 3) "\t" 
                                         (strcat "POLY_" closed-flag "_" (itoa (1+ i))) "\t"
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
                                         (strcat "POLY_" closed-flag "_" (itoa vertex-counter)) "\t"
                                         current-layer) file)
                       (setq counter (1+ counter)
                             vertex-counter (1+ vertex-counter))))))
                (t 
                 (write-line (strcat ";ERROR: Unsupported object type - " enttype " on layer " current-layer) file)
                 (write-line (strcat (itoa obj-counter) "\t" 
                                   current-layer "\t"
                                   enttype "\t" 
                                   "0.000" "\t" 
                                   "ERROR - unsupported type") length-file))))))
        (write-line (strcat ";Layer " current-layer ": " (itoa layer-objects) " object(s), total length: " (rtos layer-length 2 3) " m") length-file)
        (write-line ";" length-file)
        (setq total-length (+ total-length layer-length)))
      (write-line ";" file)
      (write-line (strcat ";Total number of points: " (itoa (1- counter))) file)
      (write-line ";End of file" file)
      (write-line ";=== FINAL SUMMARY ===" length-file)
      (write-line (strcat ";Total length of all layers: " (rtos total-length 2 3) " m") length-file)
      (write-line ";End of file" length-file)
      
      (close file)
      (close length-file)
      (princ (strcat "\n*** REPORT ***"
                   "\nDate and time: " date-str " " time-str
                   "\nNumber of layers: " (itoa (length layer-list))
                   "\nObjects processed: " (itoa total-objects)
                   "\nPoints generated: " (itoa (1- counter))
                   "\nTotal length: " (rtos total-length 2 3) " m"
                   "\n\nFILES:"
                   "\nCoordinates: " filename
                   "\nLengths: " length-filename
                   "\n\nWARNING: Fill in coordinate system info in the file!")))
    (princ "\nNo objects selected."))
  (princ))

(defun c:GENERATEXY-ALL (/ ss)
  (princ "\nSelecting all lines and polylines from the drawing...")
  (setq ss (ssget "X" '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  (if ss
    (progn
      (sssetfirst nil ss)
      (c:GENERATEXY))
    (princ "\nNo lines or polylines found in the drawing."))
  (princ))
