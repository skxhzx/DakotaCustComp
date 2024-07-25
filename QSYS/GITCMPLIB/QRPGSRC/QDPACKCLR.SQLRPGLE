      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  QDPACKCLR    Packers conversion - Clear files.
     *  18 June 2006
     *  Dave Sommerville
     *
     *  Revisions
500 A*    06/18/06  DAS  5.10
     *      - Created.
     *
500 B*    06/20/06  RMC  5.10
     *      - Added additional files to clear.
     *----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*----------------------------------------------------------------
500 A
500 A /copy qcopysrc,id#packers

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D oldwhse         s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CLEAR
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500 A
500 A* If not *CLEAR, then get out.
500 A
PCK AC                   if        $pcmd <> '*CLEAR'
PCK AC                   goto      bottom
PCK AC                   endif
500 A
500 A* Get client id.
500 A
500 AC                   call      'GETCLIENT'
500 AC                   parm                    client           10
500 A
500 A* Get out if not Packers.
500 A
PCK AC                   if        client <> packers
PCK AC                   goto      bottom
PCK AC                   endif
500 A
500 A* Define old and new warehouses
500 A
PCK AC                   eval      oldwhse = 1

     * Establish the connection to local machine.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     * Clear file CHKLBL

     C/EXEC SQL
     C+  DELETE FROM CHKLBL
     C+  WHERE CLWHSE = :oldwhse
     C/END-EXEC

     * Clear file CHKPLT

     C/EXEC SQL
     C+  DELETE FROM CHKPLT
     C+  WHERE CPWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file CWEXCP

     C/EXEC SQL
     C+  DELETE FROM CWEXCP
     C+  WHERE CXWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file INVBSLH

     C/EXEC SQL
     C+  DELETE FROM INVBSLH
     C+  WHERE IBSWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVBSLT

     C/EXEC SQL
     C+  DELETE FROM INVBSLT
     C+  WHERE IBSWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVCHK

     C/EXEC SQL
     C+  DELETE FROM INVCHK
     C+  WHERE IVCWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVEXCH

     C/EXEC SQL
     C+  DELETE FROM INVEXCH
     C+  WHERE IVEWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVEXCP

     C/EXEC SQL
     C+  DELETE FROM INVEXCP
     C+  WHERE IVEWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVNXTP

     C/EXEC SQL
     C+  DELETE FROM INVNXTP
     C+  WHERE IVXWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVPAGE

     C/EXEC SQL
     C+  DELETE FROM INVPAGE
     C+  WHERE IVPWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVPAGH

     C/EXEC SQL
     C+  DELETE FROM INVPAGH
     C+  WHERE IVPWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVSLOT

     C/EXEC SQL
     C+  DELETE FROM INVSLOT
     C+  WHERE IVSWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVSLTH

     C/EXEC SQL
     C+  DELETE FROM INVSLTH
     C+  WHERE IVSWHS = :oldwhse
     C/END-EXEC

500 B* Clear file INVTEAM

     C/EXEC SQL
     C+  DELETE FROM INVTEAM
     C+  WHERE IVTWHS = :oldwhse
     C/END-EXEC

500 B* Clear file ITEMZRO

     C/EXEC SQL
     C+  DELETE FROM ITEMZRO
     C+  WHERE IZWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDC

     C/EXEC SQL
     C+  DELETE FROM ORDC
     C+  WHERE OCWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDD

     C/EXEC SQL
     C+  DELETE FROM ORDD
     C+  WHERE ODWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDH

     C/EXEC SQL
     C+  DELETE FROM ORDH
     C+  WHERE OHWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDL

     C/EXEC SQL
     C+  DELETE FROM ORDL
     C+  WHERE OLWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDRTE

     C/EXEC SQL
     C+  DELETE FROM ORDRTE
     C+  WHERE ORWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDSLCT

     C/EXEC SQL
     C+  DELETE FROM ORDSLCT
     C+  WHERE OSWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORDT

     C/EXEC SQL
     C+  DELETE FROM ORDT
     C+  WHERE OTWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file ORRTN

     C/EXEC SQL
     C+  DELETE FROM ORRTN
     C+  WHERE ORWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file PIRTRCK

     C/EXEC SQL
     C+  DELETE FROM PIRTRCK
     C+  WHERE TRWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file PLTSTP

     C/EXEC SQL
     C+  DELETE FROM PLTSTP
     C+  WHERE PSSWHS = :oldwhse
     C/END-EXEC

500 B* Clear file PLTSUM

     C/EXEC SQL
     C+  DELETE FROM PLTSUM
     C+  WHERE PSWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file PRPLFIL

     C/EXEC SQL
     C+  DELETE FROM PRPLFIL
     C+  WHERE PRWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file RPLFILE

     C/EXEC SQL
     C+  DELETE FROM RPLFILE
     C+  WHERE RLWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file RTECSUM

     C/EXEC SQL
     C+  DELETE FROM RTECSUM
     C+  WHERE RCWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file RTEHED

     C/EXEC SQL
     C+  DELETE FROM RTEHED
     C+  WHERE RHWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file RTESUM

     C/EXEC SQL
     C+  DELETE FROM RTESUM
     C+  WHERE RSWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file RTETRCK

     C/EXEC SQL
     C+  DELETE FROM RTETRCK
     C+  WHERE RTTWHS = :oldwhse
     C/END-EXEC

500 B* Clear file RTETTL

     C/EXEC SQL
     C+  DELETE FROM RTETTL
     C+  WHERE RLWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file RTEUNDO

     C/EXEC SQL
     C+  DELETE FROM RTEUNDO
     C+  WHERE RUWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file SLTRPEX

     C/EXEC SQL
     C+  DELETE FROM SLTRPEX
     C+  WHERE SEWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file VSLEXCP

     C/EXEC SQL
     C+  DELETE FROM VSLEXCP
     C+  WHERE VXWHSE = :oldwhse
     C/END-EXEC

500 B* Clear file WORKLBL

     C/EXEC SQL
     C+  DELETE FROM WORKLBL
     C+  WHERE LWWHSE = :oldwhse
     C/END-EXEC

     * Disconnect the current connection.

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC
     C
PCK AC     bottom        tag
PCK AC                   eval      *inlr = *on
