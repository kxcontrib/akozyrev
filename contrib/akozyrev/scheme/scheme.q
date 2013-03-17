/ lexer
w0:@[128#3;w;:;til count w:`int$("\t \r";"\n";";";"'def";.Q.a,.Q.A,"!$%&*/:<=>?^_~";.Q.n),"ft@,#+-.\"(\\"];

wm:("a A a0ft+-."; "A A a0ft+-.";"f A a0ft@+-.";"t A a0ft@+-."; / identifiers
    "; C *"; "; \n \n"; "C C *"; "C \n \n"; / comments
    "0 F 0";"0 I .";". I 0";"- I .";"- F 0";"F F 0";"F I .";"I I 0"; / number -[0-9].[0-9], F - float, I - int
    "\" S *";"\" Z \"";"\" Y \\";"S S *";"S Z \"";"S Y \\";"Y S *"; / string "aaa\"aaa"
    ", Z @"; / ,@ - Z-end of token state
    "# Z (tf";"# T \\";"T Z *"); / #( #t #f #\C

w1:{.[;;:;]/[(c;c:count s)#s?s;m[;0],'enlist each 4_'m;(m:s?ssr[;"*";s:(`char$first each w),distinct m where (m:raze wm) in .Q.A] each wm)[;2]]}[];

w:{(i _x)@ where 2<s i:where (count distinct w0)>s:w1\[0;w0 x]};

/ w ". , ,@ @ 1 10.1 -1 -23.1 .1212 -.122 ( ) ' \\ # #\\$ #t #f \"aaaa\" \"\" \"aaa\\\"aa\\baa\" \"\\\"\""
/ w " a + 1 ;aaaaaa\na + 1; 1aa  aa"
/ w "aab aabt afrt ?--- <=> a0?_."

/ token to value
v:{$[x~(),".";".";x~",@";x;(t:first x) in "()',";t;(1=count x)&t="-";`$t;t in ".-",.Q.n;value x;t="\"";enlist x where 1b|':not "\\"=x:-1_1_ x;t="#";$["t"=t:x[1];1b;t="f";0b;t="(";"(";t="\\";last x;x];`$x]};

/ s) . , ,@ @ 1 10.1 -1 -23.1 .1212 -.122 ( ) ' \\ #( # #\\$ #t #f "aaaa" "" "aaa\"aa\baa" "\""
/ s) a + 1 ;aaaaaa
/   a + 1; 1aa  aa
/ s) aab aabt afrt ?--- <=> a0?_.

