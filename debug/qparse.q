/ lexer
/ classes: wspace, \n, special syms, A-z, 0-9, . , `, :, _ , " , /, \ 
.qparse.w0:@[128#2;.qparse.w;:;til count .qparse.w:`int$("\t \r";"\n";"{}";.Q.a,.Q.A;.Q.n;"eE"),".-+`'<>=:_/\\\""];

.qparse.wm: ("a A ae0._"; "A A ae0._"; "e A ae0._"; / identifiers + numbers + datetime vals
             "0 N a0.:"; "0 B :"; "N N a0.:"; "0 E e"; "N E e"; "E E e"; "E N +-a0.:"; / + and - in float only after e/E
             ". A ae"; ". N 0"; / dispatch . to number/identifier
             "< B ="; "> B ="; / <= >=
             "` S ae0.:"; "S S ae0.:_"; / symbols
             ": B :"; / : or ::
             "/ B :"; "\\ B :"; "' B :"; / adverbs
             "\" C *";"\" Z \"";"\" Y \\";"C C *";"C Z \"";"C Y \\";"Y C *"; / strings
             "\t W \t"; "W W \t"; / merge whitespace
             "\n o /"; "\t p /"; "W p /"; "\n r \\"; / begin comment: O - comment, P - til \n, Q - til \\n, R - til EOF, T - expect \n
             "o P *"; "o Q \n"; "p P *"; "p \n \n"; "P P *"; "P \n \n"; "Q Q *"; "Q T \\"; "r R *"; "R R *"; "T Q *"; "T \n \n"); / continue comments

