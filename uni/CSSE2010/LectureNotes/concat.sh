#!/bin/bash

echo "" > concat_notes.md
echo "" > botch
for i in {1..25}
do
	cat "Lec${i}.md" >> concat_notes.md
done	

pandoc -o CSSE2010_Lecture_Notes.tex concat_notes.md -H botch
pdflatex CSSE2010_Lecture_Notes.tex

rm concat_notes.md
