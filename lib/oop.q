/ Converts sym to its value.
/ @param x (symbol|any) Input.
/ @returns any Returns the sym value or the passed value.
.oo.unsym:{$[-11=type x;get x;x]};
/ For a symbol prepare its set expression.
/ @param name (symbol|any) Input value.
/ @returns any Returns set[name] ir id function.
.oo.set:{$[-11=type x;set[x];::]};
/ Transforms N arg function to any number of args function.
/ @param x func function.
.oo.makeg:{(')[x;enlist]};

/ Create an anonymous general fn.
/ @param f func General function or (::).
/ @param b func Function to be added to the general function.
/ @param a long - Number of the f arguments.
/ @returns func General function that calls 'f' for 'a' number of arguments. If it is not defined for some 'a' then 'undefined will be raised.
.oo.defgen0:{[f;b;a] f:$[f~(::);.oo.makeg .oo.defcore 9#.oo.makeg {'"undefined"};105=type f;f;'type]; .oo.makeg {(x count y). y}@[(value value[f]0)1;a;:;b]};
.oo.defcore:{(x count y). y};

/ Create a general function. Such function can accept any number of arguments from 0 to 8.
/ .oo.defgen is generic itself and accept up to 3 arguments. 3 types of input functions are accepted: symbol (function name), function or function list. Mixed lists of functions and symbols can be used too.
/ 1 arg:
/  {fn} or fn list or `fn - create a generic fn from a function, optionally assign it back to `fn, fn type should be 100
/ 2 args:
/  [`genfn1;`fn2 or fn2 or fn2 list] or [genfn1;`fn2 or fn2 or fn2 list] - add fn2 to the generic function genfn1, assign it back to `genfn1, genfn1 can be ` or (::) if there is no generic func.
/  [fn or fn list;N or N list] or [`fn;N] - create a generic function from fn, assign it back to `fn. N - number of args (can be used when fn is not 100 type fn).
/ 3 args:
/  [`genfn;`fn2 or fn2 or fn2 list;N or N list] - like mixed 2 args case.
/  [genfn;`fn2 or fn2 or fn2 list;N or N list]
.oo.defgen:.oo.defgen0/[(::);({.oo.set[x].oo.defgen[::;x]};
  {$[type[y]in -6 -7 6 7h;.oo.set[x].oo.defgen[::;x;y];.oo.defgen[x;y;{$[100=type x:.oo.unsym[x];count(value x)1;'type]}each y]]};
  {.oo.set[x].oo.defgen0/[$[x~`;x:(::);-11=type x;@[get;x;{}];x];.oo.unsym each y;z]});1 2 3];

/ default func is called once by default but it can call the next fn. In this case it should have two args with names `state`args but defined with the proper number of arguments: defmeth[`m;{[state;args] ...};5]
.oo.aspect.default.unique:1b; / unique=1b means only 1 such fn can exist in a multimethod per arg combination
.oo.aspect.default.order:1b;  / sort by specificity or reverse
.oo.aspect.default.fn:{[sett;args;func;i] r:f . $[`state~first (value f:func[i;`f])1;enlist[(sett;func;$[`default=func[i+1;`a];i+1;-1])],args;args]; .oo.aspect.after.fn[sett;args;func;i]; r}; 

/ after can't do anything with the result, but it is sorted in the desc order
.oo.aspect.after.unique:0b;
.oo.aspect.after.order:0b;
.oo.aspect.after.fn:{[sett;args;func;i] (func[`f] where `after=func[`a]).\:args;};

/ before is allowed to modify input args but doesn't have to.
.oo.aspect.before.unique:0b;
.oo.aspect.before.order:1b;
.oo.aspect.before.fn:{[sett;args;func;i] while[`before=func[i]`a; if[count[args]=count r:func[i;`f] . args; args:r]; i+:1]; .oo.aspect[func[i]`a][`fn][sett;args;func;i]};

/ around function in a multimethod should have 2 args - (multistate;args) - regardless how many args the default function has.
.oo.aspect.around.unique:1b;
.oo.aspect.around.order:1b;
.oo.aspect.around.fn:{[sett;args;func;i] func[i;`f][(sett;func;i+1);args]};

/ raze calls all default methods and combines their results. Function must have 2 args - input args and results from defaults.
.oo.aspect.raze.unique:1b;
.oo.aspect.raze.order:1b;
.oo.aspect.raze.fn:{[sett;args;func;i] r:func[i;`f][args;(func[`f] where `default=func[`a]).\:args]; .oo.aspect.after.fn[sett;args;func;i]; r};

/ to handle missing functions
.oo.aspect.error.unique:1b;
.oo.aspect.error.order:1b;
.oo.aspect.error.fn:{[sett;args;func;i] 'undefined};

.oo.aspects.order:`msgoop`around`before`raze`default`after`error;

/ define class: name, subclasses, initial dictionary
/ initial dictionary contains all class fields + some settings
/ Settings:
/  .init - will be called when an instance is created init[obj dict;passed args]. init gets a dictionary not an object thus general fns will not recognize it as an obj.
/  .class - will be set to the user class name.
/  .pclass - will be set to the class names of subclasses.
/  ..obj - will be set to the undelying obj name
.oo.classNS:`.objs; / namespace for instances and class definitions. .objs by default.
.oo.cid:`$"_obj_"; / reference counter
.oo.oid:0; / object number cnt
.oo.cmap:()!(); / map from the class names to their base objects with static fields and etc
/ Leaf garbage collector, doen't resolve circles.
.oo.gc:{if[(x~`)|x~(::);x:key .oo.classNS]; if[count o:x where{if[1=-16!.oo.classNS[x]`.id; @[.oo.classNS;x;:;1]; :1b];0b}each x:x where x like\: "o[0-9]*"; ![`.objs;();0b;o]]; count o};
.oo.addCType:{[n;s] if[not all s in key .oo.pmap; '"Subclass is undefined"]; .oo.tmap[n]:n; .oo.pmap[n]:distinct n,(raze .oo.pmap s),`any};
.oo.defclass:{[n;sub;i] .oo.addCType[n;sub]; i:(`.pclass`.class`.init!((),sub;n;{y;x})),i; (cn:`$string[.oo.classNS],".",string[n],"_c")set i; .oo.cmap[n]:cn; n};
.oo.getInstance:{[n;a] if[not 99=type c:@[get;.oo.cmap n;0];'"Class undefined: ",.Q.s n]; (c`.init)[({$[count x;(k where not (k:key[x]except`:.meths`:.this`:.acc)like"..*")#x;x]},/[.oo.getInstance[;a]each c`.pclass]),c;a]};
.oo.makeInstance0:{[a] c:.oo.getInstance[a 0;1_a]; c[`..obj`.id]:(n:`$string[.oo.classNS],".o",string .oo.oid+:1;enlist .oo.cid); c};
.oo.makeInstance:.oo.makeg {c:.oo.makeInstance0[x]; c[`..obj] set c; {z;x}[c`..obj;c`.id]}; / accepts any number of args
.oo.isObj:{if[105=type y;y:first value y]; if[104=type y;y:value y;if[enlist[.oo.cid]~y 2;:y 1]]; $[x;'"Not object";`]};
/ raw methods to set/get any fields
.oo.setFld:{[th;f;v] oo:.oo.isObj[1;th]; $[f like ":*";@[.oo.cmap oo`.class;f;:;v];@[oo;f;:;v]]; th};
.oo.getFld:{[th;f] oo:.oo.isObj[1;th]; $[f like ":*";.oo.cmap oo`.class;oo] f};

/ Java like objects
/ .oo.class[`name;subclasses;list of members]
/ List of members: ((`publicVal;iVal);(`.protectedVal;i);(`:staticVal;i);(`;`f;{}))
/ Functions wishing to call other obj function should have 'th' (this) or TH (THIS) as the first argument. th gives access to the object, TH is the objects name and gives direct access to non-static fields.
/ th and TH can be converted to each other via .oo.getThis[TH] or .oo.getTHIS[th]. getThis returns protected verion of this with no access to protected fields and no writes to readonly fields.

/ check if a function have TH or th argument.
.oo.hasTGen:{"j"$$[(enlist)~last v:value x;.oo.hasThis[v 0]|$[104=type v 0;$[.oo.defcore~(v:value v 0)0;max .oo.hasThis each v 1;0];0];any v[1]~/:.oo.proxy;max .oo.hasThis each value[v 0][2;`f];.oo.hasThis v 1]};
.oo.hasThis:{[f] "j"$$[100=t:type f;$[`th=f:first value[f]1;1;`TH=f;3;0];-11=t;.z.s value f;104=t;.z.s first value f;105=t;.oo.hasTGen f;t within(106;111);.z.s first value f;0]};
/ Default setters and getters: obj[`field], obj[`field;10], obj[`field;+;10]
/ Default doesnt exist handler: if the first arg is a sym list applies each.
.oo.setf:{[TH;f;fn;v] @[TH;f;fn;v]; .oo.getThis TH};
.oo.setfs:{[TH;f;fn;v] @[.oo.cmap TH`.class;f;fn;v]; .oo.getThis TH};
.oo.getf:{[TH;f] TH f};
.oo.getfs:{[TH;f] .oo.cmap[TH`.class] f};
.oo.getSetGet:{[x] .oo.defgen[;1 2 3] $[x like ":*";.oo.getfs[;x],.oo.setfs[;x;:],.oo.setfs[;x];.oo.getf[;x],.oo.setf[;x;:],.oo.setf[;x]]};
.oo.undef:{[th;a] $[11=type a 0;(th'). a;'.Q.s a 0]};
.oo.getFields:{y:enlist[(`.meth;::)],y;f:(!). flip y where 2=i:count each y;f[`.meth]:update c:x from (flip `t`n`f!flip ((`;x;.oo.makeg .oo.defcnstr[;x]);(`;`;.oo.undef)),({(`;x;.oo.getSetGet x)}each key f),y where 3=i);f};
.oo.class:{[n;s;m] .oo.defclass[n;$[s~(::);();s~();`obj;distinct (),s];.oo.getFields[n;m]]};
.oo.setupMeth:{[m] m:(exec last f by n from update n:`${string[x],":",string y}'[c;n] from m),exec last f by n from m;(m;.oo.hasThis each m)};
.oo.getClass:{[a] if[not `:.meths in key c:.oo.makeInstance0[a]; c[`:.meths`:.this]:.oo.setupMeth {(,/[.z.s each c`.pclass]),(c:get .oo.cmap x)`.meth}a 0; c[`:.acc]:.oo.getAcc c]; c};
.oo.getAcc:{[c] k!{x:last ":"vs string x;$["."=x 0;2;x[0]in .Q.A;1;0]}each k:distinct ((key c),key c[`:.meths])except`.class`};
.oo.exec:{[n;id;a] if[11=abs type m:a 0; if[2=m:max n[`:.acc](),m;'protected]; if[(1<count a)&1=m;'readonly]]; .oo.pexec[n;id;a]};
.oo.pexec:{[n;id;a] ms:n[`:.meths]; $[-11=type m:a 0;if[not m in key ms;a:(m:`;a)];a:(m:`;a)]; a:$[th:(n`:.this)m;$[th=3;n;.oo.makeg .z.s[n;id]];()],1_a; ms[m] . $[count a;a;(),(::)]};
.oo.new:.oo.makeg {c[`..obj] set c:.oo.getClass[x]; o:.oo.getThis c`..obj; o . x; o};
.oo.getTHIS:{[t] .oo.getFld[t;`..obj]};
.oo.getId:{[t] $[-11=type t;t;.oo.getFld[t;`..obj]]};
.oo.getThis:{[TH] .oo.makeg .oo.exec[TH;TH`.id]};
.oo.defcnstr:{[th;x]th[0].@[th;0;:;last .oo.cmap[x]`.pclass]};
.oo.setcnstr:{.oo.makeg {[TH;f] if[count[f]<>-1+count TH; 'numargs]; .oo.setf[TH 0;;:]'[f;1_TH]}[;x]}; / set N fields to N values in constr
.oo.setgcnstr:{.oo.makeg {[TH;f;fn] if[count[f]<c:-1+count TH; 'numargs]; .oo.setf[TH 0;;:]'[c#f;1_TH]; fn[TH]}[;x;y]}; / set up to N fields to N values in constr and call a fn
.oo.getInfo:{[f] o:get(value first value f)1; o};

/ 1: defmeth[`fname|fname]
/ 2: defmeth[`fname|fname;arg|arg list] - default function, body should have type 100, args are taken from non list
/ 3: defmeth[`gname|gname;`fname|fname;arg | args]
/ 3: defmeth[aspect;`fname|fname;arg | args]
/ 4: defmeth[`gname|gname;aspect;`fname|fname;arg | args]
/ returned value - name if it is a symbol and an anonymous multimethod otherwise.
/ to remove a meth: the same args with body set to (::)
.oo.defmeth3:{[fn;x;y;z] if[-11=type x;if[x in .oo.aspects.order; :.oo.set[y] fn[::;x;y;z]]]; fn[x;`default;y;z]};
.oo.defmeth:.oo.defgen[(  / define as a general function
  {.oo.defmeth[`default;x;`any]}; {.oo.defmeth[`default;x;y]}; {.oo.defmeth3[.oo.defmeth;x;y;z]}; / 1 2 3 args
  {[g;a;m;p] if[not a in .oo.aspects.order;'aspect]; m:.oo.unsym m; p:$[type[p]within (0;80);p;(count value[m]1)#(),p]; if[g~`;g:(::)]; $[t;set[g];::] .oo.defmeth0[$[t:-11=type g;@[get;g;{y;.oo.gen0 x}[count p]];g~(::);.oo.gen0 count p;g];a;p;m]})];

/ like defmeth, combines multimethods and general functions.
.oo.defgmeth0:{[g;a;m;p]
  if[-11=type gg:g;gg:$[`=g;g:(::);@[get;g;{::}]]];
  fn:last value first value gg:$[gg~(::);.oo.defgen[.oo.gen0 each c;c:1+til 8];105=type gg;gg;'type];
  m:.oo.unsym m;
  p:$[type[p]within (0;80);p;(count value[m]1)#(),p];
  : .oo.set[g].oo.defgen[gg;.oo.defmeth[fn count p;a;m;p];count p];
 };
.oo.defgmeth:.oo.defgen[(
  {.oo.defgmeth[`default;x;`any]};{.oo.defgmeth[`default;x;y]};{.oo.defmeth3[.oo.defgmeth;x;y;z]};.oo.defgmeth0)];

/ Create an anonymous multimethod
/ fn:'[main;proxy], main: disp[settings;map;cnsts;(tmap;fmap;cmap) x NArgs]
.oo.defmeth0:{[fn;asp;args;body]
  fn:.oo.unpack fn;
  if[count[args]<>count fn 4; 'args_number];
  fn[3]:{{if[(c:count x)=r:x?y;x,:enlist y];x}/[x;y]}/[fn 3;a:.oo.getArgs args]; / calc args and add new consts
  t:.oo.calcID[string .oo.aspects.order?asp;.oo.aspect[asp;`order];fn 3] each a:(0N 2)#/:a; / calculate id of each row
  if[.oo.aspect[asp]`unique; fn[2]:update f:body from fn[2] where id in t; t:t b:where not t in fn[2]`id; a:a b]; / update existing unique entries
  if[(body~(::))|count t;
    fn[2]:`id xasc delete from (fn[2],([] a:asp; id:t; args:a; f:body)) where f~\:(::); / update dispatch map
    fn[4]:.oo.calcMap[fn 3;fn 2] each til count args; / recalculate args map
  ];
  : .oo.pack fn;
 };

/ find out the applicable methods and process them
.oo.disp:{[sett;map;cnst;amap;args] .oo.makeCall[sett;args] map asc distinct inter/[.oo.disp1'[amap;args]]};
.oo.disp1:{[map;a] (raze map[0] .oo.getType a),(raze map[1;1]where(map[1;0])@\:a),map[2;1]where map[2;0]~\:a}; / calc row idx for an arg
.oo.makeCall:{[sett;args;funcs] if[0=count funcs;'undefined]; .oo.aspect[funcs[0;`a]][`fn][sett;args;funcs;0]};
.oo.callNext:{[sett;args] if[(-1=sett 2)|0=count funcs:sett 1;'undefined_next]; .oo.aspect[funcs[0;`a]][`fn][sett 0;args;funcs;sett 2]};

/ get type of an arg
.oo.getType:{.oo.pmap $[(t:type x)in 98 99h;.oo.tType x;t=105;$[`=oo:.oo.isObj[0;o];`func;o`.class];.oo.shmap t]}; / symbol type of an arg + all parent types
.oo.tType:{$[99=type x;$[all 98=type each (value x;k:key x);`ktable;`dict];not -11=type v:value flip x;`mtable;v like ":*";`stable;`ptable]};

/ id - aspN_a1type_a2type_... - to simplify sort and search
.oo.calcID:{[a;o;cmap;ar] `$a,"_","_"sv{string[z 0],string $[y;999999-;100000+]$[2=z 0;value[.oo.tmap]?z 1;x?z 1]}[cmap;o] each ar};

/ recalculate args map for 1 arg
.oo.calcMap:{[const;m;a] m[`ty`c]:flip m[`args][;a]; (exec i by c from m where ty=2;exec (c;i) from m where ty=1;exec (c;i) from m where ty=0)}; / type map, func map, const map

/ get the gen func components: (main;sett;map;cnsts;(cfg);proxy)
.oo.unpack:{value[v 0],(v:value x)1};
/ create a gen func
.oo.pack:{(')[x[0]. x[1 2 3 4];x 5]};
/ create an initial method with a dummy entry
.oo.gen0:{.oo.defmeth0['[.oo.disp[()!();([] a:0#`;id:0#`;args:();f:());(),(::);x#0];.oo.proxy x];`error;x#`any;enlist@]};

/ arg: typeExpr | consts | func | (`:const;const1;...) | (::)
/ (::) - no restriction on the arg, also "." and "any" can be used. 
/ func - predicate on the arg
/ consts - constant arg, lists are treated as several possible consts
/ `:const - to escape consts when they conflict with other exprs
/ typeExpr - char | string | symbol | symbol list | short | short list
/   symbols and sym lists that are not 100% in the .oo.tmap are treated as consts
/   general or 0 - type 0 list.
/   string expr: "i table myClass", sym: `i`table`myClass, short: -6 98h
/ it is not possible to mix several types of arg exprs.
.oo.getArg:{[a] b:(),a;if[10=t:abs type a;b:`$" "vs b];if[5=t;b:.oo.shmap b];$[t in 5 10 11h;$[not any null c:.oo.tmap b;(2;c);11=t;(0;b);'"Undefined type"];a~(::);(2;(),`any);100=t;(1;a);`:const~first a;(0;1_ a);(0;$[t<98;b;enlist a])]};
.oo.getArgs:{[a]cross/[{flip((count x 1)#x 0;(x:.oo.getArg x)1)}each a]};

/ proxys for fns up to 8 args, to support correct projections and etc
.oo.proxy:(::),{value "{[",x,"]enlist[",(x:";"sv string x),"]}"} each  (1+til[8])#\:-8?`1; 

/ type maps: from str&sym and short, map from types to parent types
.oo.tmap:{(d,`0`.,v2,v1,upper[k],k:`b`g`x`h`i`j`e`f`c`s`p`m`d`z`n`u`v`t)!(d:`any`list`atom`table`dict`ktable`stable`ptable`mtable`func`enum`enumlist`obj),`list`any,v2,v1,(v2:`$string[v1],\:"list"),v1:`bool`guid`byte`short`int`long`real`float`char`symbol`timestamp`month`date`datetime`timespan`minute`second`time}[];
.oo.shmap:{{("h"$raze x 0)!.oo.tmap raze x 1}flip((neg e;60#`enum);(e:20+til 60;60#`enumlist);(0 98 99,100+til 13;`0`table`dict,13#`func);(neg v;`$(),/:.Q.t v);(v;`$(),/:upper .Q.t v:1 2,4+til 16))}[];
/ type order:
/ atomic types: `type`atom`any
/ list types: `type`list`any
/ keyed table: `ktable`table`dict`any
/ splayed: `stable`table`any
/ parted: `ptable`table`any
/ in-memory: `mtable`table`list`any
/ func: `func`any
/ objs: `name`parent...`obj`dict`any
.oo.pmap:{m:`any`dict`func`obj`list`atom!(();`dict`any;`func`any;`obj`any;`list`any;`atom`any);m:m,(v!((v:v where(v:distinct value .oo.tmap)like "*?list"),\:`list`any)),(k!k:.oo.tmap`b`g`x`h`i`j`e`f`c`s`p`m`d`z`n`u`v`t`enum),\:(`atom`any);m[v]:(v:`table`ktable`stable`ptable`mtable),'(`list`any;`table`dict`any;`table`any;`table`any;`table`list`any);m}[];

.oo.class[`obj;::]
  ((`;`obj;{[TH] if[`..abstract in key TH;'abstract];}); / ensure abstract classes can't be created
   (`;`this;{[th] .oo.makeg .oo.exec . 1_ value (value th)0}); / return protected this
   (`;`.class;{[TH] TH`.class}); / obj class
   (`;`.pclass;{[TH] TH`.pclass});
   (`..abstract;1));

