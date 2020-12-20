

Transaction Management - Durability
====================================

Overview
---------

- Data for databases are stored on disk

- Data is brought to memory to be modified

- Until the changes made are written to disk, they are not permanent:

  - A power loss will loose any data changed in memory but not yet
    written to disk

- Due to atomicity, if a transaction aborts we must UNDO all changes
  by that transaction

  - A second problem is that if a transaction changed data and this
    change is written to disk, we must be able to find out what it did
    and change it back

- Algorithms for ensuring durability deal with these two problems:

  - How not to loose data changed by committed transactions
  - How not to loose information about changes written to disk by
    uncommitted transactions

Logging
---------

- Logs deal with keeping track of changes made by transactions.

- A log is a system table continuously updated as transactions execute
  (new tuples/records are appended)

- Each log entry has a sequential number, **LSN**: log sequence number

- Log is created in memory but periodically written to disk
  completely, i.e. flushed to disk

- Log entries are created for:

  - Changes to transactions
  - Transaction states: commit, abort
  - Recovery steps from a crash: undo of log entries
  - Checkpoints: a snapshot of the active transactions

- Each entry has an LSN, continuously increasing number


What happens in a crash when log is used incorrectly?
---------------------------------------------------------

- Let's see a scenario:


  ::

     Suppose T1 modified data pages P1 and P2 in memory

     We want to write both P1 and P2 to disk, then we will allow
     T1 to commit.

     However after writing P1 to disk there is a crash. We loose
     all state data in memory including the portion of the log
     in memory.

     T1 did not finish, so we must undo its changes by reading
     T1 back from disk.

     If the log containing the changes to page P1 by T1 is not
     on disk, we are in trouble. We cannot UNDO.

- To make sure that such a situation does not cause a problem, we will
  employ a method called WRITE AHEAD LOGGING (WAL).

Write Ahead Logging (WAL)
--------------------------

- Write ahead logging (WAL) is a method to ensure that if a data page
  is modified on disk, we have a log record for it on disk.

- To accomplish this, the log is always written to disk ahead of the
  data.

- Write ahead logging:

  ::

     Before writing any data page modified from memory to disk:

         First, flush all the log records currently in memory
	 including the information about what was changed in this
	 data page.
  
	 After log is written, the data pages can be written
	 to disk.

- Example log entry:

  .. list-table:: Log entries (on disk)
   :header-rows: 1
   :widths: 5, 10, 5
   :stub-columns: 1

   * - LSN
     - Log Entry
     - PrevLSN
   * - 1234
     - Update: T2 PageY  21 25
     -
   * - 1235
     - Update: T1 PageX  12 15
     -
   * - 1236
     - Commit: T2
     - 1234
   * - 1237
     - Update: T1 PageY   25  31
     - 1235
   * - 1238
     - Commit: T1
     - 1237

- PrevLSN is the LSN number of the last change by the same transaction
  before the current one (used to trace back a transaction steps).

- Each update has the previous and next value for the data page:

  ::
     
     T2 PageY  21 25

     Page Y: old value: 21, new value: 25

  This is a simplification of the actual log entry.

  In reality, we only write the part of the data paged changed.

  ::

     T2 PageY startoffset-in-page  oldvalue newvalue

- Data pages contain the LSN of the last change to that page in their
  header.

  .. list-table:: Data pages (on disk)
   :header-rows: 1
   :widths: 10, 5, 10
   :stub-columns: 1

   * - Page number
     - LSN
     - Page Contents
   * - PageX
     - 1235
     - 15
   * - PageY
     - 1237
     - 31

- This allows us to see whether a change recorded in log is already
  written to disk or not.

- All transaction management systems must use WAL to make sure that a
  change to a data page written to disk can be traced and undone is
  possible.

- We will assume WAL is always used in all the discussion below.

Force and Steal
----------------

- Whenever a transaction aborts, we must UNDO all the changes it has
  already made, by reversing the updates.

- Whenever there is a crash:

  - First, we must UNDO all the changes by all transactions that have
    not completed.

  - Second, we must REDO the changes made by committed transactions to
    make sure that they are not lost.

  - These actions are called recovery.

- In both cases, what must be done for REDO and UNDO will ultimately
  depend on the rules we employ in executing transactions, namely
  force and steal.

  - Force has to do with whether we force data pages to disk when a
    transaction commits.
    
  - Steal has to do with whether memory pages are dedicated to a
    single transaction or can be shared (or stolen) by others.

  - We will see how to do both properly and their impact on recovery.
  
  
Force
-----

