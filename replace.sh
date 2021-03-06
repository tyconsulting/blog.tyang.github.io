#!/bin/bash
filename=$1

echo "replacing <strong> with **"
sed -i "s/<strong>/**/" $filename

echo "replacing </strong> with **"
sed -i "s/<\/strong>/**/" $filename

echo "replacing <b> with **"
sed -i "s/<b>/**/" $filename

echo "replacing </b> with **"
sed -i "s/<\/b>/**/" $filename

echo "removing <om>"
sed -i "s/<om>//" $filename

echo "removing </om>"
sed -i "s/<\/om>//" $filename

echo "removing <em>"
sed -i "s/<em>//" $filename

echo "removing </em>"
sed -i "s/<\/em>//" $filename

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

echo "removing &nbsp;"
sed -i "s/&nbsp;//" $filename

echo "replacing <blockquote> with >"
sed -i "s/<blockquote>/>/" $filename

echo "removing </blockquote>"
sed -i "s/<\/blockquote>//" $filename

echo "removing <p>"
sed -i "s/<p>//" $filename

echo "removing </p>"
sed -i "s/<\/p>//" $filename

echo "done"