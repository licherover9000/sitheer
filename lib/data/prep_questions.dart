import 'package:sitheer/model/prep_question.dart';

/// PYQ-style questions keyed by chapter id — ~50 items across all GATE CS/DA subjects.
final prepQuestionsByChapter = <String, List<PrepQuestion>>{
  // ─────────── Algorithms ───────────
  'algo-sorting': [
    const PrepQuestion(
      id: 'q-algo-sort-1',
      chapterId: 'algo-sorting',
      prompt: 'What is the worst-case time complexity of QuickSort?',
      options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(log n)'],
      correctIndex: 2,
      explanation:
          'When the pivot is always the smallest or largest element (e.g. sorted input without randomization), QuickSort degrades to O(n²) due to maximally unbalanced partitions.',
    ),
    const PrepQuestion(
      id: 'q-algo-sort-2',
      chapterId: 'algo-sorting',
      prompt: 'MergeSort is stable because:',
      options: [
        'It uses extra memory',
        'Equal elements keep relative order during merge',
        'It is in-place',
        'It uses a heap',
      ],
      correctIndex: 1,
      explanation:
          'During the merge step, when two elements are equal the left subarray element is always chosen first, preserving the original relative order — the definition of stability.',
    ),
    const PrepQuestion(
      id: 'q-algo-sort-3',
      chapterId: 'algo-sorting',
      prompt: 'HeapSort is preferred over MergeSort when:',
      options: [
        'Stability is required',
        'Extra O(n) space must be avoided',
        'Input is nearly sorted',
        'Online sorting is needed',
      ],
      correctIndex: 1,
      explanation:
          'HeapSort is in-place (O(1) auxiliary space) whereas MergeSort requires O(n) extra memory for the temporary array during merging.',
    ),
    const PrepQuestion(
      id: 'q-algo-sort-4',
      chapterId: 'algo-sorting',
      prompt: 'The lower bound for comparison-based sorting is:',
      options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(n log log n)'],
      correctIndex: 1,
      explanation:
          'The decision-tree model shows at least n! leaf nodes, giving height ≥ log₂(n!) = Ω(n log n) by Stirling\'s approximation.',
    ),
  ],

  'algo-graphs': [
    const PrepQuestion(
      id: 'q-algo-graph-1',
      chapterId: 'algo-graphs',
      prompt: 'Dijkstra\'s algorithm fails on graphs with:',
      options: [
        'Undirected edges',
        'Negative edge weights',
        'Cycles',
        'More than one connected component',
      ],
      correctIndex: 1,
      explanation:
          'Dijkstra\'s greedy relaxation assumes once a node is settled its shortest path is final — negative edges can violate this assumption, causing incorrect results.',
    ),
    const PrepQuestion(
      id: 'q-algo-graph-2',
      chapterId: 'algo-graphs',
      prompt: 'The time complexity of BFS on a graph with V vertices and E edges is:',
      options: ['O(V)', 'O(E)', 'O(V + E)', 'O(V × E)'],
      correctIndex: 2,
      explanation:
          'BFS visits each vertex once and processes each edge once from each endpoint, giving O(V + E) overall with an adjacency-list representation.',
    ),
    const PrepQuestion(
      id: 'q-algo-graph-3',
      chapterId: 'algo-graphs',
      prompt: 'Topological sorting is only possible for:',
      options: [
        'Undirected graphs',
        'Directed Acyclic Graphs (DAGs)',
        'Complete graphs',
        'Weighted graphs',
      ],
      correctIndex: 1,
      explanation:
          'Topological order requires that for every directed edge u→v, u comes before v. A cycle makes this impossible, so only DAGs support topological sorting.',
    ),
    const PrepQuestion(
      id: 'q-algo-graph-4',
      chapterId: 'algo-graphs',
      prompt: 'Kruskal\'s MST algorithm uses which data structure for efficiency?',
      options: ['Heap', 'Trie', 'Union-Find (Disjoint Set)', 'Stack'],
      correctIndex: 2,
      explanation:
          'Kruskal\'s needs to check if adding an edge creates a cycle. Union-Find with path compression and union-by-rank makes this O(α(n)) ≈ O(1) per operation.',
    ),
  ],

  'algo-dp': [
    const PrepQuestion(
      id: 'q-algo-dp-1',
      chapterId: 'algo-dp',
      prompt: 'The 0/1 Knapsack problem has time complexity:',
      options: ['O(n)', 'O(n log n)', 'O(n × W)', 'O(2ⁿ) only'],
      correctIndex: 2,
      explanation:
          'The standard DP table is n items × W capacity, filling each cell in O(1), giving O(n × W) pseudo-polynomial time.',
    ),
    const PrepQuestion(
      id: 'q-algo-dp-2',
      chapterId: 'algo-dp',
      prompt: 'Longest Common Subsequence of "ABCBDAB" and "BDCAB" has length:',
      options: ['3', '4', '5', '6'],
      correctIndex: 1,
      explanation:
          'The LCS is "BCAB" (or "BDAB") with length 4. The DP recurrence LCS[i][j] = LCS[i-1][j-1]+1 if match, else max(LCS[i-1][j], LCS[i][j-1]).',
    ),
    const PrepQuestion(
      id: 'q-algo-dp-3',
      chapterId: 'algo-dp',
      prompt: 'Matrix chain multiplication chooses parenthesization to minimize:',
      options: ['Number of matrices', 'Number of scalar additions', 'Number of scalar multiplications', 'Memory usage'],
      correctIndex: 2,
      explanation:
          'Matrix chain multiplication optimizes the number of scalar multiplications, since multiplication is the dominant operation compared to additions.',
    ),
    const PrepQuestion(
      id: 'q-algo-dp-4',
      chapterId: 'algo-dp',
      prompt: 'Which property is REQUIRED for dynamic programming to apply?',
      options: [
        'Greedy choice property',
        'Optimal substructure',
        'Divide and conquer',
        'Amortized analysis',
      ],
      correctIndex: 1,
      explanation:
          'Optimal substructure means an optimal solution to the whole problem contains optimal solutions to subproblems — this is the fundamental requirement for DP.',
    ),
  ],

  // ─────────── Data Structures ───────────
  'ds-trees': [
    const PrepQuestion(
      id: 'q-ds-tree-1',
      chapterId: 'ds-trees',
      prompt: 'In-order traversal of a BST yields:',
      options: [
        'Random order',
        'Descending keys',
        'Sorted ascending keys',
        'Level order',
      ],
      correctIndex: 2,
      explanation:
          'In-order traversal visits left subtree → root → right subtree. In a BST all left descendants are smaller and all right descendants are larger, so this yields ascending order.',
    ),
    const PrepQuestion(
      id: 'q-ds-tree-2',
      chapterId: 'ds-trees',
      prompt: 'The height of a complete binary tree with n nodes is:',
      options: ['O(n)', 'O(log n)', 'O(n log n)', 'O(√n)'],
      correctIndex: 1,
      explanation:
          'A complete binary tree of height h has between 2^h and 2^(h+1)-1 nodes, so h = ⌊log₂ n⌋ = O(log n).',
    ),
    const PrepQuestion(
      id: 'q-ds-tree-3',
      chapterId: 'ds-trees',
      prompt: 'An AVL tree maintains balance by ensuring:',
      options: [
        'All leaves at same level',
        'Height difference between left/right subtrees ≤ 1',
        'Equal number of nodes in each subtree',
        'No right-skewed subtrees',
      ],
      correctIndex: 1,
      explanation:
          'The AVL invariant requires |height(left) - height(right)| ≤ 1 at every node. Rotations (LL, RR, LR, RL) are used after insertions/deletions to restore this.',
    ),
  ],

  'ds-linear': [
    const PrepQuestion(
      id: 'q-ds-linear-1',
      chapterId: 'ds-linear',
      prompt: 'Which operation is O(1) for a doubly-linked list but O(n) for a singly-linked list?',
      options: [
        'Insertion at head',
        'Deletion of a node given its pointer',
        'Search by value',
        'Insertion at tail (without tail pointer)',
      ],
      correctIndex: 1,
      explanation:
          'To delete a node in a singly-linked list you need its predecessor (O(n) traversal). In a doubly-linked list the node itself holds the previous pointer, so deletion is O(1).',
    ),
    const PrepQuestion(
      id: 'q-ds-linear-2',
      chapterId: 'ds-linear',
      prompt: 'A queue implemented with two stacks has amortized push/pop complexity:',
      options: ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'],
      correctIndex: 1,
      explanation:
          'Each element is pushed once and popped once from each stack — at most 4 operations total per element. Amortized cost per operation is O(1) even though worst-case per-op is O(n).',
    ),
    const PrepQuestion(
      id: 'q-ds-linear-3',
      chapterId: 'ds-linear',
      prompt: 'Stack overflow in recursion is caused by:',
      options: [
        'Too many heap allocations',
        'Exceeding call stack depth (no base case or deep recursion)',
        'Integer overflow',
        'Array bounds violation',
      ],
      correctIndex: 1,
      explanation:
          'Each recursive call pushes a new stack frame. Without a proper base case (or with very deep recursion), the call stack exhausts its allocated space — stack overflow.',
    ),
  ],

  'ds-hashing': [
    const PrepQuestion(
      id: 'q-ds-hash-1',
      chapterId: 'ds-hashing',
      prompt: 'Load factor α = n/m. Average search time under separate chaining is:',
      options: ['O(1)', 'O(α)', 'O(α²)', 'O(n)'],
      correctIndex: 1,
      explanation:
          'With separate chaining and uniform hashing, average chain length is α. An unsuccessful search traverses the whole chain: O(1 + α). For small α this is O(1).',
    ),
    const PrepQuestion(
      id: 'q-ds-hash-2',
      chapterId: 'ds-hashing',
      prompt: 'Open addressing with linear probing suffers from:',
      options: [
        'Secondary clustering',
        'Primary clustering',
        'No clustering',
        'Chaining overhead',
      ],
      correctIndex: 1,
      explanation:
          'Linear probing creates long runs of occupied slots (primary clusters) because consecutive collisions all probe the same sequence, degrading performance.',
    ),
    const PrepQuestion(
      id: 'q-ds-hash-3',
      chapterId: 'ds-hashing',
      prompt: 'The best hash function for strings is typically:',
      options: [
        'Sum of ASCII values mod m',
        'Polynomial rolling hash (Rabin-Karp style)',
        'Length of string mod m',
        'First character mod m',
      ],
      correctIndex: 1,
      explanation:
          'A polynomial rolling hash h(s) = Σ s[i]·p^i (mod m) captures positional information, reducing collisions vs. simpler sums which ignore order.',
    ),
  ],

  // ─────────── Operating Systems ───────────
  'os-process': [
    const PrepQuestion(
      id: 'q-os-proc-1',
      chapterId: 'os-process',
      prompt: 'Round Robin scheduling with very large time quantum behaves like:',
      options: ['FCFS', 'SJF', 'SRTF', 'Priority scheduling'],
      correctIndex: 0,
      explanation:
          'As the time quantum → ∞, each process runs to completion before preemption — identical to FCFS (First Come First Served).',
    ),
    const PrepQuestion(
      id: 'q-os-proc-2',
      chapterId: 'os-process',
      prompt: 'A process moves from Running to Blocked state when:',
      options: [
        'It is preempted by a higher-priority process',
        'It issues an I/O request',
        'Its time quantum expires',
        'It is newly created',
      ],
      correctIndex: 1,
      explanation:
          'An I/O request cannot be completed immediately by the CPU, so the process blocks (waits) until the I/O completes, at which point it moves to the Ready queue.',
    ),
    const PrepQuestion(
      id: 'q-os-proc-3',
      chapterId: 'os-process',
      prompt: 'Shortest Job First (SJF) is optimal in minimizing:',
      options: ['Turnaround time', 'Waiting time', 'Average waiting time', 'Response time'],
      correctIndex: 2,
      explanation:
          'SJF minimizes average waiting time among all non-preemptive algorithms. It\'s provably optimal: scheduling the shortest burst next minimizes total time other processes wait.',
    ),
  ],

  'os-memory': [
    const PrepQuestion(
      id: 'q-os-mem-1',
      chapterId: 'os-memory',
      prompt: 'Paging avoids:',
      options: [
        'External fragmentation',
        'Internal fragmentation only',
        'TLB misses',
        'Page faults',
      ],
      correctIndex: 0,
      explanation:
          'Paging uses fixed-size frames so free frames can always accommodate any page — no external fragmentation. Internal fragmentation still exists (last page may be partially filled).',
    ),
    const PrepQuestion(
      id: 'q-os-mem-2',
      chapterId: 'os-memory',
      prompt: 'Thrashing occurs when:',
      options: [
        'CPU utilization is 100%',
        'Processes spend more time page-faulting than executing',
        'Virtual memory is disabled',
        'TLB hit rate is 100%',
      ],
      correctIndex: 1,
      explanation:
          'Thrashing happens when the working set of all processes exceeds physical memory. The system spends most time swapping pages in/out, causing very low CPU utilization.',
    ),
    const PrepQuestion(
      id: 'q-os-mem-3',
      chapterId: 'os-memory',
      prompt: 'LRU page replacement is approximated in hardware using:',
      options: ['Clock algorithm', 'Reference bits / Aging', 'FIFO', 'Random replacement'],
      correctIndex: 1,
      explanation:
          'True LRU requires tracking exact last-use times. Hardware approximations use reference bits that are periodically shifted right (aging), creating an approximate LRU ordering.',
    ),
  ],

  'os-sync': [
    const PrepQuestion(
      id: 'q-os-sync-1',
      chapterId: 'os-sync',
      prompt: 'Deadlock requires all four conditions: mutual exclusion, hold-and-wait, no preemption, and:',
      options: ['Starvation', 'Circular wait', 'Priority inversion', 'Busy waiting'],
      correctIndex: 1,
      explanation:
          'The four Coffman conditions for deadlock are: mutual exclusion, hold-and-wait, no preemption, and circular wait. All four must hold simultaneously.',
    ),
    const PrepQuestion(
      id: 'q-os-sync-2',
      chapterId: 'os-sync',
      prompt: 'A binary semaphore initialized to 1 implements:',
      options: ['Counting semaphore', 'Mutex', 'Spinlock', 'Condition variable'],
      correctIndex: 1,
      explanation:
          'A binary semaphore {0,1} initialized to 1 provides mutual exclusion: wait() decrements to 0 (locked), signal() increments back to 1 (unlocked) — equivalent to a mutex.',
    ),
    const PrepQuestion(
      id: 'q-os-sync-3',
      chapterId: 'os-sync',
      prompt: 'Banker\'s Algorithm is used for:',
      options: ['Memory allocation', 'Deadlock avoidance', 'CPU scheduling', 'Deadlock detection'],
      correctIndex: 1,
      explanation:
          'Banker\'s Algorithm checks if a resource allocation request would leave the system in a safe state (a state from which all processes can complete). It\'s a deadlock avoidance technique.',
    ),
  ],

  // ─────────── DBMS ───────────
  'dbms-sql': [
    const PrepQuestion(
      id: 'q-dbms-sql-1',
      chapterId: 'dbms-sql',
      prompt: 'Which clause filters rows before grouping?',
      options: ['WHERE', 'HAVING', 'ORDER BY', 'GROUP BY'],
      correctIndex: 0,
      explanation:
          'WHERE filters individual rows before aggregation. HAVING filters groups after GROUP BY. Both filter differently — WHERE cannot reference aggregate functions.',
    ),
    const PrepQuestion(
      id: 'q-dbms-sql-2',
      chapterId: 'dbms-sql',
      prompt: 'Division in relational algebra is used for:',
      options: [
        'All tuples in A related to every tuple in B',
        'Cartesian product',
        'Union of relations',
        'Deleting duplicates',
      ],
      correctIndex: 0,
      explanation:
          'Relational division A ÷ B returns tuples in A that are associated with ALL tuples in B — e.g., "find students who have taken all courses in set B".',
    ),
    const PrepQuestion(
      id: 'q-dbms-sql-3',
      chapterId: 'dbms-sql',
      prompt: 'A view in SQL is:',
      options: [
        'A physical table stored on disk',
        'A virtual table defined by a query',
        'A synonym for an index',
        'A stored procedure',
      ],
      correctIndex: 1,
      explanation:
          'A view is a named query stored in the database catalog. It appears as a virtual table to users but does not store data itself (unless it is a materialized view).',
    ),
  ],

  'dbms-normal': [
    const PrepQuestion(
      id: 'q-dbms-norm-1',
      chapterId: 'dbms-normal',
      prompt: 'A relation is in BCNF if for every non-trivial FD X→Y:',
      options: [
        'Y is a prime attribute',
        'X is a superkey',
        'X is a candidate key',
        'Y is part of a candidate key',
      ],
      correctIndex: 1,
      explanation:
          'BCNF (Boyce-Codd Normal Form) requires that the left-hand side of every non-trivial functional dependency is a superkey. This is stricter than 3NF.',
    ),
    const PrepQuestion(
      id: 'q-dbms-norm-2',
      chapterId: 'dbms-normal',
      prompt: 'Partial dependency occurs when:',
      options: [
        'A non-key attribute depends on part of the composite primary key',
        'An attribute depends on a non-key attribute',
        'Two candidate keys overlap',
        'A foreign key references a non-unique column',
      ],
      correctIndex: 0,
      explanation:
          'Partial dependency: a non-prime (non-key) attribute depends on a proper subset of the composite primary key. Eliminating these gives 2NF.',
    ),
    const PrepQuestion(
      id: 'q-dbms-norm-3',
      chapterId: 'dbms-normal',
      prompt: 'Transitive dependency is eliminated in:',
      options: ['1NF', '2NF', '3NF', 'BCNF'],
      correctIndex: 2,
      explanation:
          '3NF requires no non-prime attribute is transitively dependent on the primary key. A→B→C where A is primary key and B is non-prime is a transitive dependency.',
    ),
  ],

  'dbms-txn': [
    const PrepQuestion(
      id: 'q-dbms-txn-1',
      chapterId: 'dbms-txn',
      prompt: 'The ACID property that ensures transactions execute as if they are the only one running is:',
      options: ['Atomicity', 'Consistency', 'Isolation', 'Durability'],
      correctIndex: 2,
      explanation:
          'Isolation ensures that concurrent transactions appear to execute serially — intermediate states of one transaction are not visible to others.',
    ),
    const PrepQuestion(
      id: 'q-dbms-txn-2',
      chapterId: 'dbms-txn',
      prompt: 'A "dirty read" anomaly occurs when:',
      options: [
        'A transaction reads a value written by another uncommitted transaction',
        'A transaction reads the same row twice with different values',
        'A transaction reads a phantom row',
        'A transaction reads a committed rollback',
      ],
      correctIndex: 0,
      explanation:
          'A dirty read happens when transaction T2 reads data modified by T1 before T1 commits. If T1 later rolls back, T2 has read data that never existed.',
    ),
    const PrepQuestion(
      id: 'q-dbms-txn-3',
      chapterId: 'dbms-txn',
      prompt: 'Two-phase locking (2PL) guarantees:',
      options: ['Deadlock freedom', 'Serializability', 'Starvation freedom', 'Optimistic concurrency'],
      correctIndex: 1,
      explanation:
          '2PL ensures conflict serializability: the growing phase acquires locks, the shrinking phase releases them. Once a lock is released, no new lock can be acquired.',
    ),
  ],

  // ─────────── Computer Networks ───────────
  'cn-routing': [
    const PrepQuestion(
      id: 'q-cn-route-1',
      chapterId: 'cn-routing',
      prompt: 'Distance-vector routing suffers from:',
      options: [
        'Count-to-infinity',
        'No loops',
        'Global link-state knowledge',
        'Fixed path MTU',
      ],
      correctIndex: 0,
      explanation:
          'Distance-vector protocols (like RIP) can loop: when a link fails, routers may keep incrementing the metric to infinity while still believing a path exists through each other.',
    ),
    const PrepQuestion(
      id: 'q-cn-route-2',
      chapterId: 'cn-routing',
      prompt: 'OSPF is a link-state protocol that uses:',
      options: ['Bellman-Ford', 'Dijkstra\'s shortest path', 'Spanning tree', 'Flooding only'],
      correctIndex: 1,
      explanation:
          'OSPF routers maintain a complete topology map (link-state database) and compute shortest paths using Dijkstra\'s algorithm, unlike distance-vector protocols.',
    ),
    const PrepQuestion(
      id: 'q-cn-route-3',
      chapterId: 'cn-routing',
      prompt: 'Subnet mask 255.255.255.192 in CIDR notation is:',
      options: ['/24', '/26', '/28', '/30'],
      correctIndex: 1,
      explanation:
          '255.255.255.192 = 11111111.11111111.11111111.11000000. Counting the 1-bits: 24 + 2 = 26 bits. So /26.',
    ),
  ],

  'cn-transport': [
    const PrepQuestion(
      id: 'q-cn-trans-1',
      chapterId: 'cn-transport',
      prompt: 'TCP ensures reliability using:',
      options: [
        'Sequence numbers, ACKs, and retransmission',
        'Checksums alone',
        'IP fragmentation',
        'DNS lookups',
      ],
      correctIndex: 0,
      explanation:
          'TCP uses sequence numbers to order segments, acknowledgments (ACKs) to confirm receipt, and retransmission timers to resend unacknowledged segments.',
    ),
    const PrepQuestion(
      id: 'q-cn-trans-2',
      chapterId: 'cn-transport',
      prompt: 'UDP is preferred over TCP when:',
      options: [
        'Guaranteed delivery is required',
        'Low latency matters more than reliability (e.g., video calls)',
        'Data must arrive in order',
        'The receiver must acknowledge every packet',
      ],
      correctIndex: 1,
      explanation:
          'UDP has no connection setup, no retransmission, and no ordering overhead — ideal for real-time applications (VoIP, streaming) where a small amount of loss is acceptable.',
    ),
    const PrepQuestion(
      id: 'q-cn-trans-3',
      chapterId: 'cn-transport',
      prompt: 'TCP slow start begins with congestion window (cwnd) of:',
      options: ['MSS/2', '1 MSS', '2 MSS', 'ssthresh'],
      correctIndex: 1,
      explanation:
          'TCP slow start initializes cwnd = 1 MSS and doubles it each RTT until cwnd reaches ssthresh (slow-start threshold), after which congestion avoidance (linear increase) begins.',
    ),
  ],

  'cn-physical': [
    const PrepQuestion(
      id: 'q-cn-phys-1',
      chapterId: 'cn-physical',
      prompt: 'Shannon\'s channel capacity formula C = B log₂(1 + S/N) gives capacity in:',
      options: ['Packets per second', 'Bits per second', 'Baud', 'MHz'],
      correctIndex: 1,
      explanation:
          'Shannon\'s theorem gives the theoretical maximum data rate (in bits per second) for a channel of bandwidth B Hz and signal-to-noise ratio S/N.',
    ),
    const PrepQuestion(
      id: 'q-cn-phys-2',
      chapterId: 'cn-physical',
      prompt: 'Manchester encoding guarantees:',
      options: [
        'Efficient bandwidth use',
        'A clock transition in every bit period',
        'DC balance only',
        'No signal inversion',
      ],
      correctIndex: 1,
      explanation:
          'Manchester encoding embeds clock information by always having a transition in the middle of each bit period (high→low = 0, low→high = 1), enabling self-clocking at the receiver.',
    ),
  ],

  // ─────────── Theory of Computation ───────────
  'toc-fa': [
    const PrepQuestion(
      id: 'q-toc-fa-1',
      chapterId: 'toc-fa',
      prompt: 'The language accepted by a DFA is always:',
      options: ['Context-free', 'Regular', 'Recursively enumerable', 'Context-sensitive'],
      correctIndex: 1,
      explanation:
          'DFAs (and NFAs) recognize exactly the class of regular languages. Regular languages are closed under union, concatenation, and Kleene star.',
    ),
    const PrepQuestion(
      id: 'q-toc-fa-2',
      chapterId: 'toc-fa',
      prompt: 'Minimization of DFA merges states that are:',
      options: [
        'Indistinguishable on all inputs',
        'Unreachable only',
        'Final and non-final',
        'Equivalent on empty string only',
      ],
      correctIndex: 0,
      explanation:
          'Two states p, q are distinguishable if some string w leads one to an accepting state and the other to a rejecting state. States that cannot be distinguished on ANY string are merged.',
    ),
    const PrepQuestion(
      id: 'q-toc-fa-3',
      chapterId: 'toc-fa',
      prompt: 'The number of states in the minimal DFA for strings over {a,b} containing "ab" as a substring is:',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      explanation:
          'Three states suffice: q0 (no progress), q1 (seen "a"), q2 (seen "ab" — accepting sink). Any string with "ab" reaches q2 and stays there.',
    ),
  ],

  'toc-cfg': [
    const PrepQuestion(
      id: 'q-toc-cfg-1',
      chapterId: 'toc-cfg',
      prompt: 'The language {aⁿbⁿ | n ≥ 0} is:',
      options: [
        'Regular',
        'Context-free but not regular',
        'Context-sensitive but not context-free',
        'Turing-recognizable only',
      ],
      correctIndex: 1,
      explanation:
          'The pumping lemma for regular languages proves {aⁿbⁿ} is not regular. It is context-free, generated by S → aSb | ε and accepted by a PDA that pushes a\'s and pops on b\'s.',
    ),
    const PrepQuestion(
      id: 'q-toc-cfg-2',
      chapterId: 'toc-cfg',
      prompt: 'Ambiguous grammar is one where:',
      options: [
        'It generates no strings',
        'Some string has two distinct parse trees',
        'It is not in CNF',
        'It has left recursion',
      ],
      correctIndex: 1,
      explanation:
          'A CFG is ambiguous if there exists at least one string with two or more leftmost derivations (equivalently, two distinct parse trees). Ambiguity is a property of grammars, not languages.',
    ),
    const PrepQuestion(
      id: 'q-toc-cfg-3',
      chapterId: 'toc-cfg',
      prompt: 'CYK algorithm parses a string of length n using a CFG in CNF in:',
      options: ['O(n)', 'O(n²)', 'O(n³)', 'O(2ⁿ)'],
      correctIndex: 2,
      explanation:
          'CYK fills an n×n triangle DP table, each cell requiring O(n) work to try all split points. Total: O(n³) — polynomial, making CYK practical for moderate-length strings.',
    ),
  ],

  'toc-tm': [
    const PrepQuestion(
      id: 'q-toc-tm-1',
      chapterId: 'toc-tm',
      prompt: 'The Halting Problem is:',
      options: [
        'Decidable in polynomial time',
        'Undecidable',
        'Decidable but exponential',
        'Semi-decidable only for total TMs',
      ],
      correctIndex: 1,
      explanation:
          'Turing proved by diagonalization that no TM can decide whether an arbitrary TM halts on a given input. The Halting Problem is the canonical undecidable problem.',
    ),
    const PrepQuestion(
      id: 'q-toc-tm-2',
      chapterId: 'toc-tm',
      prompt: 'A recursively enumerable (RE) language is one where:',
      options: [
        'A TM always halts and accepts or rejects',
        'A TM halts and accepts all strings in the language (but may loop on non-members)',
        'A DFA accepts the language',
        'A PDA accepts the language',
      ],
      correctIndex: 1,
      explanation:
          'RE (Turing-recognizable): a TM halts-and-accepts on all strings in L, but may loop forever on strings not in L. Recursive (decidable): TM always halts.',
    ),
    const PrepQuestion(
      id: 'q-toc-tm-3',
      chapterId: 'toc-tm',
      prompt: 'Rice\'s Theorem states that every non-trivial property of the language of a TM is:',
      options: ['Decidable', 'Undecidable', 'Semi-decidable', 'Regular'],
      correctIndex: 1,
      explanation:
          'Rice\'s Theorem: any non-trivial semantic property of TMs (concerning the language they accept) is undecidable. This generalizes the Halting Problem to many questions about programs.',
    ),
  ],

  // ─────────── Mathematics ───────────
  'math-la': [
    const PrepQuestion(
      id: 'q-math-la-1',
      chapterId: 'math-la',
      prompt: 'Eigenvalues of a matrix exist when:',
      options: [
        'Av = λv has non-zero v',
        'Matrix is always singular',
        'Determinant is zero only',
        'Matrix is symmetric only',
      ],
      correctIndex: 0,
      explanation:
          'Eigenvalues λ satisfy det(A - λI) = 0. For each eigenvalue, eigenvectors v ≠ 0 satisfy Av = λv. Every n×n matrix over ℂ has exactly n eigenvalues (counted with multiplicity).',
    ),
    const PrepQuestion(
      id: 'q-math-la-2',
      chapterId: 'math-la',
      prompt: 'Rank-nullity theorem states: rank(A) + nullity(A) =',
      options: ['Number of rows', 'Number of columns', 'Determinant', 'Trace'],
      correctIndex: 1,
      explanation:
          'For an m×n matrix A: rank(A) (dimension of column space) + nullity(A) (dimension of null space) = n (number of columns).',
    ),
    const PrepQuestion(
      id: 'q-math-la-3',
      chapterId: 'math-la',
      prompt: 'A system Ax = b has no solution when:',
      options: [
        'rank(A) = rank([A|b]) = n',
        'rank(A) < rank([A|b])',
        'rank(A) = n',
        'det(A) ≠ 0',
      ],
      correctIndex: 1,
      explanation:
          'By Rouché-Capelli theorem: Ax = b is inconsistent iff rank(A) < rank([A|b]). The augmented matrix has higher rank than A, meaning b is outside the column space of A.',
    ),
  ],

  'math-prob': [
    const PrepQuestion(
      id: 'q-math-prob-1',
      chapterId: 'math-prob',
      prompt: 'For a normal distribution, about 95% of values lie within:',
      options: ['1σ', '2σ', '3σ', '0.5σ'],
      correctIndex: 1,
      explanation:
          'The 68-95-99.7 rule: ~68% lie within 1σ, ~95% within 2σ, ~99.7% within 3σ of the mean.',
    ),
    const PrepQuestion(
      id: 'q-math-prob-2',
      chapterId: 'math-prob',
      prompt: 'If P(A) = 0.4, P(B) = 0.3, and A and B are independent, then P(A ∩ B) =',
      options: ['0.7', '0.12', '0.1', '0.3'],
      correctIndex: 1,
      explanation:
          'For independent events P(A ∩ B) = P(A) · P(B) = 0.4 × 0.3 = 0.12.',
    ),
    const PrepQuestion(
      id: 'q-math-prob-3',
      chapterId: 'math-prob',
      prompt: 'Bayes\' Theorem is used to:',
      options: [
        'Compute joint probability of independent events',
        'Update prior probability given new evidence',
        'Calculate expected value',
        'Find the mode of a distribution',
      ],
      correctIndex: 1,
      explanation:
          'Bayes\' Theorem: P(A|B) = P(B|A)·P(A) / P(B). It updates a prior belief P(A) with likelihood P(B|A) given observed evidence B to get the posterior P(A|B).',
    ),
  ],

  // ─────────── Aptitude ───────────
  'apt-verbal': [
    const PrepQuestion(
      id: 'q-apt-verbal-1',
      chapterId: 'apt-verbal',
      prompt: 'Choose the word most opposite in meaning to "Ephemeral":',
      options: ['Transient', 'Fleeting', 'Permanent', 'Temporary'],
      correctIndex: 2,
      explanation:
          'Ephemeral means lasting a very short time. Its antonym is Permanent (lasting or enduring forever or for a long time).',
    ),
    const PrepQuestion(
      id: 'q-apt-verbal-2',
      chapterId: 'apt-verbal',
      prompt: 'Which sentence is grammatically correct?',
      options: [
        'Each of the students have submitted their assignment.',
        'Each of the students has submitted their assignment.',
        'Each of the student has submitted their assignment.',
        'Each of the students has submitted its assignment.',
      ],
      correctIndex: 1,
      explanation:
          '"Each" is singular and takes a singular verb. "Each of the students has..." is correct. "Their" is acceptable as a gender-neutral singular pronoun.',
    ),
  ],

  'apt-quant': [
    const PrepQuestion(
      id: 'q-apt-quant-1',
      chapterId: 'apt-quant',
      prompt: 'A train 200m long crosses a pole in 10 seconds. Its speed is:',
      options: ['15 m/s', '20 m/s', '25 m/s', '18 m/s'],
      correctIndex: 1,
      explanation:
          'Speed = distance/time = 200m / 10s = 20 m/s.',
    ),
    const PrepQuestion(
      id: 'q-apt-quant-2',
      chapterId: 'apt-quant',
      prompt: 'The compound interest on ₹1000 at 10% p.a. for 2 years is:',
      options: ['₹200', '₹210', '₹100', '₹205'],
      correctIndex: 1,
      explanation:
          'A = P(1 + r/100)^t = 1000 × (1.1)² = 1000 × 1.21 = ₹1210. CI = 1210 - 1000 = ₹210.',
    ),
  ],

  'apt-reason': [
    const PrepQuestion(
      id: 'q-apt-reason-1',
      chapterId: 'apt-reason',
      prompt: 'If all roses are flowers and all flowers need water, then:',
      options: [
        'Some roses do not need water',
        'All roses need water',
        'Some flowers are not roses',
        'No roses need water',
      ],
      correctIndex: 1,
      explanation:
          'Syllogism: roses ⊆ flowers, flowers ⊆ {things needing water}. By transitivity: roses ⊆ {things needing water}. So all roses need water.',
    ),
    const PrepQuestion(
      id: 'q-apt-reason-2',
      chapterId: 'apt-reason',
      prompt: 'Series: 2, 6, 12, 20, 30, ___',
      options: ['38', '40', '42', '36'],
      correctIndex: 2,
      explanation:
          'Differences: 4, 6, 8, 10, 12. The series is n(n+1): 1×2, 2×3, 3×4, 4×5, 5×6, 6×7 = 42.',
    ),
  ],

  // ─────────── Stats & Data Analysis ───────────
  'stats-core': [
    const PrepQuestion(
      id: 'q-stats-1',
      chapterId: 'stats-core',
      prompt: 'For a normal distribution, about 95% of values lie within:',
      options: ['1 sigma', '2 sigma', '3 sigma', '0.5 sigma'],
      correctIndex: 1,
      explanation:
          'The empirical rule: 68%-95%-99.7%. About 95% of data falls within ±2 standard deviations of the mean in a normal distribution.',
    ),
    const PrepQuestion(
      id: 'q-stats-2',
      chapterId: 'stats-core',
      prompt: 'A p-value < 0.05 in hypothesis testing means:',
      options: [
        'The null hypothesis is definitely true',
        'We reject the null hypothesis at 5% significance level',
        'The effect size is large',
        'There is a 95% chance the alternative is true',
      ],
      correctIndex: 1,
      explanation:
          'A p-value < 0.05 means: if H₀ were true, we\'d see this result (or more extreme) less than 5% of the time. We reject H₀ at the 5% significance level.',
    ),
    const PrepQuestion(
      id: 'q-stats-3',
      chapterId: 'stats-core',
      prompt: 'The coefficient of variation (CV) is defined as:',
      options: [
        'Mean / Standard Deviation',
        '(Standard Deviation / Mean) × 100%',
        'Variance / Mean',
        'Mean / Variance',
      ],
      correctIndex: 1,
      explanation:
          'CV = (σ/μ) × 100%. It measures relative variability — useful for comparing dispersion across datasets with different units or scales.',
    ),
  ],

  // ─────────── Python / Programming (GATE DA) ───────────
  'prog-da-python': [
    const PrepQuestion(
      id: 'q-prog-1',
      chapterId: 'prog-da-python',
      prompt: 'Time complexity of `x in set` for a Python set is:',
      options: ['O(1) average', 'O(n)', 'O(log n)', 'O(n²)'],
      correctIndex: 0,
      explanation:
          'Python sets use hash tables. Membership testing computes the hash of x (O(1)) and probes the table — O(1) average, O(n) worst case with many collisions.',
    ),
    const PrepQuestion(
      id: 'q-prog-2',
      chapterId: 'prog-da-python',
      prompt: 'What does Python\'s list comprehension `[x*2 for x in range(5)]` produce?',
      options: [
        '[0, 2, 4, 6, 8]',
        '[1, 2, 4, 8, 16]',
        '[0, 1, 2, 3, 4]',
        '[2, 4, 6, 8, 10]',
      ],
      correctIndex: 0,
      explanation:
          'range(5) = [0,1,2,3,4]. Multiplying each by 2 gives [0, 2, 4, 6, 8].',
    ),
    const PrepQuestion(
      id: 'q-prog-3',
      chapterId: 'prog-da-python',
      prompt: 'Which Python data type is immutable?',
      options: ['list', 'dict', 'tuple', 'set'],
      correctIndex: 2,
      explanation:
          'Tuples are immutable in Python — once created, their elements cannot be changed. Lists, dicts, and sets are mutable.',
    ),
  ],

  // ─────────── TOC DFA (additional) ───────────
  'toc-dfa': [
    const PrepQuestion(
      id: 'q-toc-dfa-1',
      chapterId: 'toc-dfa',
      prompt: 'Minimization of DFA merges states that are:',
      options: [
        'Indistinguishable on all inputs',
        'Unreachable only',
        'Final and non-final',
        'Equivalent on empty string only',
      ],
      correctIndex: 0,
      explanation:
          'DFA minimization uses the table-filling algorithm: states p,q are indistinguishable if no string w makes exactly one of them accept. All indistinguishable states are merged.',
    ),
  ],
};

List<PrepQuestion> questionsForChapter(String chapterId) {
  return prepQuestionsByChapter[chapterId] ??
      [
        PrepQuestion(
          id: 'generic-$chapterId',
          chapterId: chapterId,
          prompt: 'Placeholder: add more questions for $chapterId',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          explanation: 'Import a full question bank into Firestore later.',
        ),
      ];
}