- Transaction management systems may employ force:

  ::

     Using force means that whenever a transaction
     wants to commit:

        1. flush the log to disk
	
        2. all the pages modified by that transaction
	   are written to disk

	3. write commit record to log, flush the log to disk
	   
	4. allow transaction to commit

- Advantage of force is that if a transaction is committed, then we
  know all the pages by the transaction are written to disk.

  No data by a committed transaction is lost.

- Disadvantage of force is that writing pages may require many seeks.
  Other transactions may also use the pages once they are in memory
  improving performance if force was not employed.

- In case of crash:

  - If we see a commit record, we know that all changes by the
    transaction are written to disk already. No need to REDO.

  - If we do not see a commit record, some data pages may actually be
    written to disk while we were trying to commit. So, we need to
    UNDO those changes.

    
No force
---------

- For comparison, let's see how NO FORCE will work.

  ::

     Using force means that whenever a transaction
     wants to commit:

        1. write the commit record and flush the log to disk 

	2. allow the transaction to commit

	   pages modified by the transaction will be
	   written to disk by the operating system
	   as needed by other transactions
	   
- The advantage is that we can improve performance by allowing commits
  without forcing lots of disk accesses.

- Log contains all actions by a committed transaction, so we can make
  sure no data is lost even in case of crash.

  However, recovery may not involve both an UNDO and a REDO. We will
  see such a recovery algorithm below.


No steal
-----------

- If a system does not use steal, then specific memory pages allocated
  to a transaction remain allocated to the same transaction until
  it commits:
 
  ::

     Using no steal means that if a transaction has modified
     a page, it must be kept in memory (not written to disk)
     until the transaction decided to commit.

- Disadvantage of no steal is that memory use is not optimal.
  
- Advantage of no steal is the simplicity of recovery. In case of a
  crash, any transaction that is not yet committed according to the
  log has not written any data to disk.

  No need to UNDO.

  There may be a need to REDO.

Steal
----------

- Using steal means the reverse:

  ::

     Using steal means that a transaction can steal the memory
     block allocated to a transaction by

         First writing the log due to Write Ahead Logging
	 
	 Then, writing the modified page to disk to free
	 up memory for this transaction.

- Advantage of steal is that memory is used more efficiently, allowing
  transactions to use more or less memory depending on need of
  different operations.

- Disadvantage of steal is that if there is a crash, we need to UNDO
  any pages modified by uncommitted transactions (i.e. dirty pages)
  that were written to disk due to steal. Hence both UNDO and REDO are
  needed.


Recovery from a crash
---------------------

- ARIES series of algorithms provide safe recovery from a crash.

- Often recovery occurs after a catastrophic event that causes loss of
  all state information.

- To recover, we must find out the state of the database just before
  crash based on the portion of the log on disk. The first step of
  recovery is the "analysis step".

- The analysis step will read log from the beginning all the way to
  its end to find all transactions that have ended and all
  transactions that were still in progress.

  - To simplify analysis, we can take period snapshots of the database
    state called checkpoints.

  - The analysis starts from the latest checkpoint.

- Based on the analysis, we find two things:

    
  - All pages modified by committed transactions that may not have
    been written to disk. All these changes must be redone.

    If force is used, there is no need to REDO.
  
  - All transactions that were still executing at the time of
    crash. The changes by these transactions must be undone.

    If steal is not used, there is no need UNDO.

Checkpointing
--------------

- A checkpoint is a snapshot of the database state written to the log.

- Checkpoints store two main types of information:

  - Transaction table: all transactions that are still executing at
    the time of checkpoint.

    For each transaction, we store its id and the LSN of the last
    action by the transaction.

  - Dirty page table: list of all pages modified in memory and were
    not written back to disk at the time of checkpoint.

    For each dirty page, we store the page id and the LSN of the
    earliest change that was not written to disk.

- When log is flushed to disk, checkpoints are also written to disk.

- During recovery, we will start from the last checkpoint for
  analysis.

- Example:

  .. list-table:: Log checkpoint example
   :header-rows: 1
   :widths: 5, 15
   :stub-columns: 1

   * - LSN
     - Log Entry
   * - 1001
     - begin checkpoint
   * - 1002
     - Transaction table
   * - 1003
     - T1 991, T2 995
   * - 1004
     - Dirty page table
   * - 1005
     - P1 981, P4 987
   * - 1006
     - end checkpoint
       
- Note in reality, checkpoints can span many log entries.

  It may take time to write a checkpoint, so it is possible to use a
  fuzzy checkpoint that will allow transactions to continue while
  checkpoint is being written.

  
Data Used During Recovery
-------------------------

- Let's recap what data is available during recovery

