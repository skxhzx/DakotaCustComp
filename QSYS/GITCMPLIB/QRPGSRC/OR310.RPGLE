     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   845 Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR300     Single Order Report - Print
     *  Bob Perry
     *  25 October 2005 Created - V5.00
     *
     *  Revisions
500bA*    01/05/06  RH   5.00b
     *      - Fix: Use LABEL record to calculate picked qty.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  76        ORDH4   Not on file/End of file indicator
     *  77        ORDD1   Not on file/End of file indicator
     *  78        PIRITEM Not on file/End of file indicator
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  91        Print continuation line on headings
     *  92        Headings printed. Print detail 1 line.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordh4     if   e           k disk
     Fordd1     if   e           k disk
     Fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Frtehed    if   e           k disk
500b Flabel93   if   e           k disk
     For310pr   o    e             printer oflind(*in90)
     F                                     usropn
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *                   RPD     1   3 30
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     D desc            s             10    dim(9) ctdata perrcd(1)
     D desc2           s             10    dim(3) ctdata perrcd(1)
     *    General
     *
     D a80             s              1    dim(80)
     *
     *    Printer override
     *
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  VARIABLES
     D #pwhse          s              3  0
     D $pdev           s             10
     D $pform          s             10
     D $pwhse          s              3
     D $prtid          s              5
     D $plen           s              3  0
     D $pstr           s             60
     D brk             s              1    inz(*off)
     D count           s              3  0
     D eof             s              1
     D first           s               n
     D forever         s               n
     D l               s              1  0
     D m               s                   like(l)
     D opened          s              1
     D p#              s              1  0
     D wkprtf          s             10
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE    -  Warehouse
     *      $PRTID    -  Route Id
     *
     *    Returned Parameters
     *      *NONE
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $prtid
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     C                   move      $pwhse        #pwhse

     C     orhkey        setll     ordh4

     C                   dow       forever = forever
     C     orhkey        reade     ordh4                                  76
     C                   if        *in76 = *on
     C                   leave
     C                   else

     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *
     C                   if        *in90  or
     C                             brk = *on or
     C                             first = *on
     C                   exsr      zrzero
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *
     *  Level 1 break - Warehouse/PO
     *
     C                   if        brk = *on
     C                   eval      l = 1
     C                   endif
     *
     *  Output Headings
     *
     C                   if        *in90  or
     C                             brk = *on or
     C                             first = *on
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      first = *off
     C                   endif
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
     * Scan through and print all detail records for this order
     *
     C                   eval      count = 0
     C     ordkey        setll     ordd1
     C                   dow       *in77 = *off
     C     ordkey        reade     ordd1                                  77
     C                   if        *in77 = *off
     C                   eval      first = *off
     C     itmkey        chain     piritem                            78
     C                   if        *in78
     C                   eval      itdesc = *blanks
     C                   endif
     * item status
     C                   if        odstat = 'O'
     C                   movea     desc2(1)      w1dsts
     C                   else
     C                   if        odstat = 'P'
     C                   movea     desc2(2)      w1dsts
     C                   else
     C                   if        odstat = 'C'
     C                   movea     desc2(3)      w1dsts
     C                   endif
     C                   endif
     C                   endif