.qparse.extStates:"opr";
.qparse.states:{(`char$first each .qparse.w),distinct .qparse.extStates,m where (m:raze .qparse.wm) in .Q.A}[];
.qparse.w1:{.[;;:;]/[(c;c:count s)#s?s;m[;0],'enlist each 4_'m;(m:s?ssr[;"*";s:.qparse.states] each .qparse.wm)[;2]]}[];

.qparse.w:{flip `state`token!(.qparse.states first each i _s;(i _x)@ where -1<s i:where (count distinct .qparse.w0,.qparse.extStates)>s:.qparse.w1\[1;.qparse.w0 x])};

.qparse.off:{(sums c)-c:count each x}; / offset in file
.qparse.xy:{[xy;tkn] (xy[0]+c-1;(count last l)+xy[1]*(1=c:count l:"\n" vs tkn))}; / token coordinates enlist[(0;0)],-1_ .qparse.xy\[(0;0);t2`token]

.qparse.keywords:`abs`aj`aj0`acos`all`and`any`asc`asin`asof`atan`attr`avg`avgs`bin`ceiling`cols`cor`cos`count`cov`cross`cut;
.qparse.keywords,:`delete`deltas`desc`dev`differ`distinct`div`do`each`ej`enlist`eval`except`exec`exit`exp`fby`fills`first`flip`floor`fkeys;
.qparse.keywords,:`get`getenv`group`gtime`hclose`hcount`hdel`hopen`hsym`iasc`idesc`if`ij`in`insert`inter`inv`key`keys;
.qparse.keywords,:`last`like`lj`load`log`lower`lsq`ltime`ltrim`mavg`max`maxs`mcount`md5`mdev`med`meta`min`mins`mmax`mmin`mmu`mod`msum;
.qparse.keywords,:`neg`next`not`null`or`over`parse`peach`pj`plist`prd`prds`prev`prior`rand`rank`ratios`raze`read0`read1`reciprocal;
.qparse.keywords,:`reverse`rload`rotate`rsave`rtrim`save`scan`select`set`setenv`show`signum`sin`sqrt`ss`ssr`string`sublist`sum`sums`sv`system;
.qparse.keywords,:`tables`tan`til`trim`txf`type`uj`ungroup`union`update`upper`upsert`value`var`view`views`vs`wavg`where`while`within`wj`wj1`wsum;
.qparse.keywords,:`xasc`xbar`xcol`xcols`xdesc`xexp`xgroup`xkey`xlog`xprev`xrank;

.qparse.zwords:`$".z.",/:("exit";"pc";"ph";"po";"ps";"ts";"vs";"zd";"ac";"bm";"pg";"pi";"pp";"pw"),"abchklNpqWztTdDfiKnoPsuwxZ";
.qparse.qwords:`$".Q.",/:("addmonth";"addr";"host";"chk";"cn";"dd";"dpft";"dsftg";"def";"en";"fc";"fk";"fmt";"fs";"ft";"fu";"gc";"hdpft";"ind";"j10";"x10";"j12";"x12";"k";"l";"opt";"par";"qt";"s";"ty";"v";"V";"view";"w";"M";"pf";"pt";"PD";"PV";"pd";"pv";"pn";"P";"D";"u");

/ not all errors are detected!
.qparse.parseNum:{[tk]
  if[(2=count tk)&tk[1]=":"; :`io];
  if["b"=t:last tk;:$[all (-1_tk)in "01";`value:number:boolean;`value:number:error]]; / bool
  if["0x"~2#tk;:$[all (2_tk) in .Q.n,"ABCDEFabcdef";`value:number:byte;`value:number:error]]; / byte
  if[(tk[0]="0")&tk[1] in "WwNn";
    $[tk~"0N";:`value:null:int;tk~"0n";:`value:null:float;tk~"0W";:`value:inf:int;tk~"0w";:`value:inf:float;()];
    if[(3=count tk)&t in "hjemdzuvtpnf"; :("hjemdzuvtpnf"!`$("value:",$[tk[1] in "Nn";"null:";"inf:"]),/:("short";"long";"real";"month";"date";"datetime";"minute";"second";"time";"timestamp";"timespan";"float")) t];
    :`value:null:error;
  ];
  if[t in "hji";:$[all (-1_tk)in .Q.n;$[t="h";`value:number:short;t="j";`value:number:long;`value:number:int];`value:number:error]]; / short&long&int
  if[t in "dmznpuvt"; :("dmznpuvt"!`$"value:time:",/:("date";"month";"datetime";"timespan";"timestamp";"minute";"second";"time")) t]; / explicit time
  if[all tk[4 7]=".";
    if[10=count tk; :`value:time:date];
    if[tk[10]="T"; :`value:time:datetime];
    if[tk[10]="D"; :`value:time:timestamp];
    : `value:time:error;
  ];
  if[tk[2]=":";
    if[5=count tk; :`value:time:minute];
    if[8=count tk; :`value:time:second];
    if[9<count tk; :`value:time:time];
    : `value:time:error;
  ];
  if[all tk in .Q.n; :`value:number:int];
  if["D" in tk; :`value:time:timespan];
  if[2>sum tk=".";:$[t="e"; `value:number:real; `value:number:float]];
  : `value:number:unknown;
 };

.qparse.vMap:(.qparse.states!count[.qparse.states]#{`unknown}),(!). flip
 (("\n";{`newline});
  ("o";{$["\n"~x 1;`comment:multiline;`comment:line]});
  ("p";{`comment:line});
  ("\t";{`ws});
  ("`";{`value:symbol});
  ("{";{("{}[]();,@~$#*%&!?|^"!`sym:lcb`sym:rcb`sym:lsb`sym:rsb`sym:lp`rp`sym:dotcomma`sym:comma`sym:at`sym:eqv`sym:cast`sym:take`sym:mult`sym:div`sym:and`sym:dict`sym:find`sym:or`sym:fill) first x});
  ("'";{`sym:each});("_";{`sym:drop});("+";{`sym:plus});("=";{`sym:eq});("-";{`sym:minus});
  ("<";{$[x~"<=";`sym:lesseq;`sym:less]});
  (">";{$[x~">=";`sym:greatereq;`sym:greater]});
  ("/";{$[x~"/:";`sym:eachright;`sym:over]});
  ("\\";{$[x~"\\:";`sym:eachleft;`sym:scan]});
  (":";{$["::"~x;`sym:gamend;`sym:amend]});
  ("\"";{$[3=count x;`value:char;`value:string]});
  ("a";{$[max {(x=".")&y="."}':[x];`var:error;$[(s:`$x)in .qparse.keywords;`var:keyword;s in .qparse.zwords;`var:zword;s in .qparse.qwords;`var:qword;"."=first x;`var:global;`var:simple]]});
  ("0";.qparse.parseNum);
  (".";{$[1=count x;`sym:dot;x[1] in .Q.A,.Q.a;.qparse.vMap["a"] x;x[1] in .Q.n;.qparse.parseNum[x];`unknown]});
  ("r";{`comment:eof}));

.qparse.vMap["e"]:.qparse.vMap["a"];

.qparse.tType:{update tType:.qparse.vMap[state]@'token from x};

.qparse.qPadSchema:"comment=#808080,value:string=#14c800,value:boolean=#33ccff,value:symbol=#b30086,*:error=#ff0000,*unknown=#ff0000,var:keyword=#0000ff,var:zword=#f0b400,var:qword=#f0b400,var=#b4a000,value=#3368ff,=#000000,background=#FFFFFF";
.qparse.vimSchema:"comment=#c00000,value:string=#c000c0,value:boolean=#c000c0,value:symbol=#808000,*:error=#ff0000,*unknown=#ff0000,var:keyword=#808000,var:zword=#008000,var:qword=#008000,var:simple=#008080,var=#c0c0c0,value=#c000c0,=#ffffff,background=#000000";
.qparse.htmlColor:{[cmap;t]
  m:((first m),\:"*")!("<span style=\"color: ",/:last m:flip "=" vs' "," vs cmap),\:"\">";
  bc:-7#18#(first ss[cmap;"background="])_ cmap;
  t:update token:ssr/[;"&<> \t";("&amp;";"&lt;";"&gt;";"&nbsp;";"&nbsp;")] each token, color:{[m;t] value[m] first where t like/: key m}[m] each tType from t;
  d:{[d;r]
    s:$[d[`color]~"";"";"</span>"];
    if["\n"=first t:r[`token]; :`color`html!("";d[`html],s,"<br>\n")]; / reset on enter
    if[r[`tType]=`ws; d[`html],:t; :d]; / skip ws
    if[not d[`color]~r[`color];d:`color`html!(r[`color];d[`html],s,r[`color])];
    if[r[`tType] in `comment:multiline`value:string;
      d[`html],:(("</span><br>\n",r[`color]) sv "\n" vs t);
      d[`color]:r[`color];
      :d;
    ];
    d[`html],:t; :d;
  }/[`color`html!("";"<div style=\"background-color:",bc,";margin-top:0in;margin-right:0in;margin-bottom:0in;margin-left:0in;margin-bottom:0in;line-height:normal;text-autospace:none;font-size: 8pt; font-family: Consolas; white-space: nowrap;\">");t];
  : d[`html],$[d[`color]~"";"";"</span>"],"</div>";
 };

.qparse.htmlDbgColor:{[t]
  t:update token:ssr/[;"&<> \t";("&amp;";"&lt;";"&gt;";"&nbsp;";"&nbsp;")] each token, tType:{`$ssr[string x;":";"_"]} each tType from t;
  :{[h;r]
    if["\n"=first t:r[`token];: h,"<br>"];
    if[r[`tType]=`ws; : h,t];
    if[r[`tType] in `comment:multiline`value:string; : h,"<div class=\"",string[r`tType],"\">",(("<br>") sv "\n" vs t),"</div>"];
    : h,"<span class=\"",string[r`tType],"\">",t,"</span>";
    }/["";t];
 };

.qparse.qToHtml:{[schema;file] -1 .qparse.htmlColor[schema;.qparse.tType .qparse.w "\n" sv read0 `$":",string file]; exit 0;};

/ qexpr : assign_exp |
/ assign_exp : var (: ::) qexpr

/ .qparse.pTop:{[t]{$[count x:delete from x where (tType in `ws`newline)|tType like "comment*";.qparse.pExp x;()]} each (0,where {(y=`newline)&not x=`ws}':[t2`tType]) cut t};
