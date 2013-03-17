This is a simple Scheme interpreter in Q.

It is capable of executing most of SICP examples and supports almost all
important scheme features like tail recursion, mutable lists and continuations.

To start it enter the dir with scheme.s and scheme.q and type

q scheme.q

After the interpreter is started you can load and execute the scheme code via

\l schemeFile.s

or

s) (define some_var (+ 10 20))


For example to run the famous call/cc example you should do this:

\l yinyan.s

s) (yystart)


Press ^C to stop the example.

Mutable lists and continuations can't be handled by Q means only, they require
their own garbage collector so you should call

gc[]

from time to time to clear out old closures and etc.

All lists by default are Q lists and they are immutable. To create a mutable
list mcons should be used. Cons acts as mcons if the first arg is a mutable
list.