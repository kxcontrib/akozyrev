/ unique mixing
.oo.class[`mx.unique;();enlist (`;`.unique;{[TH;k] if[100<count TH k; @[@[;k;`u#];TH;0]];})];

/ Universal dictionaries.
.oo.class[`dt.dict;`mx.unique]
 ((`key;());(`value;());
  (`getKey;{x});
  (`;`dt.dict;.oo.defgen {[th]},{[th;k] this[`key;enlist th[`getKey]k]; th[`value;enlist (::)]});
  (`;`.key;{[TH;k] $[count[ks]=v:(ks:TH[`key])?k;0N;v]});
  (`;`hasKey;{[th;k] th[`.key;th[`getKey]k]});
  (`;`upsert;{[th;k;v] o:.oo.getTHIS th; $[null i:th[`.key;k:th[`getKey]k];[@[o;`value`key;,;(v;k)]; th[`.unique;`key]];.[o;(`value;i);:;v]]; th});
  (`;`insert;{[th;k;v] o:.oo.getTHIS th; if[not null i:th[`.key;k:th[`getKey]k];'unique]; @[o;`value`key;,;(enlist v;enlist k)]; th[`.unique;`key]; th});
  (`;`get;{[th;k] if[null i:th[`hasKey;k];'nexist]; th[`value] i});
  (`;`peek;{[th;k;v] if[null i:th[`hasKey;k]; :v]; th[`value] i});
  (`;`delete;{[th;k] if[null i:th[`hasKey;k]; :th]; th[`key;th[`key]_i]; th[`value;th[`value]_i]; th[`.unique;`key]; th}));

/ .z.* handlers
.oo.class[`z.handler;()]
 ((`..abstract;1);
  (`.hStatus;`off);(`.hName;`undef);
  (`;`.hInitFn;{[old] old});
  (`;`start;{[th] if[`on=s:th`.hStatus; :()]; if[`off=s; n set th[`.hInitFn] @[get;n:th`.hName;{}]; th[`.hStatus;`on]]});
  (`;`stop;{[th] th[`.hStatus;`stopped]}));

/ file src args
.oo.class[`z.handler.ph;`z.handler]
 ((`.hName;`.z.ph);(`Handlers;.oo.defmeth[{[f;b;c] 'not_inited};`any`any`any]);(`getId;{`unknown});
  (`.process;{$[`on=x`.hStatus; .[x[`Handlers];x[`.prepReq;z 0;z 1];{.h.he "Unexpected error: ",x}];y z]});
  (`;`.hInitFn;{[th;old] th[`addHandler;`default;{[o;f;b;c] if[("/"=last f)|0=count f:string f; f,:"index.html"]; o (f;"")}old;`any`any`any]; th[`.process][th;old]});
  (`;`.prepReq;{[th;x;y](d`file;d`id;d:(`file`id`query!(`$.h.uh c#x;th[`getId]p;(x;y))),p:.h.uh each(!).@[;0;`$]flip{2#x,enlist""}each"="vs/:"&"vs(1+c:count[x]^x?"?")_x)});
  (`;`addHandler;.oo.defgen {[th;f;a] th[`addHandler;`default;f;a]},{[th;asp;fn;arg] th[`Handlers;.oo.defmeth[th`Handlers;asp;fn;arg]]});
  (`;`removeHandler;{[th;arg] th[`Handlers;.oo.defmeth[th`Handlers;::;arg]]}));

/ @class Cron () Cron manager.
/ This class can be used to execute cron jobs via .z.ts timer. It adds it own handler to .z.ts and calls the previous handler so several crons can be used. Usage:
/ @example .cron.cron:.oo.new[`cron];
/ @example .cron.cron:.oo.new[`cron][`interval;1000]`start;
/ @field Jobs table Contains jobs that are scheduled for execution.
/ @field Status table Contains return values of all executed jobs. Gets cleared regularly.
/ @field interval timespan Timer setting in millis. It gets applied only when `start is called and \t is not set.
/ @field .status symbol Internal state - off, on or stopped.
/ @method cron Initializes the new cron object. It also adds a job to itself to clear its Status table.
/ @method add Adds a new job to cron. Usually it is called by the job itself.
/ @param job cron.job A job to be added.
/ @returns cron Returns cron itself.
/ @method .upd Updates the internal job table.
/ @method delete Deletes a job from cron. Usually it is called by the job itself.
/ @param job cron.job Job to be deleted.
/ @returns cron Returns cron itself.
/ @method start Starts cron. Adds a handler to .z.ts and sets \t if neccessary.
/ @returns cron Returns cron itself.
/ @method stop Stops cron. The handler is not deleted from .z.ts and timer is not stopped.
/ @returns cron Returns cron itself.
/ @method run1 Runs one job that can be run at this time. 
/ @returns cron Returns cron itself.
.oo.class[`cron;()]
 ((`Jobs;([id:`$()] name:`$(); nxt:"p"$(); job:()));
  (`Status;([] name:"s"$(); sTime:"p"$(); time:"n"$(); rval:()));
  (`interval;100);(`.status;`off);
  (`;`cron;{[th] .oo.new[`cron.job.periodic;th;`cron.clear.status;{[t] th[`Status;0#th`Status]}][`args;th][`interval;1D][`sTime;0D12+"p"$.z.D+1]`start});
  (`;`add;{[th;job] th[`.upd;job;job[`next;0np]]});
  (`;`.upd;{[th;job;nxt] t:th`Jobs;t[.oo.getId job]:(job`Name;nxt;job); th[`Jobs;t]});
  (`;`delete;{[th;jb] th[`Jobs;delete from th[`Jobs] where id=.oo.getId jb]});
  (`;`start;{[th] if[`on=s:th`.status; :()]; if[`off=s; .z.ts:{[t;old;v] t`run1; old v}[th;@[get;`.z.ts;{::}]]]; if[0=system "t"; system "t ",string th`interval]; th[`.status;`on]});
  (`;`stop;{[th] th[`.status;`stopped]});
  (`;`reschedule;{[th;jb;tm] th[`Jobs;update nxt:{$[-12=type x;x;x+y]}[tm] each nxt from th[`Jobs] where id=.oo.getId jb]});
  (`;`run1;{[th] if[not `on=th`.status; :th`this];
                  if[null (j:exec from th[`Jobs] where nxt<=.z.P, not null nxt, i=min i)`nxt; :()]; st:.z.P; v:@[jj:j`job;`run;{x}]; th[`Status;th[`Status],`name`sTime`time`rval!(j`name;st;.z.P-st;v)];
                  $[null n:jj[`next;.z.P];th[`delete;jj];th[`.upd;jj;n]]}));

/ @class cron.job () Abstract cron job.
/ Can be used to create classes for cron jobs. Job is run via run method from sTime to eTime with interval.
/ @prop abstract
/ @field Name symbol Name of the job.
/ @field sTime timestamp Start time.
/ @field eTime timestamp End time.
/ @field interval timespan Interval between runs.
/ @field .cron cron Cron object that manages this job.
/ @field Status symbol Job's status: on or off.
/ @field Lastval any Last value.
/ @method cron.job Creates a new cron job.
/ @param cron cron Cron object.
/ @param name symbol Job's name.
/ @method start Starts the job, adds it to cron.
/ @returns cron.job Returns the object itself.
/ @method stop Stops the job, removes it from cron.
/ @returns cron.job Returns the object itself.
/ @method next Returns the next time when the job has to be executed.
/ @param prv timestamp The last time when the job was executed. Null if there is no one.
/ @returns timestamp Time when the job has to be run.
/ @method run Abstract. Should execute the job and return its value.
.oo.class[`cron.job;()]
 ((`..abstract;1);
  (`Name;`none);
  (`sTime;-0wp);(`eTime;0wp);(`interval;0D01);
  (`.cron;`undef);(`Status;`off);(`Lastval;::);
  (`;`cron.job;.oo.setcnstr`.cron`Name);
  (`;`start;{[th] if[`off=th`Status; if[-16=type t:th`sTime; th[`sTime;.z.P+t]]; if[-16=type t:th`eTime; th[`eTime;.z.P+t]]; th[`.cron][`add;th[`Status;`on]]]; th`this});
  (`;`stop;{[th] th[`.cron][`delete;th[`Status;`off]]; th`this});
  (`;`next;{[TH;prv] if[`off=TH`Status; :0np]; $[null prv;min(max(TH`sTime;.z.P);TH`eTime);null TH`interval;0np;prv=TH`eTime;0np;min(.z.P+TH`interval;TH`eTime)]});
  (`;`run;{[th] }));

/ @class cron.job.periodic cron.job Periodic cron job.
/ Can be used to execute some function periodically.
/ @example .oo.new[`cron.job.periodic;.cron.cron;`MyJob;.job.func][`sTime;.z.P+0D01][`interval;2000][`args;1 2 3]`start
/ @field args any Args for the job.
/ @field fn func Function to be executed.
/ @method run Executes fn with args from sTime to eTime with interval, returns its value. Exceptions are recorded but ignored.
.oo.class[`cron.job.periodic;`cron.job]
 ((`args;::);(`fn;{[]});
  (`;`cron.job.periodic;.oo.setcnstr`.cron`Name`fn);
  (`;`run;{[th] th[`Lastval;v:.[th`fn;(),th`args;{"Failed with: ",x}]]; v}));

/ @class cron.job.untilSucc cron.job.periodic Like the periodic job but stops when fn returns 1b.
.oo.class[`cron.job.untilSucc;`cron.job.periodic]
 enlist (`;`run;{[th] th[`Lastval;v:.[{[t;a] v:th[`fn]. a; if[1b~v;th`stop]; v}th;(),th`args;{"Failed with: ",y}]]; v});

/ @class cron.job.untilFail cron.job.periodic Like the periodic job but stops when fn returns 0b or an exception.
.oo.class[`cron.job.untilFail;`cron.job.periodic]
 enlist (`;`run;{[th] th[`Lastval;v:.[th`fn;(),th`args;{[t;m] t`stop; "Failed with: ",m}[th]]]; if[v~0b;th[`stop]]; v});

/ @class cron.job.once cron.job.periodic Runs the job exactly one time.
.oo.class[`cron.job.once;`cron.job.periodic]
 ((`;`cron.job.once;.oo.setcnstr`.cron`Name`fn`args`sTime);
  (`;`run;{[th] v:th`cron.job.periodic:run; th`stop; v}));

/ @class dt.lazyTree Tree that updates itself on demand.
/ Can be used to map filesystems or Q namespaces. Requires functions to load data, filter it, create new leaves and nodes.
/ @prop abstract
/ @field .nodes object List of objects created for Nodes.
/ @field Nodes any Raw list of nodes.
/ @field .leaves object List of objects created for Leaves.
/ @field Leaves Raw list of leaves.
/ @field State any State from which nodes and leaves are calculated.
/ @field .ready long Controls wether nodes and leaves are calculated or not.
/ @field lazy long If equals to 1 then calculation of leaves and nodes will be done on demand.
/ @field filter func Can be used to filter nodes and leaves. Format: (State;Nodes;Leaves) -> (Nodes;Leaves).
/ @method dt.lazyTree Accepts up to 3 arguments. If lazy is 0 then loads all leaves and nodes.
/ @param state any State.
/ @param lazy long Lazy or not.
/ @param filter func Filter function.
/ @returns dt.lazyTree
/ @method .getx Internal method that creates nodes and leaves on demand.
/ @method getLeaves Get leaves objects by indecies. Calculate leaves and objects if needed.
/ @param idx (long|symbol|long list|symbol list) Indecies - numbers or symbols.
/ @returns (object|object list) Leaves as objects.
/ @method getNodes Get nodes objects by indecies. Calculate nodes and objects if needed.
/ @param idx (long|symbol|long list|symbol list) Indecies - numbers or symbols.
/ @returns (object|object list) Nodes as objects.
/ @method Leaves Overwrites the default set/get. Loads leaves and nodes if neccessary.
/ @returns (this|any) On set returns the object itself. On get returns Leaves.
/ @method Nodes Overwrites the default set/get. Loads leaves and nodes if neccessary.
/ @returns (this|any) On set returns the object itself. On get returns Nodes.
/ @method .get This method is used to load leaves and nodes. Should be redefined.
/ @method .newLeaf It is used to create new leaf objects.
/ @param idx (long list) Indecies into Leaves to be created.
/ @returns (object list) New leaf objects.
/ @method .newNode It is used to create new node objects.
/ @param idx (long list) Indecies into nodes to be created.
/ @returns (object list) New node objects.
/ @method load Loads nodes and leaves using .get and filter.
/ @method cd Can be used to navigate the tree.
/ @param path list List of nodes to traverse starting from the current node. It also accepts a leaf at the end.
.oo.class[`dt.lazyTree;()]
 ((`..abstract;1);
  (`.nodes;());(`Nodes;());(`.leaves;());(`Leaves;());(`State;::);
  (`.ready;0);
  (`lazy;1);(`filter;{[s;n;l] :(n;l)});
  (`;`dt.lazyTree;.oo.setgcnstr[`State`lazy`filter;{[a] if[0=a[0]`lazy; (.oo.getThis a 0)`load]}]);
  (`;`.getx;{[th;idx;f1;f2;fn] if[0=th`.ready; th`load]; if[11=type i:(),idx; i:(),idx:th[f1]?idx]; v:th[fn;i:i where null th[f2] i]; if[count i; .[.oo.getTHIS th;(f2;i);:;v]]; th[f2] idx});
  (`;`getLeaves;{[th;idx] th[`.getx;idx;`Leaves;`.leaves;`.newLeaf]});
  (`;`getNodes;{[th;idx] th[`.getx;idx;`Nodes;`.nodes;`.newNode]});
  (`;`Leaves;.oo.defgen[{[TH] if[0=TH`.ready; (.oo.getThis TH)`load]; TH`Leaves},.oo.setf[;`Leaves;:];1 2]);
  (`;`Nodes;.oo.defgen[{[TH] if[0=TH`.ready; (.oo.getThis TH)`load]; TH`Nodes},.oo.setf[;`Nodes;:];1 2]);
  (`;`.get;{});
  (`;`.newLeaf;{[TH;idx] 'undefined});
  (`;`.newNode;{[TH;idx] .oo.new'[TH`.class;TH[`State],/:enlist each TH[`Nodes] idx;TH`lazy;TH`filter]});
  (`;`load;{[th] if[th`.ready;:()]; th'[`Leaves`Nodes;v:th[`filter][th`State;]. th[`.get]]; th'[`.leaves`.nodes;(count each v)#\:(::)]; th[`.ready;1]});
  (`;`cd;{[th;path] $[0=c:count path; th`this; (p:path 0) in th`Leaves; $[1=c;th[`getLeaves;p];'p]; p in th`Nodes; th[`getNodes;p][`cd;1_ path];'p]}));

/ @class dt.fsTree dt.lazyTree Filesystem lazy tree.
/ This class can be used to map a filesytem or some directory onto objects.
/ @field Path symbol Path associated with this object.
/ @method dt.fsTree Accepts two or three args - State, filter and lazy. Loads all dirs and files if not lazy.
/ @method files Redirects to Leaves.
/ @method nodes Redirects to Nodes.
/ @method getFiles Redirects to getLeaves.
/ @method getDirs Redirects to getNodes.
/ @method .get Scans Path and loads files and dirs.
/ @method cd Based on the parent's cd but tuned for filesystem paths.
/ @param pat (symbol|symbol list) Symbol paths (without : at the start) are accepted.
.oo.class[`dt.fsTree;`dt.lazyTree]
 ((`Path;`);(`QPath;`);
  (`:getDrives;{`$"/"});(`:logDrives;()!`$());
  (`;`dt.fsTree;.oo.defgen {[th;p] th[`dt.fsTree;p;th`lazy;th`filter]},{[th;p;l;f] th[`dt.lazyTree;(),p;l;f]; th[`Path`QPath;] $[1=count p;2#p;{hsym`$$[(`$"/")~first x:"/"sv x;1_ x;x]}each string(p 1;p[1]^th[`:logDrives]p 1),\:2_ p]});
  (`;`files;{[th] th`Leaves});
  (`;`dirs;{[th] th`Nodes});
  (`;`getFiles;{[th;ids] th[`getLeaves;ids]});
  (`;`getDirs;{[th;ids] th[`getNodes;ids]});
  (`;`.get;{[th] value n#(n!()),k group{x -11<>type @[key;` sv y,z;()]}[n:`Leaves`Nodes;p] each k:@[{$[y=`;(key x`:logDrives),x[`:getDrives][];key y]}[th];p:th`QPath;()] except `});
  (`;`cd;{[th;path] path:$[`~path;();(`$"/")~path;enlist path;-11=type path; path:$["/"=first p;(`$"/"),1_;::]`$"/" vs p:string path;path]; if[`.~p:path 0; :th[`cd;1_ path]]; th[`dt.lazyTree:cd;path]}));

/ @class dt.nsTree dt.lazyTree Namespace lazy tree.
/ This class can be used to map a namespace onto objects.
/ @field Path symbol Path associated with this object.
/ @method dt.nsTree Accepts two or three args - State, filter and lazy. Loads all namespaces and variables if not lazy.
/ @method varss Redirects to Leaves.
/ @method nss Redirects to Nodes.
/ @method getVars Redirects to getLeaves.
/ @method getNss Redirects to getNodes.
/ @method .get Scans Path and loads vars and nss.
/ @method cd Based on the parent's cd but tuned for namespace paths.
/ @param pat (symbol|symbol list) Symbol paths (without : at the start) are accepted.
.oo.class[`dt.nsTree;`dt.lazyTree]
 ((`Path;`);
  (`;`dt.nsTree;.oo.defgen {[th;p] th[`dt.nsTree;p;th`lazy;th`filter]},{[th;p;f;l] th[`dt.lazyTree;(),p;f;l]; th[`Path;` sv (),$[p~``.;1_p;p]]});
  (`;`vars;{[th] th`Leaves});
  (`;`nss;{[th] th`Nodes});
  (`;`getVars;{[th;ids] th[`getLeaves;ids]});
  (`;`getNss;{[th;ids] th[`getNodes;ids]});
  (`;`.get;{[TH] k:@[key;p:TH`Path;()]; if[p~`; k,:`.]; value n#(n!()),k group(n:`Leaves`Nodes){if[x~`;:1]; if[99=type v:x y;if[11=type key v;if[` in key v;:1]]]; 0}[p] each k});
  (`;`cd;{[th;path] if[-11=type path; path:$[path=`.;{(),`.};path like ".*";1_;$[`~th`Path;`.,;::]]` vs path]; $[0=count p:path; th`this; th[`dt.lazyTree:cd;path]]}));


.oo.class[`sys.file;()]
 ((`Name;::);(`Path;::);(`QPath;::);(`Ext;::);(`type;::);(`Data;());(`cacheTime;0Nn);(`cron;`);
  (`Status;"");(`.cronId;`);
  (`;`sys.file;{[th;p]; th[`QPath;p:hsym p]; v:` vs p; th[`Path;`$1_string v 0]; th[`Name;v 1]; th[`Ext;d:`$(count[d]^last 1+where "."=d)_d:string v 1]; th[`type;d]});
  (`;`.get;{[th;op] if[not()~d:th`Data; if[not null c:th`.cronId; th[`cron][`reschedule;c;th`cacheTime]]; :d]; th[`Status;""]; d:@[op;th`QPath;{x[`Status;y];()}th]; if[""~th`Status; th[`.initCache;d]]; d});
  (`;`.set;{[th;op;d] if[not d~th`Data; th`purge; th[`.set;{y;x}d]]; .[op;(th`QPath;d);{x[`Status;y]}th]; th`Status});
  (`;`.initCache;{[th;d] if[null ct:th`cacheTime; :()]; th[`Data;d]; if[(ct~0Wn)|null cr:th`cron; :()]; th[`.cronId;] .oo.getId .oo.new[`cron.job.once;cr;`fileCacheJob;{V::x; x`purge};th;ct]`start});
  (`;`read;{[th] d:th[`.get;read0]; $[()~d;d;all 10=type each d;d;4=type d;"c"$d;'type]});
  (`;`get;{[th] th[`.get;get]});
  (`;`load;{[th] d:th[`.get;read1]; $[()~d;d;4=t:type d;d;10=t;"x"$d;[th`purge;th[`.get;read1]]]});
  (`;`purge;{[th] th[`Data;()]; th[`Status;""]; if[not null cr:th`.cronId; th[`cron][`delete;cr]; th[`.cronId;`]]});
  (`;`set;{[th;d] th[`.set;set;d]});
  (`;`write;{[th;d] th[`.set;{x 0: $[10=type y;enlist y;y]};d]});
  (`;`save;{[th;d] th[`.set;1:;d]}));



.oo.class[`sys.editSession;()]
  ((`content;());(`file;::);(`cache;::);(`type;`);(`name;`);(`host;`);(`dirty;0);
   (`.adjd;{update `$action, "j"$sX, "j"$sY, "j"$eX, "j"$eY from x});
   (`;`.appd;{[th;x;y] idx:{[l;i] 0^(where not l within (128;191)) i};
            sy:y`sY;sx:idx[l:x sy;y`sX];ey:y`eY;ex:idx[x ey;y`eX];
            $[`insertText=a:y`action; $[sy=ey;x[sy]:(sx#l),y[`text],sx _l;x:(sy#x),(sx#l;sx _l),(1+sy) _x];`insertLines=a;x:(sy#x),y[`lines],sy _x;
            `removeText=a;$[sy=ey;x[sy]:(sx#l),ex _l;x:(sy#x),enlist[l,x ey],(1+ey) _x];`removeLines=a;x:(sy#x),ey _x;`save=a;();'a];x});
   (`;`sys.editSession;{[th;f] fn:`$(1+i:first p?":")_p:string f; if[not (h:`$i#p) in .qute.cfg.host,`;'"unexpected host"]; th[`name`host;fn,h]; $[h<>`;th[`file;.oo.new[`sys.file;fn]]; th[`content;enlist ""]]});
   (`;`getPath;{[th] if[null f:th`file; :`]; f`QPath});
   (`;`getName;{[th] if[null f:th`file; :th`name]; f`Name});
   (`;`getType;{[th] if[null f:th`file; :th`type]; f`type});
   (`;`getContent;{[th] if[not()~c:th`content;:c]; if[null f:th`file; '"no_file_no_data"]; th[`content;f`read]; if[count e:f`Status; 'e]; th`content});
   (`;`applyDeltas;{[th;d] th[`dirty;2]; th[`content;th[`.appd;;]/[th`content;th[`.adjd] d]]});
   (`;`save;{[th] th[`file][`write;th`content]; th[`dirty;0]}));

