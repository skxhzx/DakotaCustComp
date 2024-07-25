      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *
     *   Any changes made to this program, please check IV121A which
     *   is identical with the exception of no level check on LVL
     *
     *
     *----------------------------------------------------------------
     *  IV121     Print inventory sheets - Assign sheet numbers
     *  13 February 1996
     *  Dave Sommerville
     *
     *  Revisions:
408 A*    01/12/97  RH    4.08
     *      - Re-compiled, INVSLOT file changed.
409 A*    07/14/98  RH    4.09
     *      - When handstack or virtual slots are continued from
     *        one page to the next, set IVPMOR=*ON for leading page.
414aA*    05/11/00  RH    4.14
     *      - Re-compiled, INVSLOT file changed.
416 A*  09/25/01  RH   4.16
     *    - Recompile - INVSLOT file changed.
510aA*  07/12/06  RH   5.10a
     *    - Enh: Write records to Inventory Page Assignment file.
510bA*  06/08/07  RH   5.10b
     *    - Enh: Write records to Inventory Slot Assignment file.
     *      Remove write to Inventory Page Assignment file.
700aA*  08/03/16  MR   7.00a
     *    - Convert to RPGLE.
     *    - Enh: Write inventory history records.
700bA*  09/14/16  LMC  7.00b
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
     *
710aA*  03/23/17  LMC  7.10a
     *    - Fix: Fields ICHADJ & ICHPSTTS need to be initialized
     *      on add of invhsth record.
710bA*  12/04/17  MLB  7.10b
     *    - Fix: Revised pgm to add test for savdpt > blanks at LR time
     *      before trying to execute routine, HIST. Was causing DDE error
     *      when pgm run with no pages to assign.
     *   - Pgm, IV121A needs mod 7.10b.
710cA*  12/22/17  LMC  7.10c
     *    - Enh: Database change to INVHSTD. Recompile only.
740aA*  06/06/20  RH   7.40a
     *    - Fix: If INVINUSE rec found for Dept, set INVHSTH status
     *      to closed for ICHUID, then create new INVINUSE record
     *      Program combines Dept counts, but didn't close previous.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  78        Record locked.
     *  79        Not on file/End of file.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FINVSLOT   UP   E           K DISK
     FINVNXTP   UF A E           K DISK
     FINVPAGE   O  A E           K DISK
700aAFINVSASN   UF A E           K DISK
700aDF*INVSASN   O  A E           K DISK
510bD*NVPASN O   E           K        DISK                      A
700bDF*ICHCNTH   UF A E           K DISK
700bAFinvhstH   UF A E           K DISK
700bDF*ICDCNTD   O  A E           K DISK
700bAFinvhstD   O  A E           K DISK
700aAFINVINUSE  UF A E           K DISK
700aAFSLOT2     IF   E           K DISK
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *----------------------------------------------------------------
     *  Constants
     *
     D @PAGMX          C                   CONST(15)
     *----------------------------------------------------------------
409 A*  Data structure for IVSKEY and PVSKEY
409 A*
409 AD                 DS
409 AD  IVSKEY                 1     16
409 AD  IVSWHS                 1      3  0
409 AD  IVSWHD                 4      8
409 AD  IVSASL                 9     11
409 AD  IVSLOC                12     14  0
409 AD  IVSLVL                15     16  0
409 A*
409 AD                 DS
409 AD  PVSKEY                 1     16
409 AD  PVSWHS                 1      3  0
409 AD  PVSWHD                 4      8
409 AD  PVSASL                 9     11
409 AD  PVSLOC                12     14  0
409 AD  PVSLVL                15     16  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #MSGF           C                   CONST('PIRMSGF   ')
     *
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D COUNT           s              2  0
     D ERROR           s              1
     D SHEET           s                   like(IVPPAG)
     D wcyccnt         s              7s 0
700bAD savdpt          s              5
740aAD savuid          s                   like(ichuid)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     *----------------------------------------------------------------
     *  Input record
     *
     IIVSREC
     I                                          IVSWHS        L1
     I                                          IVSWHD        L1
     I                                          IVSSTP        L1
     I                                          IVSASL        L1
     I                                          IVSSID        L1