- Log records contain data about:

  - Transaction actions:

    update of pages

    commit of transactions

    abort of transactions

    end of transactions

- We keep track of when a committed or aborted transaction is
  completely finished with an END record.

  - for abort, all changes are undone (in memory)
  - for commit, log has been flushed.
    
  Only at this point, the transaction is notified that it has ended.
    
  - Recovery actions: log records for these are called Compensation
    Log Record (CLR)
    
    undo of updates

  - Checkpoints:

    transaction table

    dirty page table

- Data pages contain information about

  - LSN of the last update that changed that page
 
ARIES Recovery Algorithm
---------------------------

- The algorithm consists of three phases:

  - Analysis phase
  - REDO phase
  - UNDO phase

- Remember that DPT (dirty page table) stores pairs of the form
  (PX, LX) where PX is a page number and LX is the LSN number of the
  log entry for the first update to PX that has not been written to
  disk yet.

- TT (transaction table) stores pairs of the form (TX,LX) where TX is
  a transaction that is still active, and LX is the LSN number of the
  log entry for the last operation performed by LX.

- I summarize the operations performed at each step below.   

  
Analysis Phase
----------------

- The main point of analysis is to find at the time of crash which
  pages may be dirty and which transactions may still be executing.

- We simply trace the log starting with the checkpoint:

  - Find the last LSN for all transactions we find
  - Remove committed transactions
  - Record all new potentially dirty pages (and earliest potentially
    unrecorded change for each page)

- Any transaction that is not committed at the end of analysis is
  assumed to be incomplete and must be aborted. However, UNDO step
  comes first, then we will first REDO.
  
- Analysis algorithm:
  
  ::

     Read last checkpoint entry
  
     Initialize the DPT (dirty page table) and TT (transaction table) to
     the recorded checkpoint entries
  
     set NEXT_LSN to the last LSN for checkpoint
     
     while the end of log is not reached
         read the next log record pointed by NEXT_LSN into LOG_RECORD
	 if LOG_RECORD is an update: (TX updates PG)
	    put (TX, NEXT_LSN) into TT
	    ## or modify the LSN for TX if it is already in TT 
	    if PG  is not in DPT then
	        add (PG, NEXT_LSN) to DPT
	 else if LOG_RECORD is a CLR: (CLR: undo [TX update PG])
	     put (TX, NEXT_LSN) into TT
	     ## or modify the LSN for TX if it is already in TT 
      	     if PG  is not in DPT then
	         add (PG, NEXT_LSN)  to DPT
	 else if LOG_RECORD is: abort TX
	     mark TX  in TT  as aborted
	     change the LSN to NEXT_LSN
	 else if LOG_RECORD is: commit TX
	     mark TX  in TT  as committed
	     change the LSN to NEXT_LSN
	 else if LOG_RECORD is: end TX
	     remove TX  from TT
	 else
	     ignore the log record
	 advance to the next log record  ##set NEXT_LSN to NEXT_LSN+1 
  
REDO Phase
-----------

- The point of REDO is to bring the database to the same state at the
  time of crash. What we really care is making sure the changes by
  committed transactions are recorded.

  - Depending on the underlying concurrency scheme, we can REDO only
    the changes by committed transactions.

- Redo step will read each data page that is potentially dirty and if
  its pageLSN is smaller than the LSN of the log record, that means
  this change is not yet recorded to disk and we must REDO.

- Redo will simply make the NEW value of the change the current value.

  ::

     Update TX PY 10 12

  means that TX changes page PY from 10 to 12, so we must REDO to change
  the page to 12 if this change is not yet recorded.
  
- As in the transaction management system, UNDO/REDO changes are kept
  in memory or forced to disk at commit depending on whether
  force/steal are used.

  The algorithm works even in the case of repeated crashes as long as
  write ahead logging is used.


- REDO proceeds in forward log order, from earlier records to later
  records.
  
