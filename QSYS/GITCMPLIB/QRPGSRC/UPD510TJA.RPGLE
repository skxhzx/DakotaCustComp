      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPD510TJA   Create default repack slots for all depts
     *  10 April 2007
     *  Traci Jahnke
     *
     *  Revisions
     *
     *    04/10/07  TJ   5.10
     *      - Created
650aA*    02/15/13  JCJ  6.50a
     *      - Commented out the creation of RPK-501-1 slots.
     *        these slot have been replaced by RCVREPACK-XX slots
     *        in license tracking.
740 A*    09/09/20  KDE  7.40
     *      - Enh:  Create Replen Task record  (REPLRP)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslot      uf a e             disk
     Fslot2     if   e           k disk    rename(slrec:slrec2)
     Fwhdept    if   e           k disk
740 Aftask      uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D create          s              1
     D keydisp         s             12

     *----------------------------------------------------------------
     *  Define keys
     *----------------------------------------------------------------

     C     slotkey       klist
     C                   kfld                    wdwhse
     C                   kfld                    wdcode
     C                   kfld                    keydisp

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   exsr      getdept
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  getdept
     *----------------------------------------------------------------

     C     getdept       begsr

     C     *loval        setll     whdept
     C                   read      whdept
     C                   dow       not %eof
     C                   exsr      writerec1
650aD ***                exsr      writerec2
740 Ac                   exsr      crttask
     C                   read      whdept
     C                   enddo

     C                   endsr

740 A*----------------------------------------------------------------
740 A*  crttask     REPLRP
740 A*----------------------------------------------------------------

     C     crttask       begsr
      /free
         chain ('REPLRP') task;
         if not %found(task);
           tkcode='REPLRP';
           tkdesc='Replenishment - Repack';
           tkcat='SMAINT';
           tksub='REPL';
           tktype='D';
           tkstd='Y';
           tktlvl='D';
           tkusrc='N';
           tktrkc='Y';
           tktrkw='Y';
           tktrkp='Y';
           tktrk1='N';
           tkdsc1=' ';
           tktrk2='N';
           tkdsc2=' ';
           tktrk3='N';
           tkdsc3=' ';
           write tkrec;
         endif;
      /end-free
740 AC                   endsr

     *----------------------------------------------------------------
     *  writerec1   RPK-101-1
     *----------------------------------------------------------------

     C     writerec1     begsr

     C                   eval      create = 'N'
     C                   eval      keydisp = 'RPK-101-1'

      * Check to see if default already exists; pgm already ran

     C     slotkey       setll     slot2
     C     slotkey       reade     slot2
     C                   if        %eof
     C                   eval      create = 'Y'
     C                   endif
     C                   if        not %eof
     C                   if        slside <> 0
     C                             and slsdte <> 0
     C*                  eval      create = 'Y'
     C                   endif
     C                   endif

     C                   if        create = 'Y'
     C                   clear                   slrec
     C                   eval      slwhse = wdwhse
     C                   eval      slwhdp = wdcode
     C                   eval      sldisp = 'RPK-101-1'
     C                   eval      slaisl = 'RPK'
     C                   eval      slloc  = 101
     C                   eval      slrlvl = 1
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C                   eval      slstat = 'RP'
     C                   eval      slstyp = 'F'

     C                   write     slrec
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  writerec2   RPK-501-1
     *----------------------------------------------------------------

     C     writerec2     begsr

     C                   eval      create = 'N'
     C                   eval      keydisp = 'RPK-501-1'

      * Check to see if default already exists; pgm already ran

     C     slotkey       setll     slot2
     C     slotkey       reade     slot2
     C                   if        %eof
     C                   eval      create = 'Y'
     C                   endif
     C                   if        not %eof
     C                   if        slside <> 0
     C                             and slsdte <> 0
     C                   eval      create = 'Y'
     C                   endif
     C                   endif

     C                   if        create = 'Y'
     C                   clear                   slrec
     C                   eval      slwhse = wdwhse
     C                   eval      slwhdp = wdcode
     C                   eval      sldisp = 'RPK-501-1'
     C                   eval      slaisl = 'RPK'
     C                   eval      slloc  = 501
     C                   eval      slrlvl = 1
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C                   eval      slstat = 'RP'
     C                   eval      slstyp = 'F'

     C                   write     slrec
     C                   endif

     C                   endsr