510baI                                          IVSLVL        L1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Records updated succesfully
     *              *PGMQ    - Error occured. Message sent to prv program.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *ENTRY        PLIST
     C                   PARM                    $PRTN             8
     *----------------------------------------------------------------
     *  Main Line
     *
     *  Start new page if level break or page maximum was reached.
     *
700bA /free
700bA   if *inl1;
700bA     if savdpt <> ivswhd;
700bA       if savdpt <> ' ';
700bA         exsr hist;
700bA       endif;
700bA     endif;
700bA     savdpt = ivswhd;
700bA   endif;
700bA /end-free
     C                   IF        *INL1  or
     C                             COUNT = @PAGMX
     *
     *     Create page record for previous page if neccessary.
     *
     C                   IF        COUNT > 0
409 AC                   IF        IVSKEY = PVSKEY
409 AC                   MOVE      *ON           IVPMOR
409 AC                   ENDIF
409 AC                   MOVE      *OFF          IVPVTL
     C                   Z-ADD     COUNT         IVPCNT
     C                   WRITE     IVPREC
510b * Create inventory page assignment record.
510bD*                    EXSR ZZASGN
     C                   Z-ADD     0             COUNT
     C                   ENDIF
     *
     *     Get next page number. Get out if error occured.
     *
     C                   EXSR      GETPAG
     C                   IF        ERROR = *ON
     C                   MOVE      *ON           *INLR
     C                   GOTO      BOTTOM
     C                   ENDIF
     *
     *     Initialize fields for the next page record.
     *
     C                   CLEAR                   IVPREC
     C                   Z-ADD     SHEET         IVPPAG
     C                   Z-ADD     IVSWHS        IVPWHS
     C                   MOVE      IVSWHD        IVPWHD
     C                   MOVE      IVSASL        IVPASL
     C                   Z-ADD     IVSLVL        IVPLVL
     C                   MOVE      IVSSTP        IVPSTP
     C                   MOVE      IVSDSP        IVPFRM
409 AC                   MOVE      *OFF          IVPMOR
     *
     C                   ENDIF
     *
     *  Update record with page number.
     *
     C                   Z-ADD     SHEET         IVSPAG
     C                   UPDATE    IVSREC
510b * Create inventory assignment record.
510bAC                   EXSR      ZZASGN
     C                   ADD       1             COUNT
     C                   MOVE      IVSDSP        IVPTO
409 AC                   MOVE      IVSKEY        PVSKEY
     *
     C     BOTTOM        TAG
     *
     *  See if page record needs to be created at LR.
     *
     CLR                 IF        COUNT > 0
409 ACLR                 IF        IVSKEY = PVSKEY
409 ACLR                 MOVE      *ON           IVPMOR
409 ACLR                 ENDIF
     CLR                 Z-ADD     COUNT         IVPCNT
     CLR                 WRITE     IVPREC
510a * Create inventory page assignment record.
510bD**                   EXSR ZZASGN
     CLR                 ENDIF
710bA*
710bACLR                 if        savdpt > ' '
700aACLR                 EXSR      HIST
710bACLR                 endif
710bA*
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *INZSR        BEGSR
     *
700aAC     skey          klist
700aAc                   kfld                    slwhse
700aAc                   kfld                    slwhdp
700aAc                   kfld                    sldisp

     *
700aAC     hkey          klist
700aAc                   kfld                    ichuid
     c                   kfld                    ichwhse
740aA*
740aAC     hkey1         klist
740aAc                   kfld                    inuuid
740aAc                   kfld                    inuwhs
     *
