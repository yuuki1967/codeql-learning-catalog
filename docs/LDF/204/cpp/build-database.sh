#!/bin/bash
SRCDIR=$(pwd)/src/session-db
DB=$SRCDIR/cpp-runtime-values-db
codeql database create --language=cpp -s "$SRCDIR" -j 8 -v $DB --command="clang -fsyntax-only -Wno-unused-value $SRCDIR/db.c"