/ parser: paren atom list toplevel
pp:{[l] r:$["("~first l; pl[1_ l]; '"List is expected"]; $[not ")"~first r 1;'"Parens don't match";(r 0;1_ r 1)]};
pa:{[l] $["("~t:first l; pp[l]; ")"~t; :0b; "'"~t; $[0b~r:pa[1_ l];(`quote;1_ l);((`quote;r 0);r 1)];count l;(t;1_ l); :0b]};
pl:{[l] {[v] $[0b~r:pa v 1;v;(v[0],enlist r 0;r 1)]}/[(();l)]};
tl:{[l] $[0<count last r:pl[l];'"Parens don't match";r 0]};

/ s) (define a (+ 2 10))
/    (show (m (1 2) '(op 10)))
/   (define m (a b)
/     ((1 1 1)
/      #(1 1 1)
/      "aaaaa"))

/ evaluator
/ define global context
dType:$[.z.K>=3f;7;6];
ectx:``.p!(::;-1); ctxs:(`u#-2 0)!(::;ectx);  cctx:0; ctxId:0;
newCtx:{[pid] ctxs[i:ctxId+::1]:ectx; ctxs[i;`.p]:pid; i};
resolve:{[n] $[0<=c:{ctxs[x;`.p]}/[{$[y=-1;0b;not x in key ctxs y]}[n];cctx];ctxs[c;n];'string[n]," is undefined"]};

flambdac:{[e]
  if[not pLst[3] e; '"Invalid lambda"];
  : $[-11=type a:e 1; (`.lam;();a;cctx;2_ e);  / (lam a e)
    pOr[(pLst[(),0];pAnd[(pLst[1];11=type@)])] a; (`.lam;a;();cctx;2_ e); / (lam () e) or (lam (a ...) e)
    pAnd[(pLst[3];1=sum -11<>type each;pEl["."~;-2])] a; (`.lam;-2_ a;last a;cctx;2_ e); / (lam (a . b) e)
    '"Invalid lambda"];
 };
fdefinec:{[e]
  if[not pLst[3] e; '"Invalid define"];
  if[-11=type a:e[1]; : $[3=count e;(a;e 2);'"Invalid define"]]; / (define a exp)
  if[not pAnd[(pLst[1];pEl[-11=type@;0])] a; '"Invalid define"]; / (define (a ?) e)
  l:flambdac $[1=c:count a; (`l;()); / (define (a) e) -> (lam () e)
               (c=3)&("."~a 1)&11=type a 0 2; (`l;a[2]); / (define (a . b) e) -> (lam b e)
               (`l;1_ a)],2_ e; / general case
  : (a 0;l);
 };
fcondc:{[cont;e] / (cond (t e) ... (else e))
  if[not pAnd[(pLst[1];all pLst[2] each)] e:1_ e; '"Invalid cond"];
  if[not `else~first last e; e:e,enlist (`else;())];
  : (`.c;(`.cc;cont;1_ e 0;1_ e);e[0;0]);
 };
fsetc:{[n;v;c]
  if[neg[dType]<>type c;'"Invalid set! ctx"];
  if[not c in key ctxs;'"set!: invalid ctx"];
  {[n;e;c] if[-1=c;'"set!: name not found"]; $[n in key ctxs[c];ctxs[c;n]:e;c:ctxs[c;`.p]];c}[n;v]/[c];
 };
tailRec:{[cont]
  : $[`.bodyc~c:first cont; $[0=count cont 2;tailRec[cont 1];cont]; / .body can be dropped if the rest is ()
     `.letendc~c;[cctx::cont 2; : tailRec cont 1]; / letendc can be dropped
    cont];
 };
appc:{[cont;e] / call function
  cont:tailRec[cont]; / simplify continuation via tail recursion
  if[99<type f:first e; : cont,enlist f@1_ e]; / internal fn
  if[`.lam~first f; o:cctx; : fbodyc[(`.letendc;cont;o);fn . (1_ f),enlist 1_ e]]; / scheme fn, letendc is similar to fn end cont
  if[`.apply~f; $[pLst[(),3]; :appc[cont;(enlist e 1),e 2]]];
  if[`.callcc~f; $[pLst[(),2] e; :appc[cont;(e 1;(`.cont;cont;cctx))]; '"call/cc: bad arg"]]; / capture continuation
  if[`.cont~first f; cctx::f 2; : (f 1),enlist e 1]; / call continuation
  '"Non functon is called"; 
 };
fn:{[a;opt;cid;e;v]
  oldc:cctx; cctx::newCtx[cid]; / set fn contex
  $[count[a,opt]=count v:$[opt~();v;sublist[n;v],enlist (n:count a)_ (),v];ctxs[cctx;a,opt]:v;'"Invalid number of args"];
  if[100h<=type e; r:e[]; cctx::oldc; :r];
  : e;
 };

/ evaluation funcs: program(top level), definitions, expression, body
evPc:{[e] cctx::0; last evEDc each  (),e};  / program(top level)
evEDc:{[e] $[0>type e;evExc e;`define~first e;evExc `.def,fdefinec e;evExc e]}; / define or expression on global level
evExc:{[e] last {evCont x}/[{not `.ret~first x};(`.c;`.ret;e)]};
evCont:{[e]  / CPS style eval
  / 0N!(`evcont;e); /  0;$[pLst[2] e;$[pLst[0] e 1;e[1;0];e];e];{$[104=type x;"<fn>";0<=type x;$[`.lam~first x;4#x;.z.s each x];x]} 2_ e);
  : $[not pLst[0] e; : e; / values
      `.c~e 0; evExp e;
      `.lc~e 0; [v: e[2],enlist e 4;$[0=count e 3;appc[e 1;v];(`.c;(`.lc;e 1;v;1_ e 3);first e 3)]]; / (.lc cont acc rest val)
      `.ifc~e 0; (`.c;e 1),enlist $[e 4;e 2;e 3];
      `.cc~e 0; `.c,$[e 4;((`.bodyc;e 1;1_ e 2);first e 2);$[1=count e 3;((`.bodyc;e 1;1_ ce);first ce:1_ e[3;0]);((`.cc;e 1;1_ e[3;0];1_ e 3);e[3;0;0])]]; / (`.cc cont exp cond val)
      `.defc~e 0;[ctxs[cctx;e 2]:e 3; e[1], enlist (::)]; /  (`.defc;cont;name;val)
      evCont2[e]
    ]; 
 };
evCont2:{[e]
 : $[`.letc~e 0; letCont e;
     `.letendc~e 0; [cctx::e 2; e[1],enlist e 3]; / (.letend;cont;oldctx;val)
     `.bodyc~e 0; $[count e 2;(`.c;(`.bodyc;e 1;1_ e 2);first e 2);e[1],enlist e 3]; / (.bodyc;cont;exps;val)
     `.setc~e 0; (`.c;`.setc2,e 1 2 4;e 3); / (.setc;cont;name;ctx;exp)
     `.setc2~e 0; e[1],enlist fsetc . e 2 3 4; / (.setc2;cont;name;exp;ctx)
     e
    ]; 
 };
evExp:{[e]
  cont:e 1;e: e 2;
  $[-11=t:type e; : cont,enlist resolve[e]; / var name
    (0>t)or(t>99)or(t=10)or(0=count e); : cont,enlist e;  / atom, function, empty list, string
    (1=c:count e)&10h=type e 0; : cont,enlist e 0; / string    
    `if~e 0; $[pLst[3 4] e; :(`.c;(`.ifc;cont;e 2;$[3=count e;();e 3]);e 1);'"Bad if expression"];
    `cond~e 0; :fcondc[cont;e];
    `.lam~e 0; :cont,enlist e;
    `.def~e 0; :(`.c;(`.defc;cont;e 1);e 2); 
    (`$"set!")~e 0; $[pAnd[(pLst[3 4];pEl[-11=type@;1])] e;:(`.c;(`.setc;cont;e 1;$[3=c;cctx;e 2]);last e);'"Invalid set!"];
    any e[0]~/:`let`letrec`letdef,`$"let*"; : evLetc[cont;e]];
  if[`begin~e 0; :(`.bodyc;cont;1_ e;(::))];
  :(`.c;cont),enlist $[`quote~e 0; :cont,enlist e 1;
    `lambda~e 0; flambdac e;
    `and~e 0; $[c=1;1b; (`if;e 1;`and,2_ e;0b)];
    `or~e 0; $[c=1;0b; (`if;e 1;1b;`or,2_ e)];
    0=count e; ();
    :(`.c;(`.lc;cont;();1_ e);e 0)];
 };
evLetc:{[cont;e]  / (let ((n1 v1) .. (nk vk)) e1 .. en
  if[not pAnd[(pLst[3];pEl[pLst[1];1])] e; '"Invalid let"];
  if[not all pAnd[(pLst[(),2];pEl[-11=type@;0])]each b:e 1; '"Invalid let"];
  if[e[0]=`letrec;cctx::newCtx[cctx]];
  if[e[0] in `letrec`letdef; ctxs[cctx;b[;0]]::`.undef]; / bind letrec stubs
  :(`.c;(`.letc;(`.letendc;cont;cctx);e 0;();b;2_ e);b[0;1]);
 };
letCont:{[e] / (`.let;cont;type;evBinds;binds;body;value)
  if[(`$"let*")~e 2; cctx::newCtx[cctx]; ctxs[cctx;e[4;0;0]]::e 6]; / let*: bind 1 by 1
  b:(e 3),enlist (e[4;0;0];e 6); / new bind
  if[(1=count e 4)&(e 2)in `let`letrec`letdef; if[`let~e 2;cctx::newCtx[cctx]]; ctxs[cctx;b[;0]]::b[;1]]; / final bind for let&letrec
  : $[1=count e 4;fbodyc[e 1;e 5];(`.c;(`.letc;e 1;e 2;b;1_ e 4;e 5);e[4;1;1])]; / eval the next bind or continue with body
 };
fbodyc:{[cont;e]
  if[0>type e; :(`.c;cont;e)]; / not list
  d:`define~/:first each e;
  if[0=sum d; :(`.c;(`.bodyc;cont;1_ e);first e)]; / no defines
  if[11<>type s:first each (e where d)[;1];'"Invalid internal define"];
  :(`.c;cont;`letdef,(enlist fdefinec each e where d),e where not d); / transform to letrec
 };

/ define default fns
setg:{[f;a;o;e] ctxs[0;f]:fn[a;o;0;e]};
setg[`$"+";();`a;{sum resolve `a}];
setg[`$"*";();`a;{prd resolve `a}];
setg[`$"/";();`a;{r:({$[dType=type x,y;$[0=x mod y;x div y;x%y];x%y]})/[resolve `a]}];
setg[`$"-";();`a;{$[1=count a:resolve[`a];neg a 0;(-)/[a]]}];
{setg[`$x;`a`b;`c;{y;all 1_ x[prev v;v:raze resolve each `a`b`c]}[value x]]} each ("=";"<";">";"<=";">=");
{setg[`$x;`a;();{y;x@resolve `a}[value x]]} each ("not";"exp";"log";"abs";"sin";"cos";"sqrt";"atan");
setg[`remainder;`a`b;();{$[dType=type v:resolve each `a`b;.[mod;v];'"remainder: bad arg"]}];
setg[`newline;();();{1 "\n"}];
setg[`display;`a;();{1 $[10=abs type v:resolve `a;v;.Q.s1 v];}];
setg[`runtime;();();{.z.T}];
setg[`error;();`a;{'.Q.s1 resolve `a}];
setg[`:list;();`a;{resolve `a}];
setg[`$"equal?";`a`b;();{(~). resolve each `a`b}];
setg[`$"eq?";`a`b;();{$[0>max type each v:resolve each `a`b;(~). v;(all `.lam~/:first each v)&all pLst[1] each v;(~). v;0b]}];
setg[`:car;`a;();{if[pLst[1] v:resolve `a;: first v]; '"car: wrong type/empty list"}];
setg[`:cdr;`a;();{if[pLst[1] v:resolve `a;: 1_ v];'"cdr: wrong type/empty list"}];
setg[`:cons;`a`b;();{(enlist resolve `a),resolve `b}];
setg[`$"null?";`a;();{pLst[(),0] resolve `a}];
setg[`:length;`a;();{$[pLst[0] v:resolve `a;count v;'"length: not a list"]}];
setg[`$":pair?";`a;();{pLst[1] resolve `a}];
setg[`$"list-ref";`a`b;();{$[pLst[1+i:resolve `b] v:resolve `a;v i;'"list-ref: bad arg"]}];
setg[`$":type";`a;();{$[.z.K>=3f;`long$;`int$]$[0=t:type v:resolve `a;$[`.lam~first v;$[`:pair~v 2;201;200];t];t]}];
setg[`$":resolve-ctx";`a`b;();{if[not (neg[dType]=type a:resolve`a)&-11=type b:resolve `b;'"resolve-ctx: bad arg"]; cctx::a; resolve b}];
setg[`$":get-ctx";`a;();{$[`.lam~first a:resolve `a;a 3;ctxs[cctx;`.p]]}];
ctxs[0;`$"call/cc"]:`$".callcc";
ctxs[0;`$"apply"]:`$".apply";



/ pattern check
pAnd:{[p;v] not count {1_ x}/[{$[count y;y[0] x;0b]}[v];p]};  / and pattern
pOr:{[p;v] 0<count {1_ x}/[{$[count y;0b=y[0] x;0b]}[v];p]};  / or pattern
pEl:{[p;n;v] p v n+$[n>0;0;count v]}; / apply pattern to element N
pLst:{[c;v] $[0>type c;c<=count v;(count v) in c]&(type v) within (0;19)}; / list pattern

/ garbage collector
gcChkEx:{[x]
  if[not (type x) within 0 19; :()];
  r:$[any (first x)~/:`.cont`.letendc;x 2;()];
  : r,$[`.lam~first x; x 3; raze gcChkEx each x];
 };
gc:{
  gcMap::(-2 0)!2#1b; tS:.z.T;
  {if[not count x;: ()]; v:v where not gcMap v:gcChkEx value ctxs[first x]; gcMap[v]:1b; 1_ x,v}/[0];
  0N!("GC has deleted:";count[ctxs]-count gcMap;" objects, time:";.z.T-tS);
  ctxs::{(`u#key x)!value x} (where gcMap)#ctxs;
 };

.s.e:{evPc tl v each w x};

system "l scheme.s";

-1 "Scheme interpreter is ready. Load files with \\l file.s";


