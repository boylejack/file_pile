#!/bin/bash
for i in *.tex; do lualatex $i; done
rm *.aux
rm *.log
rm *.tex
for j in *.txt; do soffice --headless --convert-to docx:"MS Word 2007 XML" $j; done
rm *.txt
for f in *.text; do
  mv -- "$f" "${f%.text}.txt"
done
