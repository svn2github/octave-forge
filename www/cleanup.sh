for f in $*; do \
  d=`dirname $f`; \
  if [ -d $d ]; then \
    if [ "$d" != "." ]; then \
      rm -rf $d; \
    fi; \
  fi; \
done
