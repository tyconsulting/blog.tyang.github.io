#!/bin/bash
filename=$1

echo "replacing <strong> with **"
sed -i "s/<strong>/**/" $filename

echo "replacing </strong> with **"
sed -i "s/<\/strong>/**/" $filename

echo "removing <om>"
sed -i "s/<om>//" $filename

echo "removing </om>"
sed -i "s/<\/om>//" $filename

echo "removing <ul>"
sed -i "s/<ul>//" $filename

echo "removing </ul>"
sed -i "s/<\/ul>//" $filename

echo "replacing <li> with '* '"
sed -i "s/	<li>/* /" $filename
sed -i "s/<li>/* /" $filename

echo "removing </li>"
sed -i "s/<\/li>//" $filename

echo "removing <ol>"
sed -i "s/<ol>//" $filename

echo "removing </ol>"
sed -i "s/<\/ol>//" $filename

echo "replacing &lt; with <"
sed -i "s/&lt;/</" $filename

echo "replacing &gt; with <"
sed -i "s/&gt;/>/" $filename

echo "done"