#!/bin/bash

ls -a ../*.png |
grep -v '_light.png' |
grep -v 'blank_' |
while read file
do
	ln -s "$file" './'
done
