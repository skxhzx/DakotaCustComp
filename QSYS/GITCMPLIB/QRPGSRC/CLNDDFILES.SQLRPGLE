     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2012')

     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNDDFILES  Send DDTASK and DDDETAIL to History if necessary
     *              This should be put on scheduler to run each night
     *  Kennethe Elder
     *  August 27, 2020
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    08/27/20  KDE  7.40
     *      - Create
740aA*    09/22/20  KDE  7.40a
     *      - Add DDDETAIL to program
     *
     *----------------------------------------------------------------
     * File Specs
     *
     *----------------------------------------------------------------

     *------------------------------------------------------------------
     * Misc defs ...
     *------------------------------------------------------------------

     D prefix          s              3

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

740 A*----------------------------------------------------------------
740 A*  Standard SQL variables and constants
740 A*----------------------------------------------------------------
740 A
740 A /copy qcopysrc,c#stdsql


     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     * Main line
     C                   exsr      zzzDDTASK
740aAC                   exsr      zzzDDDTL
    A*----------------------------------------------------------------
    A*  zzzDDTASK - Move to History
    A*----------------------------------------------------------------
    AC     zzzDDTASK     begsr

    A*---Insert any records to History that should be

     C/EXEC SQL
     C+  insert into ddtaskh
     C+  select ddtask.* from ddtask,rtehed
     C+  where ddtwhse=rhwhse and ddtrtid=rhrtid and rhstat>3
     C/END-EXEC

    A*---Delete same records from Live
     C/EXEC SQL
     C+  delete from ddtask
     C+  where (select count(*) from rtehed where ddtwhse=rhwhse and
     C+  ddtrtid=rhrtid and rhstat>3)<>0
     C/END-EXEC

    AC                   endsr
740aA*----------------------------------------------------------------
740aA*  zzzDDDTL - Move to History
740aA*----------------------------------------------------------------
740aAC     zzzDDDTL      begsr

    A*---Insert any records to History that should be

     C/EXEC SQL
     C+  insert into dddetailh
     C+  select dddetail.* from dddetail,rtehed
     C+  where dddwhse=rhwhse and dddrtid=rhrtid and rhstat>3
     C/END-EXEC

    A*---Delete same records from Live
     C/EXEC SQL
     C+  delete from dddetail
     C+  where (select count(*) from rtehed where dddwhse=rhwhse and
     C+  dddrtid=rhrtid and rhstat>3)<>0
     C/END-EXEC

740aAC                   endsr
