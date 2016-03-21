\d .d2

mv:(value(1;))2; / magic value
im:@[256#0;cm+cm1:11 26 96 120 128 160;:;@[cm:til each 7 6 24 8 32 96;2;reverse]]; / var/const index
dm:@[256#3;cm+cm1;:;til 6]; / code category
cnst:(();0;1;,;`;::;::;';/;\;':;/:;\:); / basic consts
un:`::`flip`neg`first`reciprocal`where`reverse`null`group`hopen`hclose`string`enlist`count`floor`not`key`distinct`type`value`read0`read1`2::`avg`last`sum`prd`min`max`exit`getenv`abs; / unary fns
bi:(`$(),/:":+-*%&|^=<>$,#_~!?@."),`0:`1:`2:`in`within`like`bin`ss`insert`wsum`wavg`div; / binary fns
ub:value each string un,bi;
ns:`:foo^`$1_ string system "d"; / dbg namespace

/ code parse fns: code -> (stk pos;func;arg), return has 4 elements because of the global assign
c:256#{(y+d<>1;(::;{x[1]fr x 0};f;f:{fr . x};get;::)d;(cnst;y,cnst@7+;6,;5,;x 3;4_x)[d:dm c]im c:z 0)}; / cnst0, adv, arg, loc, glob, const
c[17]:{z;1_value {y}[y+1;::;]}; / magic value
c[32+til 64]:{(y-b;{x . fr y}ub c-32;y-til 1+b:63<c:z 0)}; / unary/binary
c[0]:{z;(y;{$[(::)~fr 3;fr[2 4]:(0;fr x);[v:fr x;fr::fr 3;fr[sTop::fr 4]:v]]};y;`ret)}; / return
c[1]:{z;(y;{'fr x};y)}; / raise an exception
c[2]:{z;(y-1;::;())}; / end of stm: ;
c[3]:{(y;{gt 1;:fr[x;y]:fr z}[8-dm z;im z:96+z 1];y)}; / simple assign
c[4]:{(y-1;({fr::.[fr;x:x,fr y 1;y 0;fr y 2];ass[fr;x]};{.[x;y:fr y 1;y 0;fr y 2];ass[x;y]})[d=2](6,;5,;x 3)[d:-2+dm c]im c:z 1;(ub 32+z 2),y-0 1)}; / general assign
c[5 6 7 8 9]:({(y-1;gt;z 1)};{(y-1;{gt$[fr y;1;x]}z 1;y)};{(y;{gt$[fr y;[fr[y]-:1;2];1+x]}z 2;y)}),2#{(y-8=z 0;{gt neg 1+x};z 1)}; / goto forward/condit/do/bkward
c[10 82 83]:{(y-a;{fr[4]:cc 0;if[x;gt 1];$[count e:empargs a:1_z:fr z;part[z 0;a;e];appf2[y;z]]}[10=z 0;83=z 0];y-til 1+a:1^z 1)}; / applications, enlist will deal with the magic value

/ helpers
gt:{fr[1]+:x}; / goto +N
cc:{fr[0;fr 1] x}; / current bytecode
ass:{gt 2;$[4=count fr[0;1+fr 1];::;$[y~();get x;x . y]]}; / assign + implicit return = null value
excp:{@[{if[e;e-:1;fr::{$[(::)~y:y 3;'x;y]}[x]/[{6<>x 2};fr];fr[2 4]:(5;sTop::cc 0);v:$[99<type f:fr sTop;app[{x y};(f;x)];f];gt 1;:v];'x};x;{fr[2 4]:(1;x)}]}; / handle exceptions
spf:{(x~(@))|(x~(.))|(100=t)|(t:type x)within 104 111h}; / special function - worth interpreting in gen apply
nargs:{v:value x;$[0=t:-100+type x;count v 1;t=1;1;t in 2 9 10 11;2;t in 7 8;$[2=n:nargs v;1;n];t=4;nargsp v;t=5;nargs last v;t=6;nargs v;'"not impl"]}; / num of args
nargsp:{(0|1+nargs[x 0]-count x)+count empargs x}; / required num of args for parted fn
empargs:{r:();i:-1;do[count x;r,:104=type(1;x i+:1)];where r}; / idx of missing args
part:{$[9>c:count y;x . y;(value "{x[",(";"sv @["y ",/:string til c;z;:;(count z)#enlist""]),"]}")[x;y]]};
tpart:{if[count b:(c:count i:empargs a:1_ v:value x)#y;a[i]:b];a:a,c _ y;$[104=type v 0;.z.s;app][v 0;a]}; / transform part fn into app form
out:{(-1;::)[.z.w>0]};
senv:{sT::.z.P;pc::0};

/ app functions
app:{apm[abs type x][x;y]}; / general app
appf:{d:x~(.);if[(99<type y 0)&3=c:count y;fr[2]:6;:appf[x;2#y]];$[1=c;x . y;2=c;appf2[d;y];spf y 2;app[(appN 4&0|d+2*c-3);y];x . y]}; / @ and . : in exc blk mark the frame
appf2:{Y,::enlist (x;y);if[x;if[(type y 1)within 0 98;:app . y];'`type];app[y 0;1_ y]}; / general app, x=1 - (.)[a;b]
appN:({@[x;y;:;z each x y]}; / @ - 3 args
   {z:cross/[z]};
   {[i1;a;i2;f]$[0=count i2;.[a;i1;:;f a . i1];0>type i:i2 0;.z.s[i1;;;f]/[a;i,:\1_i2];.z.s[i1,i;;;f]/[a;1_i2]]}(); / . 3 args
   {[a;i;f;v] @[a;i;:;f'[a i;v]]}; / @ 4 args
   {[i1;a;i2;f;v]$[0=count i2;.[a;i1;:;f[a . i1;v]];0>type i:i2 0;.z.s[i1;;;f]/[a;i,:\1_i2;v];.z.s[i1,i;a;1_i2;f;v]]}(); / . 4 args
   {'`rank}); / @ and .  default
appq:{if[4>count y;x . y];fr[4]:y;value["{[",(";"sv string v 0),"]",(";"sv string[v 2],'":.",n,".fr[6]",/:string 1+til count (v:value fr[6;0])2),";(",string[x],"). .",(n:string ns),".fr 4}"]. fr[5]}; / qsql, create env and exec fn
/ app type map
apf:(each;over;scan;prior);
apm:128#(.); / default application
apm[11]:{$[-11h=type x;app[get x;y];x . y]}; / redirect globals
apm[100]:{$[4>i:apf?x;app[cnst[7+i]y 0;1_y];count[y]<>count(v:value x)1;x . y;na|(first v 3)in skpns;x . y;gif[x;y;fr]]}; / simple fn call
apm[101 102]:{$[x in (@;.);appf[x;y];x in (!;?);appq[x;y];x~(enlist);y;x . y]}; / special forms/selects/other fns
apm[104]:{$[nargsp x,y;x . y;tpart[x;y]]}; / parted fn
apm[105]:{app[{x y . z};value[x],enlist y]}; / composite fn
apm[106+til 6]:{if[count[y]<nargs x;:x . y];if[na|not[spf v]&$[100=type v:value x;(not v in apf)&(first value[v]3)in skpns;1b];:x . y];app[adv t;(v;y;t:type[x]-106)]}; / adverbs
/ adverbs
adv:6#(::);
adv[0]:{z;if[98=type y;:(cols y)!.z.s[x;value each y;0]];if[any f:99=t:type each y;if[not(all f)|all c~\:k:distinct raze c:key each y w:where f;'`domain];y[w]:y[w]@\:k;:k!.z.s[x;$[98=type y;value flip y;y];0]];
  if[any t within 0 98h;y:flip y;i:-1;r:(c:count y)#(::);do[c;r[i]:x . y i+:1];:r];x . y}; / each
adv[1 2]:{s:({y};{x,enlist y})z=2;n:nargs x;c:count y;r:();if[(c=1)&n=1;f:l:y 0;while[1;r:s[r;l];if[(f~l)|(l:x l)~l;:r]]]; / iterate on val
  if[(c=2)&n=1;r:s[r;l:y 1];$[type[a:y 0]in -6 -7h;do[a;r:s[r;l:x l]];while[a l;r:s[r;l:f l]]];:r]; / iterate N/cond
  if[any f:99=t:type each a:(c:c<>1)_y;if[not all 1_~'[k 0;k:key each a w:where f];'`domain];$[98=type y;y:value flip y;y[c+w]:value each a w];:$[z=1;::;![k 0].z.s[x;y;z]]]; / dict case
  if[not c;$[1=c:count y:y 0;:s[r;first y];2=c;:s[y 0;x . y];[r:1#y;y:(y 0;1_ y)]]]; / adjust f[a] to f[a;b]
  if[any t within 0 98h;l:y 0;y:flip 1_y;i:-1;do[count y;r:s[r;l:x[l]. y i+:1]];:r];x . y}; / scan/over
adv[3]:{if[99=type l:last y;y:(-1_y),enlist value l;:(key l)!.z.s[x;y;z]]; / dict case
  if[all not(type each y)within 0 98h;:$[1=count y;y 0;x . y]]; / atom case
  if[1=nargs x;:adv[0][x;y;0]];y:enlist[$[1=count y;l -1;y 0]],l;i:0;r:(count l)#(::);do[count l;r[i]:x[y i+:1;y i]];r}; / peach
adv[4 5]:{s:z=4;if[99=t:type y s;k:key y s;y[s]:value y s;:k!.z.s[x;y;z]];
  if[not(t within 0 98h);:x . y];i:0;r:(count y s)#(::);do[count y s;r[i]:$[s;x[y 0;y[1;i]];x[y[0;i];y 1]];i+:1];r}; / each right/left

/ frame:
/ (code;index;state;parent;exc/register;args;locals;id;stack....)
fr:7#0; / prevent exc on a spurious run
fs:(!). 2#2(,:)/(::); / processed fns
gb:{count[z]#enlist c[z 0][x;y[0;0];z]}; / calculate fn code
gc:{.[;(where c in 0x00020506070809;0);0 1!()]raze enlist[(),7]gb[x]\(where differ sums prev 0=0{$[x=0;0^0 0 0 1 2 1 1 2 1 1 1@y;x-1]}\c)cut c-(c=9)&7=c til[count c]-next c:-1_x 0}; / process fn to get its code
gf:{if[not(::)~f:fs x;:f];:fs[x]:(gc @[v;3;{$[`~first x;x;` sv/:(`,x 0),/:x]}];-1;5;::;::),(::;x,count[v 2]#enlist()),0,#[last (v:-1_value x)0;::]}; / get fn frame
gif:{fr::@[gf x;3 5 7;:;(z;y,(::);1+z 7)];pc::();sTop::8}; / get inited fn frame (set parent)

tm:0D00:05; / timeout
e:10000; / error count
na:0b; / 1=native execution
noDbg:1b; / do not stop in dbg funcs (adverbs and etc)
skpns:`q`h`o`Q; / ignore this ns

/ exec fns,  states: 0 - stopped; 1 - exception; 2 - brk point; 5 - running; 6 - exc block
i0:{gif .$[100=type x;(x;(),y);({x . y};(x;(),y))],(::);gt 1}; / set initial frame
i:{i0[x;y];prs[]};
s0:{if[fr 2;fr[2]:5;@[{if[tm<.z.P-sT;'"Dbg timeout"];i:fr 7;v:x[1]x 2;if[i=fr 7;fr[x 0]:v];if[(0<fr 1)&count x 0;sTop::x 0];gt 1};cc[];excp]]}; / run 1 instruction
r:{i0[x;y];cont[]}; / run until stop/exc/brk
s:{senv[];s0[];prs[]}; / one step
cont:{senv[];{4<fr 2}s0/0;prs[]}; / continue
l:{senv[];{(4<fr 2)&(pc::cc 0;(noDbg&ns=(value fr[6;0])[3;0])|not()~pc)1}s0/0;prs[]}; / next line TODO: ignore some fns
nxt:{if[`ret~last cc[];:l[]];senv[];{y;(4<fr 2)&(pc::$[x=fr 7;cc 0;0];not(0<fr 1)&()~pc)1}[fr 7]s0/0;prs[]}; / next line over
ef:{senv[];{y;(4<fr 2)&not (x=fr 7)&`ret~last cc[]}[fr 7]s0/0;l[];prs[]}; / end function
nexp:{s[];{z;(4<fr 2)&not (x=fr 7)&fr[1]in y}[fr 7;distinct first each value txt0 fr]s0/0;prs[]};
/ stack/state
prs:{$[s:fr 2;out[](("";"Exception: ",fr 4;"Breakpoint";"";"";"Running") s;"Top of the stack:"),pstk[10],enlist"Current line: ",txt fr;fr 4]}; / print state
pstk:{reverse x sublist((" fr[",/:string[n],\:"]: "),'.Q.s1 each fr n:sTop-til sTop-7),1_ " Fn call, line: ",/:txt each {x 3}\[{not(::)~x 3};fr]}; / get N stack entries
psn:{out[]pstk x}; / print N stack entries
ps:{psn 10}; / print 10 stack entries
pl:{out[]txt fr}; / print current line
f:{out[]fr[6;0]}; / print current function

/ map from code to txt
tfs:(!). 2#2(,:)/(::); / processed fns
taj:{r:@[x;(-1+count x),where prev 0{$[x;0b;y in 0x05060809]}\x:first value x;:;0x00];r[where r>=0x80]:0xa0;r}; / adjust volatile code
tfl:{$["["~y 1;x sv(0,1+y?"]")_y;"{",x,1_y]}; / insert fake locals
tcmp:{$[(>).(j:count[x]-sum prds reverse[y]=count[y]#reverse x),i:sum prds y=count[y]#x;i+til j-i;0#0]}; / compare two preprocessed samples
tfc:{(union). tcmp[taj x]each(2+2*count raze value[x]1 2)_/:taj each value each y}; / find code range
tgm:{p&2>sums(0^("{}"!1 -1)x)*p:not 0(1 0 0;0 2 1;1 1 1)\"\"\\"?x}; / get mask, exclude {...} and "..."
tlvl:{r:prev[0;a]&a:sums y*0^("[()]"!1 1 -1 -1)x;$["["~x 1;@[r;til 1+x?"]";:;-1];r]}; / get levels
tspl:{(where 1<deltas[-2;i])_i:(where x<=y)except(0,-1+count y),where z&x=y}; / split by level
tsmp:{tfl[(":"sv reverse string raze value[x]1 2),":0; "]each@[@[string x;y;:;" "];first y;:;]each"01"}; / prepare a pair of samples
tget:{tmin[x]reverse{$[c:count r:.[tfc;(x;tsmp[x;y]);()];r!c#enlist ttrm[x;y];()!()]}[x]each i:raze tspl[;s;m&";"=f]each desc(distinct s:tlvl[f;m:tgm f:string x])except -1}; / get txt ids for all bytecode
tmin:{r:(til[c]!(c:count f:first v)#enlist til count last v:value x){x,inter'[(key y)#x;y]}/y;r[i]:r 0|-1+i:where f in "x"$til 10;r}; / get the minimal txt range
ttrm:{(neg sum prds reverse m)_(sum prds m:(string x)[y]in " \n\t\r")_y}; / trim the txt ranges
txt0:{if[(::)~tfs f:x[6;0]; tfs[f]:tget f]; tfs[f]}; / return exp idx
txt:{string[x[6;0]]txt0[x]x 1}; / cmd line version
