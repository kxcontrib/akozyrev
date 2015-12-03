.oo.class[`z.handler;()]
 ((`..abstract;1);
  (`.hStatus;`off);(`.hName;`undef);
  (`;`.hInitFn;{[old] old});
  (`;`start;{[th] if[`on=s:th`.hStatus; :()]; if[`off=s; n set th[`.hInitFn] @[get;n:th`.hName;{}]; th[`.hStatus;`on]]});
  (`;`stop;{[th] th[`.hStatus;`stopped]}));

/ file src args
.oo.class[`z.handler.ph;`z.handler]
 ((`.hName;`.z.ph);(`Handlers;::);
  (`.process;{$[`on=x`.hStatus; x[`Handlers] . x[`.prepReq;z 0;z 1];y z]});
  (`;`.hInitFn;{[th;old] th[`Handlers;.oo.defmeth[{[o;f;b;c] if[("/"=last f)|0=count f:string f; f,:"index.html"]; o (f;"")}old;`any`any`any]]; th[`.process][th;old]});
  (`;`.prepReq;{(d`file;d`id;d:(`file`id`query!(`$.h.uh c#x;`unknown;(x;y))),.h.uh each(!).@[;0;`$]flip{2#x,enlist""}each"="vs/:"&"vs(1+c:count[x]^x?"?")_x)});
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
  (`;`cron;{[this] .oo.new[`cron.job.periodic;this;`cron.clear.status;{[t] this[`Status;0#this`Status]}][`args;this][`interval;1D][`sTime;0D12+"p"$.z.D+1]`start});
  (`;`add;{[this;job] this[`.upd;job;job[`next;0np]]});
  (`;`.upd;{[this;job;nxt] t:this`Jobs;t[.oo.getId job]:(job`Name;nxt;job); this[`Jobs;t]});
  (`;`delete;{[this;jb] this[`Jobs;delete from this[`Jobs] where id=.oo.getId jb]});
  (`;`start;{[this] if[`on=s:this`.status; :()]; if[`off=s; .z.ts:{[t;old;v] t`run1; old v}[this;@[get;`.z.ts;{::}]]]; if[0=system "t"; system "t ",string this`interval]; this[`.status;`on]});
  (`;`stop;{[this] this[`.status;`stopped]});
  (`;`run1;{[this] if[not `on=this`.status; :this`pthis];
                  if[null (j:exec from this[`Jobs] where nxt<=.z.P, not null nxt, i=min i)`nxt; :()]; st:.z.P; v:@[jj:j`job;`run;{x}]; this[`Status;this[`Status],`name`sTime`time`rval!(j`name;st;.z.P-st;v)];
                  $[null n:jj[`next;.z.P];this[`delete;jj];this[`.upd;jj;n]]}));

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
  (`;`start;{[this] if[`off=this`Status;this[`.cron][`add;this[`Status;`on]]]; this`pthis});
  (`;`stop;{[this] this[`.cron][`delete;this[`Status;`off]]; .oo.getpthis this`pthis});
  (`;`next;{[THIS;prv] $[null prv;min(max(THIS`sTime;.z.P);THIS`eTime);null THIS`interval;0np;prv=THIS`eTime;0np;min(.z.P+THIS`interval;THIS`eTime)]});
  (`;`run;{[this] }));

/ @class cron.job.periodic cron.job Periodic cron job.
/ Can be used to execute some function periodically.
/ @example .oo.new[`cron.job.periodic;.cron.cron;`MyJob;.job.func][`sTime;.z.P+0D01][`interval;2000][`args;1 2 3]`start
/ @field args any Args for the job.
/ @field fn func Function to be executed.
/ @method run Executes fn with args from sTime to eTime with interval, returns its value. Exceptions are recorded but ignored.
.oo.class[`cron.job.periodic;`cron.job]
 ((`args;::);(`fn;{[]});
  (`;`cron.job.periodic;.oo.setcnstr`.cron`Name`fn);
  (`;`run;{[this] this[`Lastval;v:.[this`fn;(),this`args;{"Failed with: ",x}]]; v}));

/ @class cron.job.untilSucc cron.job.periodic Like the periodic job but stops when fn returns 1b.
.oo.class[`cron.job.untilSucc;`cron.job.periodic]
 enlist (`;`run;{[this] this[`Lastval;v:.[{[t;a] v:this[`fn]. a; if[1b~v;this`stop]; v}this;(),this`args;{"Failed with: ",y}]]; v});

/ @class cron.job.untilFail cron.job.periodic Like the periodic job but stops when fn returns 0b or an exception.
.oo.class[`cron.job.untilFail;`cron.job.periodic]
 enlist (`;`run;{[this] this[`Lastval;v:.[this`fn;(),this`args;{[t;m] t`stop; "Failed with: ",m}[this]]]; if[v~0b;this[`stop]]; v});

/ @class cron.job.once cron.job.periodic Runs the job exactly one time.
.oo.class[`cron.job.once;`cron.job.periodic]
 ((`;`cron.job.once;.oo.setcnstr`.cron`name`fn`arg`sTime);
  (`;`run;{[this] v:this`cron.job.periodic:run; this`stop; v}));


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
  (`;`dt.lazyTree;.oo.setgcnstr[`State`lazy`filter;{[a] if[0=a[0]`lazy; (.oo.getpthis a 0)`load]}]);
  (`;`.getx;{[this;idx;f1;f2;fn] if[0=this`.ready; this`load]; if[11=type i:(),idx; i:(),idx:this[f1]?idx]; v:this[fn;i:i where null this[f2] i]; if[count i; .[.oo.getTHIS this;(f2;i);:;v]]; this[f2] idx});
  (`;`getLeaves;{[this;idx] this[`.getx;idx;`Leaves;`.leaves;`.newLeaf]});
  (`;`getNodes;{[this;idx] this[`.getx;idx;`Nodes;`.nodes;`.newNode]});
  (`;`Leaves;.oo.defgen[{[THIS] if[0=THIS`.ready; (.oo.getpthis THIS)`load]; THIS`Leaves},.oo.setf[;`Leaves];1 2]);
  (`;`Nodes;.oo.defgen[{[THIS] if[0=THIS`.ready; (.oo.getpthis THIS)`load]; THIS`Nodes},.oo.setf[;`Nodes];1 2]);
  (`;`.get;{});
  (`;`.newLeaf;{[THIS;idx] 'undefined});
  (`;`.newNode;{[THIS;idx] .oo.new'[THIS`.class;THIS[`State],/:enlist each THIS[`Nodes] idx;THIS`lazy;THIS`filter]});
  (`;`load;{[this] if[this`.ready;:()]; this'[`Leaves`Nodes;v:this[`filter][this`State;]. this[`.get]]; this'[`.leaves`.nodes;(count each v)#\:(::)]; this[`.ready;1]});
  (`;`cd;{[this;path] $[0=c:count path; this`pthis; (p:path 0) in this`Leaves; $[1=c;this[`getLeaves;p];'p]; p in this`Nodes; this[`getNodes;p][`cd;1_ path];'p]}));

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
 ((`Path;`);
  (`;`dt.fsTree;.oo.defgen {[this;p] this[`dt.fsTree;p;this`lazy;this`filter]},{[this;p;f;l] this[`dt.lazyTree;(),p;f;l]; this[`Path;hsym `$"/"sv string (),p]});
  (`;`files;{[this] this`Leaves});
  (`;`dirs;{[this] this`Nodes});
  (`;`getFiles;{[this;ids] this[`getLeaves;ids]});
  (`;`getDirs;{[this;ids] this[`getNodes;ids]});
  (`;`.get;{[THIS] value n#(n!()),k group{x -11<>type key` sv y,z}[n:`Leaves`Nodes;p] each k:@[key;p:THIS`Path;()] except `});
  (`;`cd;{[this;path] if[-11=type path; path:`$"/" vs string path]; if[`.~p:path 0; :this[`cd;1_ path]]; this[`dt.lazyTree:cd;path]}));

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
  (`;`dt.nsTree;.oo.defgen {[this;p] this[`dt.nsTree;p;this`lazy;this`filter]},{[this;p;f;l] this[`dt.lazyTree;(),p;f;l]; this[`Path;` sv (),$[p~``.;1_p;p]]});
  (`;`vars;{[this] this`Leaves});
  (`;`nss;{[this] this`Nodes});
  (`;`getVars;{[this;ids] this[`getLeaves;ids]});
  (`;`getNss;{[this;ids] this[`getNodes;ids]});
  (`;`.get;{[THIS] k:@[key;p:THIS`Path;()]; if[p~`; k,:`.]; value n#(n!()),k group(n:`Leaves`Nodes){if[x~`;:1]; if[99=type v:x y;if[11=type key v;if[` in key v;:1]]]; 0}[p] each k});
  (`;`cd;{[this;path] if[-11=type path; path:$[path=`.;{(),`.};path like ".*";1_;$[`~this`Path;`.,;::]]` vs path]; $[0=count p:path; this`pthis; this[`dt.lazyTree:cd;path]]}));