700aAC     ikey          klist
700aAc                   kfld                    inuwhs
700bAc                   kfld                    inuwhdp

     *
     *   Clear previous program's message queue.
     *
     C                   MOVE      '*CLEAR '     #MSGID
     C                   MOVE      '*NULL  '     #MSGTP
     C                   EXSR      ZMSMSG
     C                   ENDSR
     *----------------------------------------------------------------
     *
     *  GETPAG  Get next page (sheet) number.
     *
     C     GETPAG        BEGSR
     C                   MOVE      *OFF          ERROR
     *
     *  Get next page record.
     *
     C     IVSWHS        CHAIN     INVNXTP                            7978
     *
     *  Record locked.
     *
     C                   SELECT
     C                   WHEN      *IN78
     C                   MOVE      *ON           ERROR
     C                   MOVE      '*PGMQ   '    $PRTN
     C                   EXSR      ZM78
     *
     *  Record not found - Start with sheet 1 and create record.
     *
     C                   WHEN      *IN79
     C                   Z-ADD     1             SHEET
     C                   Z-ADD     IVSWHS        IVXWHS
     C                   Z-ADD     2             IVXPAG
     C                   WRITE     IVXREC
     *
     *  Record found - Get next page number and update record.
     *
     C                   OTHER
     C                   Z-ADD     IVXPAG        SHEET
     C                   ADD       1             IVXPAG
     C                   UPDATE    IVXREC
     *
     C                   ENDSL
     *
     C                   ENDSR
510a *----------------------------------------------------------------
510a *
510a *  ZZASGN  Create Inventory Slot assignment record.
510a *          Create Inventory page assignment record.
510a *
510a C     ZZASGN        BEGSR
510bD*                    Z-ADDIVPPAG    IVAPAG
510bD*                    Z-ADDIVPWHS    IVAWHS
510bD*                    MOVE IVPWHD    IVAWHD
510bD*                    MOVE '1'       IVASTA
510bD*                    MOVE *BLANKS   IVATEM
510bD*                    Z-ADD0         IVASDT
510bD*                    Z-ADD0         IVASTM
510bD*                    WRITEIVAREC
510aD*
510b C                   Z-ADD     IVSWHS        IVGWHS
510b C                   Z-ADD     SHEET         IVGPAG
510b C                   MOVE      IVSDSP        IVGDSP
510b C                   MOVE      IVSWHD        IVGWHD
510b C                   MOVE      IVSASL        IVGASL
510b C                   MOVE      IVSLOC        IVGLOC
510b C                   MOVE      IVSLVL        IVGLVL
510b C                   MOVE      IVSHND        IVGHND
510b C                   MOVE      IVSSTP        IVGSTP
510b C                   Z-ADD     IVSSID        IVGSID
510b C                   MOVE      IVSDSG        IVGDSG
510b C                   MOVE      IVSPCK        IVGPCK
510b C                   MOVE      '1'           IVGSTA
510b C                   MOVE      *BLANKS       IVGTEM
510b C                   Z-ADD     0             IVGSDT
510b C                   Z-ADD     0             IVGSTM
510b C                   WRITE     IVGREC
510a C                   ENDSR
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a previous program msgq
     *
     C     ZMSMSG        BEGSR
     C                   IF        $MSGF = *BLANKS
     C                   MOVE      #MSGF         $MSGF
     C                   ENDIF
     C                   CALL      'PUTMSGP'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID
     C                   PARM                    #MSGTP
     C                   PARM                    #MSGDT
     C                   PARM      #PROG         #PGMQ2           10
     C                   PARM                    #MSGK             4
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     INV7978  Record is locked.
     *
     C     ZM78          BEGSR
     C                   MOVE      'INV7978'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVE      *BLANKS       $MD
     C                   EXSR      ZMSMSG
     C                   ENDSR
