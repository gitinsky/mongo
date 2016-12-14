import jester, asyncdispatch, htmlgen, prometheus, os

const
  bucketMargins = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 140.0, 150.0, 160.0, 170.0, 180.0, 190.0, 200.0, 210.0, 220.0, 230.0, 240.0, 250.0, 260.0, 270.0, 280.0, 290.0, 300.0, 310.0, 320.0, 330.0, 340.0, 350.0, 360.0, 370.0, 380.0, 390.0, 400.0, 410.0, 420.0, 430.0, 440.0, 450.0, 460.0, 470.0, 480.0, 490.0, 500.0, 510.0, 520.0, 530.0, 540.0, 550.0, 560.0, 570.0, 580.0, 590.0, 600.0, 610.0, 620.0, 630.0, 640.0, 650.0, 660.0, 670.0, 680.0, 690.0, 700.0, 710.0, 720.0, 730.0, 740.0, 750.0, 760.0, 770.0, 780.0, 790.0, 800.0, 810.0, 820.0, 830.0, 840.0, 850.0, 860.0, 870.0, 880.0, 890.0, 900.0, 910.0, 920.0, 930.0, 940.0, 950.0, 960.0, 970.0, 980.0, 990.0, 1000.0, 1100.0, 1200.0, 1300.0, 1400.0, 1500.0, 1600.0, 1700.0, 1800.0, 1900.0, 2000.0, 2250.0, 2500.0, 2750.0, 3000.0, 4000.0, 5000.0, 6000.0, 7000.0, 8000.0, 9000.0, 10000.0, 12000.0, 14000.0, 16000.0, 18000.0, 20000.0, 25000.0, 30000.0, 35000.0, 40000.0, 50000.0, 60000.0, 70000.0, 90000.0, 120000.0, 180000.0, 240000.0]

var
  statRequestChan: Channel[int]
  locksWTChan: Channel[int]
  locksMMV1Chan: Channel[int]
  locksWTGlobalChan: Channel[int]
  locksMMV1GlobalChan: Channel[int]
  promChan: Channel[Prometheus]

proc incLockWTCounter() {.exportc.} =
  send(locksWTChan, 1)

proc incLockMMV1Counter() {.exportc.} =
  send(locksMMV1Chan, 1)

proc incLockWTGlobalCounter() {.exportc.} =
  send(locksWTGlobalChan, 1)

proc incLockMMV1GlobalCounter() {.exportc.} =
  send(locksMMV1GlobalChan, 1)

proc statsProc() {.thread.} =
  let prom = newPrometheus()
  var localCounter = prom.newCounter("mongo_nim_http_reqs_counter", "Number of HTTP requests.")
  var locksWTCounter = prom.newCounter("mongo_nim_locks_wt_counter", "Number of locks in WT.")
  var locksMMV1Counter = prom.newCounter("mongo_nim_locks_mmv1_counter", "Number of locks in MMAPV1.")
  var locksWTGlobalCounter = prom.newCounter("mongo_nim_global_locks_wt_counter", "Number of global locks in WT.")
  var locksMMV1GlobalCounter = prom.newCounter("mongo_nim_global_locks_mmv1_counter", "Number of global locks in MMAPV1.")
  var latencyHistogram = prom.newHistogram("mongo_nim_http_reqs_latency", "Latency of HTTP requests in millis.", bucketMargins)
  var result: bool
  var latency: float
  while true:
    let (result1, _) = tryRecv(locksWTChan)
    if result1:
      locksWTCounter.increment()
    let (result3, _) = tryRecv(locksMMV1Chan)
    if result3:
      locksMMV1Counter.increment()
    let (result4, _) = tryRecv(locksWTGlobalChan)
    if result4:
      locksWTGlobalCounter.increment()
    let (result5, _) = tryRecv(locksMMV1GlobalChan)
    if result5:
      locksMMV1GlobalCounter.increment()
    let (result2, _) = tryRecv(statRequestChan)
    if result2:
      send(promChan, prom)
    sleep(20)

proc startJester() {.exportc.} =
  var statsThread: Thread[void]
  open(statRequestChan)
  open(promChan)
  open(locksWTChan)
  open(locksMMV1Chan)
  open(locksWTGlobalChan)
  open(locksMMV1GlobalChan)
  createThread(statsThread, statsProc)

  routes:
    get "/metrics":
      send(statRequestChan, 1)
      let prom = recv(promChan)
      resp prom.exportAllMetrics(), "text/plain; charset=utf-8"
    get "/":
      echo("Test")
      resp h1("Test") & "<BR/>"

  runForever()