- Redo algorithm

  ::
 
     assume DPT and TT are computed by the above Analysis Phase
     set NEXT_LSN  to the lowest LSN number in DPT
     ## earliest change to a dirty page that may not have been recorded
     
     while the end of log is not reached
         read the next log record pointed by NEXT_LSN into LOG_RECORD
	 if LOG_RECORD is an update: (TX updates PG) for a committed transaction
	     call function REDO_RECORD(LOG_RECORD,NEXT_LSN)
	 else if LOG_RECORD is a CLR: (CLR: undo TX updates PG) for a committed transaction
	     call function  REDO_RECORD(LOG_RECORD,NEXT_LSN)
	 else
	     ignore the log record
	 advance to the next log record ## set NEXT_LSN  to NEXT_LSN+1
     for all transaction TX in TT with status committed
         write an end TX log record
	 remove TX from TT


     Subroutine REDO_RECORD(LOG_RECORD,NEXT_LSN)
     ## the record LOG_RECORD is to be redone at log number NEXT_LSN 

     if LOG_RECORD is an update: (TX update PG)
        if PG is not in DPT then
	    ignore ##this change has already been recorded
        else
	    find the record (PG, DPT_LSN) in DPT for this page
	    if  NEXT_LSN < DPT_LSN then
	       ignore ##this change has already been recorded
	    else
	       read PG into memory and find its pageLSN
	       if  NEXT_LSN <= PG.pageLSN then
	           ignore ## this update has already been recorded
	       else
	           REDO the update [TX updates PG]
			 
     else if LOG_RECORD is a CLR: (CLR: undo TX updates PG)
         ##do the same as above, except REDO the undo 
	 if PG is not in DPT then
             ignore  ##this change has already been recorded
	 else
             find the record (PG, DPT_LSN)  in DPT for this page
             if  NEXT_LSN < DPT_LSN then
	         ignore
	     else
                 read PG  into memory, find its pageLSN
		 if  NEXT_LSN  <= PG.pageLSN  then
	             ignore
		 else
  	             UNDO the update [TX updates PG])
                     /* hence redo the CLR */ 
		
     end of subroutine REDO_RECORD    

UNDO Phase
------------

- The point of undo is to erase changes made by aborted transactions.

- Undo will read data pages modified by the transaction to check if
  the change by a log entry is recorded on disk.

- Undo will simply make the OLD value of the change the current value.

  ::

     Update TX PY 10 12

  means that TX changes page PY from 10 to 12, so we must UNDO to change
  it back to 10.
  
- Similar to redo, the undo is made in memory. Pages changed by an
  UNDO are written back based on the force/steal protocol.

  As long as we follow the write ahead logging, we can recover from
  repeated crashes.

- Undo proceeds in backward order, each change must be changed in reverse.

  Example:

  ::

     Update TX PY 10 12
     Update TX PY 12 15

  to undo we must first change PY from 15 to 12, then from 12
  to 10. Hence, we will trace the log in reverse order.
  
- As we undo multiple transactions, we will find the largest LSN to undo
  for each transaction.

  - We will pick the largest to undo and then add the next LSN to undo
    to a list.
  - We will continue picking the largest until no operations are left.

    Hence we do not trace a single transaction back, but all
    transactions at the same time.

- Undo algorithm:

  ::

     Assume the analysis and redo phases are completed successfully
     Set the set TO_UNDO  to empty
     For all active transactions (TX, LSNX) in TT,
        add LSNX   to set TO_UNDO
        write a log record (abort TX)
	
     While TO_UNDO  is not empty
        remove the largest LSN number UNDO_LSN  from TO_UNDO
        find LOG_RECORD corresponding to UNDO_LSN
        if LOG_RECORD  is an update record of the form [TX updates PG]
           undo the update to PG  (in memory)
           write a CLR record: CLR: undo of record [TX updates PG])
           find the previous operation for TX (follow previous lsn pointer)
           if prevlsn is not nil
	       add it to TO_UNDO
           if prevlsn is nil
	       write an end record for this transaction (i.e. TX)
	else if LOG_RECORD  is a CLR record
	    find previous undo
	    if previous undo is not nil
	        add it to TO_UNDO
            if prevlsn is nil
	        write an end record for this transaction (i.e. TX)
        else find the prevlsn for the same transaction
	    if it is not nil
                 add it to TO_UNDO
            if prevlsn is nil
	          write an end record for this transaction (i.e. TX)

Example ARIES recovery
-------------------------

- Suppose after a crash, we find the following information in the log
  on disk (we only show the relevant part of the log):
  
  .. list-table:: Log entries (on disk)
   :header-rows: 1
   :widths: 5, 10, 5
   :stub-columns: 1

   * - LSN
     - Log Entry
     - PrevLSN
   * - 994
     - Update: TA P6 10 15
     -
   * - 995
     - Update: TA P5 ZZ H
     - 994
   * - 996
     - begin checkpoint
     -
   * - 997
     - TT: TA 995
     -
   * - 998
     - DPT: P6 994
     -
   * - 999
     - end checkpoint
     -
   * - 1000
     - Commit: TA
     - 996
   * - 1001
     - Update: T1 P1 A B
     -
   * - 1002
     - Update: T1 P2 C D
     - 1001
   * - 1003
     - Update: T2 P3 E F
     - 
   * - 1004
     - Update: T2 P4 F G
     - 1003
   * - 1005
     - Update: T3 P5 H I
     - 
   * - 1006
     - Update: T4 P6 15 22
     - 
   * - 1007
     - Commit T4
     - 1006
   * - 1008
     - Update: T2 P6 K L
     - 1003
   * - 1009
     - Commit T1
     - 1002
   * - 1010
     - Update T3 P2 D E
     - 1005
     