700aA*----------------------------------------------------------------
700aA*    HIST    Write cycle count history records
700aA*----------------------------------------------------------------
700aA*
700aAC     HIST          BEGSR
700bDC*    *hival        setll     ichcnth
700bDC*                  readp     ichcnth
700bMC     *hival        setll     invhsth
700bMC                   readp     invhsth
700aAc                   IF        %EOF
700aAc                   z-add     1             ICHUID
700aAC                   ELSE
700aAC                   ADD       1             ICHUID
700aAC                   END
700aAC                   eval      ichcycnt=0
700ba /free
700bA   setll (ivswhs: savdpt) invsasn;
700bA   dou %eof(invsasn);
700bA     reade (ivswhs: savdpt) invsasn;
700bA   if %eof(invsasn);
700bA     leave;
700bA   endif;
700ba /end-free
700bDC*    *loval        setll     invsasn
700bDc*                  DOU       %EOF
700bDc*                  read      invsasn
700bDc*                  if        %EOF
700bDc*                  leave
700bDc*                  endif
700aA*    HEADER
700aAc                   if        wcyccnt = 0
700aA*    IN USE REFERENCE
700aAC                   eval      inuwhs = ivgwhs
700bAC                   eval      inuwhdp = savdpt
700aAC     ikey          chain     invinuse
700aAc                   if        %found
740aAc                   eval      savuid = ichuid
740aAc     hkey1         chain     invhsth
740aAc                   if        %found and
740aAc                             ichsts = '1'
740aAc                   eval      ichsts = '0'
740aAc                   update    ichrec
740aAc                   endif
740aAc                   eval      ichuid = savuid
700aAC                   eval      inuuid = ichuid
700aAC                   update    inurec
700aAc                   else
700aAC                   eval      inuuid = ichuid
700aAC                   write     inurec
700aAc                   endif
700aA*
700aAC                   eval      ichwhse=ivgwhs
700aAC                   eval      ichsts = '1'
700aAc                   eval      ichpprts = %timestamp
710aAc                   eval      ichadj = 0
710aAc                   eval      ichpstts = *loval
700aAc                   write     ichrec
700aAc                   endif
700aAc                   eval      wcyccnt = wcyccnt + 1
700aA*    DETAIL
700aAC                   eval      slwhse = ivgwhs
700aAc                   eval      slwhdp = ivgwhd
700aAc                   eval      sldisp = ivgdsp
700aAc     skey          chain     slot2
700aAc                   if        not %found
700aAc                   eval      slstk1 = 0
700aAc                   else
700aAC                   call      'SLOTQTY'
700aAC                   parm                    slstk1
700aAC                   parm                    slstk2
700aAC                   parm                    slstk3
700aA*
700aAC                   parm                    slalc1
700aAC                   parm                    slalc2
700aAC                   parm                    slalc3
700aA*
700aAC                   parm                    sltfr1
700aAC                   parm                    sltfr2
700aAC                   parm                    sltfr3
700aA*
700aAC                   parm                    slpck1
700aAC                   parm                    slpck2
700aAC                   parm                    slpck3
700aA*
700aAC                   parm                    slrcv1
700aAC                   parm                    slrcv2
700aAC                   parm                    slrcv3
700aA*
700aAC                   parm                    stock1            5 0
700aAC                   parm                    stock2            3 0
700aAC                   parm                    stock3            3 0
700aA*
700aAC                   parm                    avail1            5 0
700aAC                   parm                    avail2            3 0
700aAC                   parm                    avail3            3 0
700aAc                   endif
     c                   eval      icduid = ichuid
700aAc                   eval      icdbqty1 = avail1
700aAc                   eval      icdbqty2 = avail2
700aAc                   eval      icdbqty3 = avail3
700aAc                   eval      icdsldsp = ivgdsp
700aAc                   eval      icdwhsdp = ivgwhd
700bAc                   eval      icwhse = ivgwhs
700aAc                   eval      icdslcnt = 'N'
700aAc                   eval      icdsltts = %timestamp
700aAc                   write     icdrec
700aAc                   enddo
700aA*    UPDATE CYCLE COUNT
700aAc                   if        wcyccnt > 0
700bDc*    hkey          chain     ichcnth
700bMc     hkey          chain     invhsth
700aAc                   if        %found
700aAc                   eval      ichcycnt = wcyccnt
700aAc                   update    ichrec
700aAc                   endif
700aAc                   endif
700aAc
700bAc                   eval      wcyccnt = 0
700aAC                   ENDSR
