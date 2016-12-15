//#include "mongo/db/nim/nimcache/showstat.h"

#ifdef __cplusplus
extern "C" {
#endif

void startJesterP(void);
void incLockWTCounterP(void);
void incLockMMV1CounterP(void);
void incLockWTGlobalCounterP(void);
void incLockMMV1GlobalCounterP(void);
void incEnsureIndexCounterP(void);

#ifdef __cplusplus
}
#endif