500b * Picked quantity
500b C                   eval      w1pck = 0
500b C     lbkey         setll     label93
500b C                   dow       *in75 = *off
500b C     lbkey         reade     label93                                75
500b C                   if        *in75 = *off
500b C                   eval      w1pck = w1pck + lbqpck
500b C                   iter
500b C                   else
500b C                   leave
500b C                   endif
500b C                   enddo
     *
     C                   write     detail1                              90
     C                   add       1             count
     C                   eval      *in90 = *off
     C                   eval      *in92 = *off
     C                   eval      w1dsts = *blanks
     C                   endif
     *
     * Check for page break
     C                   if        *in90
     C                   write     head1
     C                   write     head2
     C                   if        *in91 and
     C                             first <> *on
     C                   write     rphead
     C                   endif
     C                   write     columns
     C                   eval      count = 0
     C                   eval      *in90 = *off
     C                   eval      *in92 = *off
     C                   endif
     *
     C                   enddo
     *
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
     C                   add       1             lvlk(1)
     *
     C                   if        %eof
     C                   write     skip1
     C                   write     foot1
     C                   endif
     C                   endif
     C                   enddo
     *
     *  Exit program
     *
     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Key fields
     *
     *
     * Order Header file - Partial key
     *
     C     orhkey        klist
     C                   kfld                    #pwhse
     C                   kfld                    $prtid
     *
     * Order Detail file - Partial key
     *
     C     ordkey        klist
     C                   kfld                    #pwhse
     C                   kfld                    ohord
     *
     *  Key for PIRITEM file
     C     itmkey        klist
     C                   kfld                    #pwhse
     C                   kfld                    oditem
     *
     *  Key for RTEHED file
     C     rthkey        klist
     C                   kfld                    #pwhse
     C                   kfld                    ohrte
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
500b *  Key for RTEHED file
500b C     lbkey         klist
500b C                   kfld                    #pwhse
500b C                   kfld                    odord
500b C                   kfld                    oditem
500b C                   kfld                    odseq
     *
     *   Get report title and dev/form and override printer file.
     *
     C                   movel     'OR310PR '    wkprtf
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   movel     rpdev         $pdev
     C                   movel     rpform        $pform
     C                   else
     C                   eval      $pstr  = 'Single Order Report'
     C                   eval      $pdev  = '*JOB'
     C                   eval      $pform = '*STD'
     C                   endif
     C                   exsr      opnprt
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     C                   time                    time
     C                   eval      count = 0
     C                   eval      l = 2
     C                   eval      first = *on
     C                   exsr      zrzero
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   if        opened = *on
     C                   close     or310pr
     C                   endif
     *
     *      Override printer file.
     *
     *          OVRPRTF FILE(OR310PR) OUTQ(*DEV) DEV(rpdev)
     *                  FORMTYPE(rpform)
     *
     C                   movea     ovrprt(1)     a80
     *
     *    Use printer device selected by user.
     C                   if        $pdev <> '*JOB    '
     C                   movea     $pdev         a80(38)
     C                   else
500 AC                   movea     '*JOB      '  a80(38)
     C                   endif
     *
     *    Use form type selected by user.
     C                   if        $pform <> '*STD    '
     C                   movea     $pform        a80(59)
     C                   else
     C                   movea     '*STD      '  a80(59)
     C                   endif
     *
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or310pr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        brk = *off
     C                   eval      *in91 = *on
     C                   endif
     *
     C     orhkey        setll     ordh4
     C                   eval      *in90 = *off
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     #pwhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   write     head1
     C     rthkey        chain     rtehed                             79
     C                   if        not *in79
     C                   eval      w1rte = rhrte
     C                   else
     C                   eval      w1rte = *blanks
     C                   endif
     * customer order number
     C                   eval      w1cord = ohcord
     * order status
     C                   move      rhstat        p#
     C                   if        rhstat = '0'
     C                   eval      p# = 1
     C                   endif
     C                   movea     desc(p#)      w1osts
     * customer number/name and po#
     C                   eval      w1cus# = ohcust
     C                   eval      w1cnam = ohcnam
500bDC*                  eval      w1po#  = ohcpo
     *
     C                   write     head2
     C                   eval      count = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     *
     C                   add       1             lvlk(m)
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   if        l = 1
     *                    WRITETOTAL1
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      lvlk(l) = 0
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zzqtys        begsr
     *
     *  Display all qty fields as one string
     C                   eval      $pcmd = '*QTY2STR'
     C                   eval      $pqstr = *blanks
     *
     C                   call      'CVTQTY'
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pqty1            7 0
     C                   parm                    $pqty2            7 0
     C                   parm                    $pqty3            7 0
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pum3             2
     C                   parm                    $pqstr           10
     C                   parm                    $pustr           17
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Check if end of detail
     *
     C     zzchkeof      begsr
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zztotals      begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**  DESC  - Order status description
Open
Allocated
Built
Printed
Closed
Exported

Unpicked
Deleted
**  DESC2 - Order status description
Open
Processing
Closed
**   OVRPRTF statment
OVRPRTF FILE(OR310PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
