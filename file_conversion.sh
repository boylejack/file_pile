#!/bin/bash
for i in *.tex; do lualatex $i; done
rm *.aux
rm *.log
rm *.tex
soffice --headless --convert-to docx:"MS Word 2007 XML" *.txt
rm *.txt
for f in *.text; do
  mv -- "$f" "${f%.text}.txt"
done
