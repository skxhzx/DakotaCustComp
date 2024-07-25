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
     *  UPD510TJB   Create repack slots for repack items/its parent
     *  31 May 2007
     *  Traci Jahnke
     *
     *  Revisions
     *
     *    05/31/07  TJ   5.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fkitcomp   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D errmsg          s             60
     D error           s              1

     *----------------------------------------------------------------
     *  Define keys
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   exsr      getrepack

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  getrepack
     *----------------------------------------------------------------

     C     getrepack     begsr

     C     *loval        setll     kitcomp
     C                   read      kitcomp
     C                   dow       not %eof
     C                   exsr      writerec
     C                   read      kitcomp
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  writerec     Create Parent and Repack Slots
     *----------------------------------------------------------------

     C     writerec      begsr

     C                   eval      error = *off

     *   Create repack slots (both the repack item and parent slots)

     C                   call      'CRTWRKORD'
     C                   parm      '*CRTRPKSLT'  $rcmd            10
     C                   parm      001           $rwhse            3 0
     C                   parm      kcitem        $ritem           15
     C                   parm      0             $rqty             5 0
     C                   parm      'M'           $rby              1
     C                   parm      ' '           $rref            15
     C                   parm      ' '           $rrtn            10
     C                   parm      ' '           $rmsg            60
     C                   parm      0             $rord             7 0
     C                   parm      0             $rndtc            8 0

     C                   if        $rrtn = '*ERROR'
     C                   eval      error = *on
     C                   eval      errmsg = $rmsg
     C                   endif

     C                   endsr

