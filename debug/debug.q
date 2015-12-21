.d.adv:(`byte$0x1a+til 6)!`$("'";"/";"\\";"':";"/:";"\\:");
.d.unary:(`byte$0x21+til 31)!`flip`neg`first`reciprocal`where`reverse`null`group`hopen`hclose`string`enlist`count`floor`not`key`distinct`type`value`read0`read1`read2`avg`last`sum`prd`min`max`exit`getenv`abs;
.d.binary:(`byte$0x41+til 31)!(`$string "+-*%&|^=<>$,#_~!?@."),`0:`1:`2:`in`within`like`bin`ss`insert`wsum`wavg`div;

.d.st:5000#enlist (::);
.d.sti:0;
.d.push:{.d.st[.d.sti]:x; .d.sti+:1};
.d.pushf:{.d.push  x . y; `c};
.d.pop:{.d.sti-:1; .d.st[.d.sti]};
.d.popn:{.d.sti-:x; .d.st[.d.sti+reverse til x]};
.d.peak:{.d.st[.d.sti-1]};

.d.rmapn:0;
.d.lpush:{[n;s].d.push .d.pops[],"\000",string[.d.rmapn],"\000",(.d.lev#" "),(.d.pops[],s);.d.rmapn:n};
.d.str:{$[10h=type x;x;x 1]};
.d.pops:{.d.str .d.pop[]};
.d.popns:{.d.str each .d.popn x};
.d.lev:0;
.d.pushbin:{[f;l;r] p:$[any (f:.d.str[f])~/:string ",$+!-#&|~=<> ";"";" "]; .d.push $[10h=type l;"(",l,")",f,p,.d.str[r];.d.str[l],p,f,p,.d.str[r]]};
.d.rev:(`byte$til 256)!256#{[a;c]'"rev error"};
.d.rev[key .d.unary]:{[a;c] .d.push string[.d.unary c]," ",.d.pops[]};
.d.rev[key .d.binary]:{[a;c] o:string[.d.binary c]; l:.d.pop[]; r:.d.pops[]; .d.pushbin[o;l;r]};
.d.rev[key .d.adv]:{[a;c] a:string .d.adv c; .d.push $[10h=type v:.d.pop[];"(",v,")",a;(`ad;.d.str[v],a)]};
.d.rev[0x0b0c0d0e0f1011]:{[a;c] .d.push ((til 7)!((`c;"()");(`c;(),"0");(`c;(),"1");(`c;(),",");(`c;(),"`");"::";"")) c-11};
.d.rev[`byte$0x60+til 23]:{[a;c] .d.push (`a;string a[`l;0x76-c])};
.d.rev[`byte$0x78+til 8]:{[a;c] .d.push (`a;string a[`a;c-0x78])};
.d.rev[`byte$0x80+til 31]:{[a;c] .d.push (`a;string a[`g;c-0x80])};
.d.rev[`byte$0xa0+til 96]:{[a;c] .d.push $[(t:type v:a[`c;c-0xa0]) in -5 -6 -7 10 -10 11 -11 -4 4h;(`a;.Q.s1 v);any v~/:(?;!;.;@);(`a;.Q.s1 v);t>99h;$[`~r:first where v~/: value `.q;(`a;.Q.s1 v);(`a;$[r~`inv;"key";r~`mmu;(),"$";string r])];.Q.s1 v]};
.d.rev[0x00]:{[a;c] .d.push ": ",.d.pops[]};
.d.rev[0x77]:{[a;c] .d.push (`a;".z.s")};
.d.rev[0x01]:{[a;c] .d.push "'",.d.pops[]};
.d.rev[0x52]:{[a;c] f:.d.pop[]; v:.d.pops[];.d.push $[10h=type f;"(",f,")",v;`ad~f 0;f[1],"[",v,"]";first[f 1] in "@$?_";(`a;v,f 1);$[v~"::";(`a;.d.str[f],"[]");.d.str[f]," ",v]];};
.d.rev03:{[a;c] .d.rev[c][a;c:`byte$c+0x60]; .d.push raze reverse (.d.pops[];": ";.d.pops[])};
.d.rev04:{[a;c;f] .d.rev[c][a;c]; v:.d.popns[3]; .d.push v[0],$[v[1]~"()";"";"[",$[v[1] like "enlist*";7_ v[1];-1_1_ v[1]],"]"],$[f=0x00;": ";string[.d.binary[`byte$0x40+f]],": "],v[2]};
.d.rev0a:{[a;c]
  v:.d.str each vo:.d.popn[1+c];
  if[v[0]~"enlist";: .d.push (`li;"(",(";" sv 1_ v),")")];
  if[(not any (1_ v)~\:"")&((`$v[0]) in `inter`except`xasc`xdesc`each`vs`sv`set`xkey`lj`ij`uj,`$("sv/:";"vs/:"))&c=2; : .d.pushbin . vo];
  if[(v[0]~"lsq")&c>2;v[0]:"!"];
  if[v[0]~(),"'"; [vo[0]:()," "; : .d.pushbin . vo]];
  .d.push (`f;$[10h=type vo 0;"(",v[0],")";v 0],"[",(";" sv 1_ v),"]");
 };
.d.block:{[a;c;t;n;nold] / if: xx 02 10; while: 09 xx 10; $: other
  nmax:d+n+2+c n+1+d:t=0x07;
  bt:$[t=0x07;"do";
       0x0210~c nmax-2 1;"if";
       0x0910~c nmax-3 1;"while";
       $[(.d.lev=0)|nold>nmax:nmax+c nmax:n+c n+1;"$";[.d.lpush[n+2;";"];:n+2]]];
  .d.push bt,"[",ssr[.d.pops[];"\000  ";{x,"  "}],";";
  r:.d.rmapn; .d.rmapn:n:n+2+d;
  .d.lev+:2;
  .d.rmain[a;c;nmax]/[n]; / exp;..;exp
  .d.lpush[nmax;"]"]; .d.push (`a;.d.pop[]);
  .d.rmapn:r;
  .d.lev-:2;
  : nmax;
 };
.d.rev[0x0920]:{[a;c] };
.d.rmain:{[a;c;nmax;n]
  if[n>=nmax;: n];
  $[0x03=t:c n; .d.rev03[a;c n+1];
    0x04=t; .d.rev04[a;c n+1;c n+2];
    t in 0x0205; .d.lpush[n+1+t=0x05;";"];
    t in 0x0607; : .d.block[a;c;t;n;nmax];
    0x0a=t; .d.rev0a[a;c n+1];
    / (0x11=t)&0x02=c n+1; n:n+1; beware $[0;1;] !!!
    .d.rev[t][a;t]
   ];
  : n+1+(t in 0x0304050607090a)+(t in 0x0407);
 };
.d.rfn:{[f]
  sti:.d.sti; .d.rmapn:.d.lev:0; .d.sti:4000; .d.push "";
  v:value f; .d.rmain[`a`l`g`c!(v 1;v 2;v 3;-1_4_ v);v 0;-1+count v 0]/[0];
  r: ("I"$first l)!last l:flip (0N 2)#1_"\000" vs .d.pops[],"\000",string[.d.rmapn],"\000",.d.pops[];
  .d.sti:sti; :r;
 };

.d.u:(`byte$0x21+til 31)!(flip;neg;first;reciprocal;where;reverse;null;group;hopen;hclose;string;enlist;count;floor;not;key;distinct;type;value;read0;read1;::;avg;last;sum;prd;min;max;exit;getenv;abs);
.d.b:(`byte$0x41+til 31)!(+;-;*;%;&;|;^;=;<;>;$;,;#;_;~;!;?;@;.;0:;1:;2:;in;within;like;bin;ss;insert;wsum;wavg;div);

.d.cmap:(`byte$til 256)!256#{[x] '"error: not impl"};
.d.cmap[key .d.u]:{[c] @[.d.pushf .d.u c;enlist .d.pop[];{.d.excp["Unary ",string[.d.unary x]," has failed with arg ",(.Q.s1 .d.st .d.sti),"): ";y]}[c]]};
.d.cmap[key .d.b]:{[c] @[.d.pushf .d.b c;reverse (.d.pop[];.d.pop[]);{.d.excp["Binary ",string[.d.binary x]," has failed with args (",(.Q.s1 .d.st .d.sti),";",(.Q.s1 .d.st .d.sti+1),"): ";y]}[c]]};
.d.cmap[0x0b0c0d0e0f1011]:{[c] .d.push (();0;1;,;`;::;`:dbg:11) c-11; `c};
.d.cmap[0x20]:{`c};
.d.cmap[0x1a1c1d1f]:{[c] .d.push ((';0;\;':;0;\:) c-0x1a) .d.pop[]; `c};
.d.cmap[0x1b]:{[c] .d.push (.d.pop[]/); `c};
.d.cmap[0x1e]:{[c] .d.push (.d.pop[]/:); `c};
.d.cmap[0x77]:{[c] .d.push .d.a`.f; `c};

.d.return:{[c]
  if[.d.sti=1; :`s];
  v:.d.pop[]; .d.sti:.d.stprev; s:.d.pop[];
  / if[`:dbg:excblock~s 0; s:.d.pop[]];
  .d.c:s 1;.d.n:s 2;.d.a: s 3; .d.stprev: s 4; / restore the frame
  .d.bpsf:.d.bps .d.a`.f; / reget bps
  .d.push v;
  : `c;
 };
.d.cmap[0x00]:.d.return;
.d.cmap[0x02]:{.d.pop[]; `c}; / drop the top value
.d.cmap[0x01]:{$[not (type r:.d.pop[]) in 10 -11h; .d.excp["Wrong exception type: ";"stype"];.d.excp["User exception: ";$[-11=type r;string r;r]]]};

.d.cmap[0x03]:{.d.n+:1; v:$[0x17<c:.d.c .d.n;.d.a[`.a;c-0x18];.d.a[`.l;0x16-c]]; .d.a[v]:.d.peak[]; `c}; / val 03 var
.d.cmap[0x04]:{
   i:.d.pop[]; v:.d.pop[]; .d.n+:1;
   if[0x79<c:.d.c .d.n; l:g:.d.a[`.g;c-0x80]];
   if[0x80>c;
     l:$[0x77<c;.d.a[`.a;c-0x78];.d.a[`.l;0x76-c]];
     `.d.gvar set .d.a[l]; g:`.d.gvar;
   ];
   .d.n+:1;
   f:$[0x00=c:.d.c .d.n;(:);.d.b `byte$0x40+c];
   : .[{[f;g;i;v;l].[g;i;f;v]; .d.push $[0x00=.d.c .d.n+1;::;$[i~();get g;.[{(get x). y};(g;i);::]]]; if[g~`.d.gvar; .d.a[l]:.d.gvar]; `c};(f;g;i;v;l);{.d.excp["Assignment to ",string[x]," failed: ";y]}[l]];
 }; / v i 04 a f

/ block structures
.d.cmap[0x06]:{.d.n+:1; @[{if[.d.pop[];:()]; .d.n+:-1+`int$.d.c .d.n;};();{.d.excp["wrong if condition: ";x]}]; `c};
.d.cmap[0x05]:{.d.n+:`int$.d.c .d.n+1; `c};
.d.cmap[0x07]:{@[{do[x;.d.n+:2;:.d.push -1+x];.d.n+:1+.d.c .d.n+2};.d.pop[];{.d.excp["Wrong do: ";x]}]; `c};
.d.cmap[0x09]:{.d.n-:.d.c .d.n+1; `c};
.d.cmap[0x08]:{.d.n-:1; .d.cmap[0x07][x]};

.d.resolve:{[n] $[n in key .d.a;(`v;.d.a n);@[{(`v;@[value;x;{$[x like ":*";x;'y]}[x]])};$[(.d.a[`.ns]~`)or n like ".*";n;` sv `,.d.a[`.ns],n];{[x;y](`e;"Undefined global ",string[x],": ";y)}[n]]]};
.d.cmap[`byte$0x60+til 23]:{[c] .d.push .d.a .d.a[`.l;0x76-c]; `c};
.d.cmap[`byte$0x78+til 8]:{[c] .d.push .d.a .d.a[`.a;c-0x78]; `c};
.d.cmap[`byte$0x80+til 32]:{[c] if[`v=first v:.d.resolve .d.a[`.g;c-0x80]; .d.push last v; :`c]; .d.excp . 1_ v};
.d.cmap[`byte$0xa0+til 96]:{[c] .d.push .d.a[`.c;c-0xa0]; `c};

/ parted funcs
/ expected min number of args
.d.nargs:{[f] $[100h=t:type f;count value[f]1; t=101h;1;t in 107 108h;$[2=n:.d.nargs[value f];1;n]; t in 102 103 109 110 111h;2; 104h=t;.d.nargsp[value f]; 105h=t;.d.nargs[last value f]; 106h=t;.d.nargs[value f];'"not impl"]};
/ \d .q
/ if[not `empargs in key `.q; `empargs set {[p] where 104h={type (1;x)} each p}]; / prevent interpretation
/ \d .
.d.empargs:{i:x~\:(::);i[w]:not null x w:where i; where i};
.d.nargsp:{[p] (max 0,1+.d.nargs[p 0]-count p)+count .d.empargs p};
.d.partify:{(value ("{[x;y]x[",";" sv {$[null x;"";"y ",string x]} each ?[y~\:`:dbg:11;0N;til count y]),"]}")[x;y]};
.d.margs:{[pa;a] i:.d.empargs pa; if[count i; pa[i]:(count i)#a]; : 1_ ((::),pa),count[i]_ a};
.d.pexec:{[f;a] a:.d.margs[1_ v:value f;a]; $[104h=type v 0;.d.pexec[v 0;a];.d.apply[v 0;a]]};
.d.apppart:{[f;a] $[0=.d.nargsp f,a;.d.pexec[f;a];.d.push f . a]; `c};
.d.app3:{[f;a]
  if[f~('); : $[count[a] in 1 2;[.d.push ('). a;`c];.d.excp["Each both/func composition error: ";"rank"]]];
  '"Not impl";
 };
.d.appfn:{[f;a] / @ and . with 3 or 4 args
  if[(3=c:count a)&99h<type first a; / exc block
    .d.apply[{x[y;z]};f,-1_ a]; / never fails
    .d.push (`:dbg:excblock;last a);
    : `c;
  ];
  if[(c=2)&99h<type first a; : .d.apply[first a;$[19=value f;a 1;1_ a]]];
  if[c>4; .d.excp["Wrong number of args: ";"rank"]];
  .[.d.pushf;(f;a);{.d.excp["Apply failed: ";x]}];
  : `c;
 };
/ adverbs
.d.each:{[f;a]
  if[98h=type a; : (cols a)!.d.each[f;value each a]]; / assign will not work on a table
  if[any t:99h=te:type each a;a[w]:a[w]@\:k:distinct raze key each a w:where t; : k!.d.each[f;a]]; / remove dicts
  if[not any (te within 0 19h)or te=98h; : f . a]; / only atoms
  a:flip a; i:0; r:(count a)#(::);
  do[count a;r[i]:f . a i; i+:1];
  : r;
 };
.d.eachr:{[f;a;s]
  if[2<>count a; '"rank"];
  if[99h=t:type a s;k:key a s; a[s]:value a s; : k!.d.eachr[f;a;s]]; / remove dicts
  if[not (t within 0 19h)or t=98h; : f . a]; / only atoms
  i:0; r:(count a s)#(::);
  do[count a s;r[i]:$[s;f[a 0;a[1;i]];f[a[0;i];a 1]]; i+:1];
  : r;
 };
.d.eachp:{[f;a]
  if[2<count a; '"rank"];
  if[99h=t:type l:last a;:(key l)!.d.eachp[f;$[1=count a;enlist value l;(a 0;value l)]]];
  if[1=count a;
    if[not (t within 0 19h)or t=98h; : l];
    if[1=.d.nargs f; : .d.each[f;enlist l]]; / weird
  ];
  a:enlist[$[1=count a;l -1;a 0]],l; / normalize
  i:1; r:(count l)#(::);
  do[count l;r[i]: f[a i;a i-1]; i+:1];
  : r;
 };
/ 1: f/[a] ; f/[n;a] ; f/[g;a]
/ 2: f/[a]
/ 2 or more f/[number of params]
.d.over:{[f;a;s]
  n:.d.nargs f; c:count a; r:();
  if[(c=1)&n=1; af:al:a 0; fl:1b;  while[fl; r:s[r] al; fl:not any (al:f al)~/:(al;af)]; :r];
  if[(c=2)&n=1; r:s[r] al:a 1; $[(t:type a 0)in -6 -7h; do[a 0;r:s[r] al:f al]; while[a[0] al;r:s[r] al:f al]]; :r];
  if[(n=1)or c>n; '"rank"];
  if[(n>2)&c<n; :$[s~{x;y};(f/). a;(f\). a]]; / parted
  if[any w:99h=t:type each a1:(c:c<>1)_ a;if[1<count k:distinct key each a1 w:where w;'"domain"];$[98h=type a;a:value each a;a[c+w]:value each a1 w]; :$[s~{x;y};s[1];![k 0]] .d.over[f;a;s]];
  if[not c; if[1=count a:a 0; :s[r] first a]; if[2=count a; : s[first a] f . a]; r:1#a; a:(first a;1_ a)];
  if[not any (t within 0 19h)or t=98h; : f . a];
  al: first a; a:flip 1 _ a; i:0;
  do[count a; r:s[r] al:f[al]. a i; i+:1];
  : r;
 };
.d.appadv:{[f;a]
  ft:$[104h=t:type v:value f;`u;t<100h;`i;v in(.;@);`u;100h=t;$[(first (value v)3)in`q`h;`i`u f~(peach);`u];t in 101 102 103 112h;`i;`u]; / f type
  if[ft=`i; : .[.d.pushf;(f;a);{.d.excp["Q function failed: ";x]}]]; / do not interpret internal fns
  if[.d.nargs[f]>count a; : .[.d.pushf;(f;a);{.d.excp["Adv unexpected fail: ";x]}]];
  if[106h=t:type f; : .d.apply[.d.each;(v;a)]];
  if[t in 107 108h; : .d.apply[.d.over;(v;a;({x;y};{x,enlist y})t-107h)]];
  if[109h=t; : .d.apply[.d.eachp;(v;a)]];
  if[t in 110 111h; : .d.apply[.d.eachr;(v;a;1-t-110h)]];
  '"not impl";
 };
.d.sel:{[f;a]
  sf:value ("{[",(";" sv string .d.a`.a),"]",";" sv (s,\:":"),'".d.a`",/:s:string .d.a`.l),"; ",string[f],"[",(";" sv ".d.a[`.sel]",/:string til count a),"]}"; / artif env
  .d.a[`.sel]:a;
  .d.push sf . .d.a .d.a`.a;
  : `c;
 };
.d.na:0b; / native execution
.d.apply:{[f;a]
  if[-11h=t:type f; if[`e=first f:.d.resolve f; :.d.excp . 1_ f]; t:type f:last f];
  if[any a~\:`:dbg:11; .d.push .d.partify[f;a]; :`c]; / missing args
  if[(100h>t)or 112h=t; : .[.d.pushf;(f;a);{.d.excp["Function failed: ";x]}]];
  v:value f;
  if[105h=t; if[(count a)<.d.nargs f;.d.push f . a; :`c]; : .d.apply[{x y . z};(v 0;v 1;a)]];
  if[104h=t; : .d.apppart[f;a]];
  if[103h=t; : .d.app3[f;a]];
  if[t in 106 107 108 109 110 111h; :.d.appadv[f;a]];
  if[f~(each); if[1=count a; .d.push (a[0]'); :`c]; :.d.appadv[(a[0]');1_ a]];
  if[any v~/:18 19; :.d.appfn[f;a]];
  if[(any v~/:16 17)&2<count a; :.d.sel[f;a]];
  ce:$[101h=t;1;102h=t;2;count v 1]; / expected args
  if[ce>c:count a;.d.push f . a; :`c]; / not enough args
  if[t in 101 102h; : $[enlist~f;[.d.push a;`c];.[.d.pushf;(f;a);{.d.excp["Q function failed: ";x]}]]]; / skip some fns
  if[.d.na or(first v 3) in `q`h; : .[.d.pushf;(f;a);{.d.excp["Q function failed: ";x]}]];
  if[c>ce; : .d.excp["Wrong number of arguments: ";"rank"]];
  .d.push (`:dbg:fncall;.d.c;.d.n;.d.a;.d.stprev); / save the old frame
  .d.c:v 0;.d.n:-1;.d.pc:0x00; .d.bpsf:.d.bps f; .d.stprev:.d.sti;
  .d.a:n!(count n:v[1],v[2])#enlist (); .d.a[`.ns`.c`.a`.l`.g`.f`.id]:(first v 3;-1_4_ v;v 1;v 2;v 3;f;.z.P); / args/local vars + namespace,const,arg,loc,glob
  .d.a[v 1]:a; / assign vars
  : `c;
 };
.d.cmap[0x0a]:{[c] f:.d.pop[]; .d.n+:1; .d.apply[f;.d.popn[`int$.d.c .d.n]]}; / an .. a1 f A0 LEN
.d.cmap[0x52]:{[c] f:.d.pop[]; a:.d.pop[]; $[(-11h=type f)or 99h<type f;.d.apply[f;enlist a];.d.apply[@;(f;a)]]}; / a f 52
.d.cmap[0x53]:{[c] f:.d.pop[]; a:.d.pop[]; $[(-11h=type f)or 99h<type f;.d.apply[f;a];.d.apply[.;(f;a)]]};

.d.e:10000;
.d.excp:{[p;m]
  if[.d.e;
    .d.e-:1;
    if[not null n:last where `:dbg:excblock~/:first each .d.st til .d.sti;
      .d.sti:n+2; v:last .d.st n;
      .d.return[0x00];
      .d.pop[];
      $[99h<type v;.d.apply[{x[y]};(v;m)];.d.push v];
      : `c;
    ]
  ];
  'p,m;
 };

/ breakpoints
.d.bps:enlist[::]!enlist `int$();
.d.bpsf:`int$();
.d.bres:{[f;b] (key .d.rfn f) b};
.d.ba:{[f;b] if[f~`;f:.d.a`.f]; .d.bps[f]:distinct .d.bps[f],.d.bres[f;b];}; / add bp
.d.bd:{[f;b] .d.bps[f]:.d.bps[f] except (),.d.bres[f;b];}; / remove bp
.d.bs:{[f;b] .d.bps[f]:(),.d.bres[f;b];}; / set bp
.d.bc:{[] .d.bps:enlist[::]!enlist `int$();}; / clear all bp

.d.a:(`symbol$())!();
.d.oa:{.d.O,:$[10h=type x;enlist x;x]};
.d.out:{$[.z.w=0;$[x~(::);-1 each .d.O;:x];:$[x~(::);"\n" sv .d.O;x]];};
.d.state:`s;
.d.pstack:{[n] .d.oa "Top of the stack: "; .d.oa (".d.st[",/:string[neg[n] sublist til .d.sti],\:"]: "),'{$[0<>type x;.Q.s1 x;`:dbg:fncall~first x;"Fn call, line: ",.d.pline2[x 3;x 2];.Q.s1 x]} each neg[n] sublist .d.sti#.d.st;};
.d.psn:{[n] .d.O:(); .d.pstack[n]; .d.out[::]};
.d.ps:{[].d.psn[10]};

.d.pline2:{[d;n] string[w],": ",l key[l] w:last where (key l:.d.rfn d `.f)<=max (0;n)};
.d.pline:{[] .d.oa "Current line: ",.d.pline2[.d.a;.d.n];};
.d.pl:{[] .d.O:(); .d.pline[]; .d.out[::]};

.d.fmap:enlist[::]!enlist`;
.d.makeFMap:{.d.fmap:(!). flip raze {raze {$[99h<type f:@[get;n:$[x~`;y;` sv `,x,y];0];enlist (f;n);99h=type f;$[any `~/:key f;raze .z.s[` sv x,y] each key `_ f;()];()]}[x] each key ` sv `,x} each `,(key `)};
.d.i:{[f;args]
  .d.hprevf:(); .d.makeFMap[];
  args:reverse $[(type args) within 0 19;$[0=count args;enlist (::);args];enlist args];
  .d.stprev:.d.sti:0; .d.c:`byte$(10;count args;00;00); .d.n:0; .d.a:(`.ns`.c`.a`.l`.g`.f`.id)!(`;();0#`;0#`;0#`;{"Entry point"};.z.P);
  .d.push each args; .d.push f;
  .d.state:`i; .d.bpsf:`int$();
 };

.d.stTime:.z.P;
.d.pEnv:{[f] .d.stTime:.z.P; .d.O:(); if[`s~.d.state; .d.oa "Not running"; : .d.out[::]]; f[1]};
.d.s:{[] .d.pEnv[{: .d.out $[`s~.d.state:.d.exec1[`c];.d.pop[];.d.state~`e;::;[.d.pstack[10]; .d.pline[]]]}]};
.d.pc:0x99; / 1 instr
.d.noadv:1b; / do not stop in adverbs
.d.skipAdv:{.d.noadv&any .d.a[`.f]~/:(.d.each;.d.eachp;.d.eachr;.d.over;{x y . z};.d.nargs;{x;y};{x[y;z]};{x,enlist y})};
.d.l:{[] .d.pc:0x99; .d.pEnv[{: .d.out $[`s~.d.state:.d.exec1/[{(.d.pc:.d.c .d.n;(x=`c)&(.d.skipAdv[]|not .d.pc in 0x000205060709))1};`c];.d.pop[];if[.d.state~`c;.d.pstack[10]; .d.pline[]]];}]}; / til next line of code, enter funcs
.d.next:{[] .d.pEnv[{if[0x00=.d.c .d.n; :.d.l[]]; : .d.out $[`s~.d.state:.d.exec1/[{[f;b;x](x=`n)or(x=`c)&not (f~.d.a`.id)&(.d.n in b)or 0x00=.d.c .d.n}[.d.a`.id;key .d.rfn .d.a`.f];`n];.d.pop[];if[.d.state~`c;.d.pstack[10]; .d.pline[]]];}]}; / til next line of code, do not enter funcs
.d.ef:{[] .d.pEnv[{$[`s~.d.state:.d.exec1/[{[f;x](x in `n`c)&not (f~.d.a`.id)&0x00=.d.c .d.n}[.d.a`.id];`n];: .d.out .d.pop[];: .d.l[]];}]};
.d.r:{[f;args]
  .d.i[f;args]; .d.O:(); .d.stTime:.z.P;
  :.d.out $[`s~.d.state:.d.exec1/[{x=`c};`c];.d.pop[];::];
 };
.d.cont:{[] .d.pEnv[{.d.bpsf:.d.bps .d.a`.f; : .d.out $[`s~.d.state:.d.exec1/[{x=`c};`c];.d.pop[];::]}]};

.d.pfunc:{[f] .d.oa string[til count v],'":",/:(" *"key[r]in .d.bps[f]),'" ",/:v:value r:.d.rfn f;};
.d.pf:{[f] .d.O:(); .d.pfunc[f]; .d.out[::]};
.d.func:{$[`s~.d.state; .d.oa "Not running";.d.pfunc .d.a`.f];};
.d.f:{.d.O:(); .d.func[]; .d.out[::]};

.d.exstr:"";
.d.timeout:00:05:00;
.d.exec1:{[]
  e:{[sti;n;x]
     .d.sti:sti;.d.n:n;
     .d.oa "Exception: ",.d.exstr:x;
     .d.pstack[10]; .d.pline[];
     `e};
  if[.d.timeout<.z.P-.d.stTime; : e[.d.sti;.d.n;"Debugger internal timeout, current value .d.timeout:",string[.d.timeout]]];
  if[not `e~r:@[.d.cmap[c];c:.d.c .d.n;e[.d.sti;.d.n]];.d.n+:1];
  if[(r~`c)&.d.n in .d.bpsf; .d.oa "Breakpoint"; .d.pstack[10]; .d.pline[]; :`b];
  : r;
 };

.d.h:{
  .d.O:();
  .d.oa (
   "DEBUG commands:";
   "START";
   "  .d.r[func;args] or .d.r[monad;enlist arg] - runs fn with args until exception or breakpoint";
   "  .d.i[func;args] or .d.r[monad;enlist arg] - prepares environment but do not start execution";
   "IN FUNCTION - EXEC";
   "  .d.cont[] - continue execution";
   "  .d.next[] - next line inside the current function (doesn't enter functions)";
   "  .d.ef[] - finish the current function";
   "  .d.l[] - next line (enters functions)";
   "  .d.s[] - next instruction";
   "IN FUNCTION - INFO";
   "  .d.f[] - prints the current function";
   "  .d.ps[] - prints top 10 stack entries";
   "  .d.psn[n] - prints top n stack entries";
   "  .d.pl[] - prints the current code line";
   "BREAKPOINTS";
   "  .d.pf[func] - shows the function with the breakpoint line numbers, bps are marked with *";
   "  .d.ba[`;line numbers] - add breakpoints to lines in the current function";
   "  .d.ba[func;line numbers] - add breakpoints to lines in the function";
   "  .d.bd[func;line numbers] - delete breakpoints from lines in the function";
   "  .d.bs[func;line numbers] - set breakpoints in the function to these lines";
   "  .d.bc[] - clear all breakpoints";
   "USEFULL VARS";
   "  .d.e - number of exceptions to pass into protected blocks (10000 by default). Set to 0 to always fail.";
   "  .d.a`var - local vars and function params are stored in .d.a. You can also find the current function in .d.a`.f";
   "  .d.c - Q bytecode of the current function.";
   "  .d.n - current Q instruction (see .d.cmap[0xXX] for the hint)";
   "  .d.st - stack");
  : .d.out[::];
 };

/ html support
.d.lnum:{[f;n] last where (key .d.rfn f)<=max (0;n)};
.d.Qs1:{if[""~r:.Q.s $[x~(::);x;99h<type x;$[`~f:.d.fmap x;x;: string f];0<>type x;x;`:dbg:fncall~first x;: "Fn call, line: ",string[.d.lnum[x[3]`.f;x 2]],", fn: ",.d.Qs1 x[3]`.f;`:dbg:excblock~first x;: "Catch block: ",.d.Qs1 x 1;x];r:.Q.s1 x]; $["\n"=last r;-1_ r;r]};
.d.hstkc:-1;
.d.hcmode:.d.hcpmode:`code;
.d.holda:(`symbol$())!();
.d.hstn:0;
.d.ph:{[x] $[(11#first x)~"debug.html?";.h.hy[`html] .d.html .h.uh ssr[11_ first x;"+";" "];.d.phold[x]]};
.d.hclrdef:{"<br>" sv {"<span class='nocolor' style='white-space: pre;'>",x,"</span>"} each "\n" vs ssr/[;"&<> \t";("&amp;";"&lt;";"&gt;";"&nbsp;";"&nbsp;")] x};
.d.hclr:{$[`qparse in key `; .qparse.htmlDbgColor[.qparse.tType .qparse.w x];.d.hclrdef x]};
.d.hc:"50 2000";
.d.halimit:0 20 14 10 8 6 5 4 3; / show max n lines when count[a] is m
.d.Qsfull:{c:system "c"; system "c ",.d.hc; s:.d.hclrdef .d.Qs1 x; system "c "," "sv string c; s};
.d.harg:{[m;a;k]
  l:".d.a[`",(n:string k),"] : ";
  if[(type a k) in 99 98h;
    if[(lm:(last .d.halimit)^.d.halimit m)<count a k;
      s:.d.Qsfull[a k];
      l:(.d.hclr l,.d.Qs1 sublist[lm-1;a k]),"<br><span onclick=\"showTbl('div",n,"')\">Click for full view</span>";
      :l, "<div style='display: none'><div id='div",n,"' class='argtbl' onclick='$.unblockUI()'>",s,"</div></div>";
    ];
  ];
  : .d.hclr l,.d.Qs1 a k
 };
.d.hargs:{
  a:$[.d.hcmode in`show`code;.d.a;.d.st[.d.hstn][3]];
  $[(not .d.state~`s)&0<count k:k where not (k:key a) like ".*";r:.d.harg[count k;a] each k;: "No arguments or local variables"];
  if[(.d.hcmode<>`code)or not .d.holda[`.id]~a[`.id]; : "<br>" sv r];
  :"\n" sv (({"<div class='bgchanged'>",x,"</div>"};{"<div>",x,"</div>"}) a[k]~'.d.holda[k])@'r;
 };
.d.hstack:{
  r:"<b>Current status:</b> ",$[.d.state~`s;"not running";any .d.state~/:`i`c;"running";.d.state~`e;"<span style='color: #ff0000;'>exception</span>";.d.state~`b;"breakpoint";.Q.s1 .d.state];
  if[not .d.state~`s;
    r,:",&nbsp;&nbsp;<b>Current function:</b> ",$[`~f:.d.fmap .d.a`.f;"anonymous, see the body below";string f],"<br><br>";
    r,: "\n" sv {s:.d.hclr ".d.st[",string[x],"] : ",.d.Qs1 y; $[`:dbg:fncall~first y;"<div id='stk",string[x],"'>",s,"</div>";s,"<br>"]}'[i;.d.st i:i where (i:.d.sti-1+til 25)>=0];
  ];
  : r;
 };
.d.hcache:enlist[::]!enlist "";
.d.hcode:{
  if[(.d.state~`s)&.d.hcmode<>`show; : "N/A"];
  n:$[.d.hcmode~`code;.d.n;.d.hcmode~`show;0;.d.st[.d.hstn]2];
  ff:.d.rfn .d.hprevf:f:$[.d.hcmode~`code;.d.a`.f;.d.hcmode~`show;.d.hprevf;.d.st[.d.hstn][3]`.f];
  .d.hcpmode:.d.hcmode; .d.hcmode:`code;
  bg:count[key ff]#enlist "bgnorm";
  if[0<c:count b:.d.bps f; bg[last each where each (key ff)<=/:b]:c#enlist "bgbpoint"];
  bg[last where (key ff)<=max (0;n)]:"bgcurr";
  if[""~.d.hcache f;.d.hcache[f]: .d.hclr each value ff];
  : "\n" sv "<div id='codediv",/:string[key ff],'"' class=\"",/:bg,'"\">",/:.d.hcache[f],\:"</div>";
 };
.d.hbp:{
  b:.d.hclr each ("Lines: ",/:"," sv/: string (key each .d.rfn each k)?'asc each v:1_ value .d.bps),'" in ",/:.d.Qs1 each k:1_ key .d.bps; / bps
  n:1_ til count key .d.bps;
  : "Click to view:<br>","\n" sv ("<div onclick='showFn2(",/:string[n],'")'>",/:b,\:"</div>") where 0<count each v;
 };
.d.hexec:{
  v:@[{if[(n:`$x) in key a:$[.d.hcpmode in `code`show;.d.a;.d.st[.d.hstn][3]];: a n]; value x};x:13_ x;{"'",x,"\n"}];
  pfx:$[(type v) in 98 99h; "<br><a onclick=\"showTbl('div",n,"')\">Click for full view</a><div style='display: none'><div id='div",(n:string `int$.z.T),"' class='argtbl' onclick='$.unblockUI()'>",.d.Qsfull[v],"</div></div><br>";""];
  : .d.hxr[x],$["'"~first v;v;.d.hclr .Q.s v],pfx;
 };
.d.hxr:{"<b>Expression received:</b><br>",.d.hclr[x],"<br><b>Result:</b><br>"};
.d.html:{[x]
  if[x~`init; if[.z.ph~.d.ph; :([] a:())]; @[{system "l ",.h.HOME,"/qparse.q"};1;1]; .d.phold:.z.ph; .z.ph:.d.ph; :([] a:())];
  x:$[null n:first ss[x;"&_=[0-9]"];x;n#x]; x[where (`int$x)>127]:" ";
  if[x~"args"; : .d.hargs[]];
  if[x~"stack"; : .d.hstack[]];
  if[x~"code"; : .d.hcode[]];
  if[x~"execst"; : $[.d.na;"true";""]];
  if[x~"excpcnt"; : string .d.e];
  if[(6#x)~"setcnt"; .d.e: 0^"I"$6_ x; :"ok"];
  if[x~"toggleExec"; .d.na:not .d.na; :"ok"];
  if[(4#x)~"prep"; : .d.hxr[x],@[{.Q.s .d.i[value x;1]; "ok"};"{[]",(x:9_ x),"}";{"'",x}]];
  if[(3#x)~"run"; if[not ()~r:@[{.d.i[value x;1]; ()};"{[]",(8_ x),"}";{"'",x}]; :r]; x:"cont"];
  if[(8#x)~"execcode"; : .d.hexec[x]];
  if[(8#x)~"sshowstk"; .d.hstn:"I"$8_ x; .d.hcmode:`sshow; :"ok"];
  if[(12#x)~"setbpcodediv"; .d.bps[.d.hprevf]:$[(bp:"I"$12_ x)in bps:.d.bps[.d.hprevf]; bps except bp; 0^bps,bp]; .d.hcmode:.d.hcpmode; :"ok"];
  if[(6#x)~"showfn"; : .d.hxr[x],@[{f:value x;if[100h<>type f;'"User function is expected"];.d.hprevf:f;.d.hcmode:`show;"ok"};x:11_ x;{"'",x,"\n"}]];
  if[x~"showbp"; : $[0=count where (count each 1_ .d.bps)>0;"No breakpoints!"; .d.hbp[]]];
  if[x~"clearbp"; .d.bc[]; :"All breakpoints are deleted"];
  .d.holda:.d.a;
  if[x~"into"; v:.d.l[]];
  if[x~"over"; v:.d.next[]];
  if[x~"instr"; v:.d.s[]];
  if[x~"fend"; v:.d.ef[]];
  if[x~"cont"; v:.d.cont[]];
  : $[.d.state~`e;.d.exstr;.d.state~`s;.d.hclr .d.Qs1 v;"ok<br>"];
 };
