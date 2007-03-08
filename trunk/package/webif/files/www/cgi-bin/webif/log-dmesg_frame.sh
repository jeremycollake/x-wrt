#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

mini_header
echo -n "<body><div class=\"logread\"><pre>"
dmesg -s$((2**14)) | sed ' s/\&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' ?></pre>
</div>
</body>
</html>
