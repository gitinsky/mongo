import jester, asyncdispatch, htmlgen

proc startJester() {.exportc.} =
  routes:
    get "/":
      echo("Test")
      resp h1("Test") & "<BR/>"

  runForever()
