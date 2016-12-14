#include "mongo/db/nim/nimcache/showstat.h"

void startJesterP(void) {
    NimMain();
    startJester();
}

void incLockWTCounterP(void) {
    incLockWTCounter();
}

void incLockMMV1CounterP(void) {
    incLockMMV1Counter();
}