- Assume also the following is the contents of the data pages
  at the time crash.

  .. list-table:: Data page contents (on disk)
   :header-rows: 1
   :widths: 5, 5, 10
   :stub-columns: 1
  
   * - pageid
     - pageLSN
     - content
   * - P1
     - 1001
     - B
   * - P2
     - 1010
     - E
   * - P3
     - 980
     - E
   * - P4
     - 1004
     - G
   * - P5
     - 996
     - H
   * - P6
     - 994
     - 15


- Based on this log, we can conclude that there is no force
  used in this DBMS system.

  T4 is commited, but change at LSN=1006 to P6 is not written to disk.

  
- Based on this log, we can conclude that there is steal used in this
  DBMS system.

  T3 is not yet committed, but its changes at LSN=1010 to P2 are
  written to disk.
  
- We can now trace each step of the algorithm based on this information.
  
- Analysis:

  ::

     Start at checkpoint (LSN: 996), initialize TT and DPT

     LSN      State info
     996      TT: TA 995  DPT: P6 994
     1000     TT:         DPT: P6 994
     1001     TT: T1 1001 DPT: P6 994, P1 1001
     1002     TT: T1 1002 DPT: P6 994, P1 1001, P2 1002
     1003     TT: T1 1002, T2 1003 DPT: P6 994, P1 1001, P2 1002, P3 1003
     1004     TT: T1 1002, T2 1004 DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004
     1005     TT: T1 1002, T2 1004, T3 1005
              DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004, P5 1005
     1006     TT: T1 1002, T2 1004, T3 1005, T4 1006
              DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004, P5 1005
     1007     TT: T1 1002, T2 1004, T3 1005
              DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004, P5 1005
     1008     TT: T1 1002, T2 1008, T3 1005
              DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004, P5 1005
     1009     TT: T2 1008, T3 1005
              DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004, P5 1005
     1010     TT: T2 1008, T3 1010
              DPT: P6 994, P1 1001, P2 1002, P3 1003, P4 1004, P5 1005
	      
      Abort transactions: T2 and T3
      write abort log records

      LSN    Log Entry
      1011   abort T2
      1012   abort T3

      
- Now, redo phase, we will go through every single log entry starting
  with the earliest LSN in the recovered DPT, go forward and redo the
  actions of all committed transactions.

  We will need to read each potentially dirty page. We will only REDO
  an entry if it is an update to a page in DPT that was not yet
  written to disk. 

  ::

     Start at 994
     
     Skip the following LSNs:
     
     995 -- LSN for P5 in DPT is higher than 995
     1003, 1004, 1005, 1008, 1010 -- aborting transactions

     Test for REDO the following LSNs:

     test 994: Read P6, pageLSN 994, already written, no need to REDO
     test 1001: Read P1, pageLSN 1001, already written, no need to REDO
     test 1002: Read P2, pageLSN 1010, already written, no need to REDO
     test 1006: P6 already in memory, but pageLSN=994, must REDO this update

     REDO 1006

- Next, we will do UNDO all the actions of aborting transactions T2 and T3
  in backwards order.

  For each action, we will check if the action has been written to
  disk. If so, we will UNDO by changing the disk entry.

  ::

     Aborting T2 and T3, put the last LSN for each into
     the TO_UNDO set.

     TO_UNDO = {1010, 1008}

     Write: UNDO 1010 log record

        P2 is already in memory with pageLSN = 1010. We must
        undo P2 contents and change it to D.

	PrevLSN = 1005 is added to TO_UNDO.

     TO_UNDO = {1005, 1008}

     Write: UNDO 1008 log record

        P6 is already in memory, but pageLSN=1006. So, no need to change
	the data page content.

	PrevLSN = 1003 is added to TO_UNDO.

     TO_UNDO = {1005, 1003}

     Write: UNDO 1005 log record
	
	Read P5 into memory, pageLSN=996. So, no need to change
	the data page content as this update was never written to disk.

	PrevLSN = nil.

     TO_UNDO = {1003}

     Write: UNDO 1003 log record

	Read P3 into memory, pageLSN=980. So, no need to change
	the data page content as this update was never written to disk.

	PrevLSN = nil.

     TO_UNDO = {}

        Recovery is complete.

	Write END log records for aborted transactions.
  
