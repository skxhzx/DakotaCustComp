      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *   *** Note ****
     *   This program was copied from IV120.  The L1 level breaks are
     *   the only differences betwen the two programs.  Any changes
     *   made to IV121A may also need to be made in IV120 as well.
     *----------------------------------------------------------------
     *
     *  IV121A    Assign sheet numbers to Inventeory sheets
     *  18 Setptember 2006
     *  Jeffrey Jahnke
     *
     *  Revisions:
510bA*  06/08/07  RH   5.10b
     *    - Enh: Write records to Inventory Slot Assignment file.
     *      Remove write to Inventory Page Assignment file.
     *
710aA*  03/23/17  LMC  7.10a
     *    - Convert to RPGLE.
     *    - Enh: Write inventory history records.
     *    - Copied mods 700a & 700b from IV121.
710bA*  12/04/17  MLB  7.10b
     *    - Fix: Revised pgm to add test for savdpt > blanks at LR time
     *      before trying to execute routine, HIST. Was causing DDE error
     *      when pgm run with no pages to assign.
     *   - Pgm, IV121 needs mod 7.10b.
710cA*  12/22/17  LMC  7.10c
     *    - Enh: Database change to INVHSTD. Recompile only.
740aA*  06/06/20  RH   7.40a
     *    - Fix: If INVINUSE rec found for Dept, set INVHSTH status
     *      to closed for ICHUID, then create new INVINUSE record
     *      Program combines Dept counts, but didn't close previous.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line
     *
CLD A*    05/10/11  RH   CLD
     *      -  Enh: Revised program to not break on side of aisle,used
     *         to print sheets for PIR slots
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  78        Record locked.
     *  79        Not on file/End of file.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Finvslot   up   e           k disk
     Finvnxtp   uf a e           k disk
     Finvpage   o  a e           k disk
710aDF*invsasn   o  a e           k disk
710aAFINVSASN   UF A E           K DISK
510bD*NVPASN O   E           K        DISK                      A
710aAFinvhstH   UF A E           K DISK
710aAFinvhstD   O  A E           K DISK
710aAFINVINUSE  UF A E           K DISK
710aAFSLOT2     IF   E           K DISK
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
CLDaA /copy qcopysrc,id#citylin
730aAD client          s             10
730aAD cliloc          s             10
     D @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *----------------------------------------------------------------
     *  Constants
     *
     D @pagmx          c                   const(15)
     *----------------------------------------------------------------
     *  Data structure for IVSKEY and PVSKEY
     *
     D                 ds
     D  ivskey                 1     16
     D  ivswhs                 1      3  0
     D  ivswhd                 4      8
     D  ivsasl                 9     11
     D  ivsloc                12     14  0
     D  ivslvl                15     16  0
     *
     D                 ds
     D  pvskey                 1     16
     D  pvswhs                 1      3  0
     D  pvswhd                 4      8
     D  pvsasl                 9     11
     D  pvsloc                12     14  0
     D  pvslvl                15     16  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D count           s              2  0
     D error           s              1
     D sheet           s                   like(ivppag)
710aAD wcyccnt         s              7s 0
710aAD savdpt          s              5
740aAD savuid          s                   like(ichuid)
     *----------------------------------------------------------------
     *  Input record
     *
     Iivsrec
CLD MI                                          ivswhs        l2
CLD MI                                          ivswhd        l2
CLD MI                                          ivsstp        l2
CLD MI                                          ivsasl        l2
     I                                          ivssid        l1
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
     C     *entry        plist
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main Line
     *
     *  Start new page if level break or page maximum was reached.
     *
710aA /free
710aA   if *inl1;
710aA     if savdpt <> ivswhd;
710aA       if savdpt <> ' ';
710aA         exsr hist;
710aA       endif;
710aA     endif;
710aA     savdpt = ivswhd;
710aA   endif;
710aA /end-free
CLD DC*                  if        *inl1  or
CLD DC*                            count = @pagmx
CLD MC                   if        *inl1  and
CLD MC                             client <> cityline or
CLD MC                             *inl2  and
CLD MC                             client = cityline or
CLD MC                             count = @pagmx
     *
     *     Create page record for previous page if neccessary.
     *
     C                   if        count > 0
     C                   if        ivskey = pvskey
     C                   eval      ivpmor = *on
     C                   endif
     C                   eval      ivpvtl = *off
     C                   eval      ivpcnt = count
     C                   write     ivprec
510bD* Create inventory page assignment record.
510bD*                    EXSR ZZASGN
     C                   eval      count = 0
     C                   endif
     *
     *     Get next page number. Get out if error occured.
     *
     C                   exsr      getpag
     C                   if        error = *on
     C                   eval      *inlr = *on
     C                   goto      bottom
     C                   endif
     *
     *     Initialize fields for the next page record.
     *
     C                   clear                   ivprec
     C                   eval      ivppag = sheet
     C                   eval      ivpwhs = ivswhs
     C                   eval      ivpwhd = ivswhd
     C                   eval      ivpasl = ivsasl
     C                   eval      ivplvl = ivslvl
     C                   eval      ivpstp = ivsstp
     C                   eval      ivpfrm = ivsdsp
     C                   eval      ivpmor = *off
     *
     C                   endif
     *
     *  Update record with page number.
     *
     C                   eval      ivspag = sheet
     C                   update    ivsrec
510b * Create inventory assignment record.
510bAC                   exsr      zzasgn
     C                   add       1             count
     C                   eval      ivpto = ivsdsp
     C                   eval      pvskey = ivskey
     *
     C     bottom        tag
     *
     *  See if page record needs to be created at LR.
     *
     CLr                 if        count > 0
     CLr                 if        ivskey = pvskey
     CLr                 eval      ivpmor = *on
     CLr                 endif
     CLr                 eval      ivpcnt = count
     CLr                 write     ivprec
510dD* Create inventory page assignment record.
510dD**                   EXSR ZZASGN
     CLr                 endif
710bA*
710bACLR                 if        savdpt > ' '
710aACLR                 EXSR      HIST
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
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client
     C                   parm                    cliloc
     *
710aAC     skey          klist
710aAc                   kfld                    slwhse
710aAc                   kfld                    slwhdp
710aAc                   kfld                    sldisp

     *
710aAC     hkey          klist
710aAc                   kfld                    ichuid
710aAc                   kfld                    ichwhse
740aA*
740aAC     hkey1         klist
740aAc                   kfld                    inuuid
740aAc                   kfld                    inuwhs
     *
710aAC     ikey          klist
710aAc                   kfld                    inuwhs
710aAc                   kfld                    inuwhdp

     *
     *
     *   Clear previous program's message queue.
     *
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmsmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETPAG  Get next page (sheet) number.
     *
     C     getpag        begsr
     C                   eval      error = *off
     *
     *  Get next page record.
     *
     C     ivswhs        chain     invnxtp                            7978
     *
     *  Record locked.
     *
     C                   select
     C                   when      *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm78
     *
     *  Record not found - Start with sheet 1 and create record.
     *
     C                   when      *in79
     C                   eval      sheet = 1
     C                   eval      ivxwhs = ivswhs
     C                   eval      ivxpag = 2
     C                   write     ivxrec
     *
     *  Record found - Get next page number and update record.
     *
     C                   other
     C                   eval      sheet = ivxpag
     C                   add       1             ivxpag
     C                   update    ivxrec
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZASGN  Create Inventory Slot assignment record.
510b *          Create Inventory page assignment record.
     *
     C     zzasgn        begsr
510bD*                    Z-ADDIVPPAG    IVAPAG
510bD*                    Z-ADDIVPWHS    IVAWHS
510bD*                    MOVE IVPWHD    IVAWHD
510bD*                    MOVE '1'       IVASTA
510bD*                    MOVE *BLANKS   IVATEM
510bD*                    Z-ADD0         IVASDT
510bD*                    Z-ADD0         IVASTM
510bD*                    WRITEIVAREC
     *
510b C                   eval      ivgwhs = ivswhs
510b C                   eval      ivgpag = sheet
510b C                   eval      ivgdsp = ivsdsp
510b C                   eval      ivgwhd = ivswhd
510b C                   eval      ivgasl = ivsasl
510b C                   eval      ivgloc = ivsloc
510b C                   eval      ivglvl = ivslvl
510b C                   eval      ivghnd = ivshnd
510b C                   eval      ivgstp = ivsstp
510b C                   eval      ivgsid = ivssid
510b C                   eval      ivgdsg = ivsdsg
510b C                   eval      ivgpck = ivspck
510b C                   eval      ivgsta = *on
510b C                   eval      ivgtem = *blanks
510b C                   eval      ivgsdt = 0
510b C                   eval      ivgstm = 0
510b C                   write     ivgrec
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a previous program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSGP'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     INV7978  Record is locked.
     *
     C     zm78          begsr
     C                   eval      #msgid = 'INV7978'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   endsr
710aA*----------------------------------------------------------------
710aA*    HIST    Write cycle count history records
710aA*----------------------------------------------------------------
710aA*
710aAC     HIST          BEGSR
710aAC     *hival        setll     invhsth
710aAC                   readp     invhsth
710aAc                   IF        %EOF
710aAc                   z-add     1             ICHUID
710aAC                   ELSE
710aAC                   ADD       1             ICHUID
710aAC                   END
710aAC                   eval      ichcycnt=0
710aA /free
710aA   setll (ivswhs: savdpt) invsasn;
710aA   dou %eof(invsasn);
710aA     reade (ivswhs: savdpt) invsasn;
710aA   if %eof(invsasn);
710aA     leave;
710aA   endif;
710aA /end-free
710aA*    HEADER
710aAc                   if        wcyccnt = 0
710aA*    IN USE REFERENCE
710aAC                   eval      inuwhs = ivgwhs
710aAC                   eval      inuwhdp = savdpt
710aAC     ikey          chain     invinuse
710aAc                   if        %found
740aAc                   eval      savuid = ichuid
740aAc     hkey1         chain     invhsth
740aAc                   if        %found and
740aAc                             ichsts = '1'
740aAc                   eval      ichsts = '0'
740aAc                   update    ichrec
740aAc                   endif
740aAc                   eval      ichuid = savuid
710aAC                   eval      inuuid = ichuid
710aAC                   update    inurec
710aAc                   else
710aAC                   eval      inuuid = ichuid
710aAC                   write     inurec
710aAc                   endif
710aA*
710aAC                   eval      ichwhse=ivgwhs
710aAC                   eval      ichsts = '1'
710aAc                   eval      ichpprts = %timestamp
710aAc                   eval      ichadj = 0
710aAc                   eval      ichpstts = *loval
710aAc                   write     ichrec
710aAc                   endif
710aAc                   eval      wcyccnt = wcyccnt + 1
710aA*    DETAIL
710aAC                   eval      slwhse = ivgwhs
710aAc                   eval      slwhdp = ivgwhd
710aAc                   eval      sldisp = ivgdsp
710aAc     skey          chain     slot2
710aAc                   if        not %found
710aAc                   eval      slstk1 = 0
710aAc                   else
710aAC                   call      'SLOTQTY'
710aAC                   parm                    slstk1
710aAC                   parm                    slstk2
710aAC                   parm                    slstk3
710aA*
710aAC                   parm                    slalc1
710aAC                   parm                    slalc2
710aAC                   parm                    slalc3
710aA*
710aAC                   parm                    sltfr1
710aAC                   parm                    sltfr2
710aAC                   parm                    sltfr3
710aA*
710aAC                   parm                    slpck1
710aAC                   parm                    slpck2
710aAC                   parm                    slpck3
710aA*
710aAC                   parm                    slrcv1
710aAC                   parm                    slrcv2
710aAC                   parm                    slrcv3
710aA*
710aAC                   parm                    stock1            5 0
710aAC                   parm                    stock2            3 0
710aAC                   parm                    stock3            3 0
710aA*
710aAC                   parm                    avail1            5 0
710aAC                   parm                    avail2            3 0
710aAC                   parm                    avail3            3 0
710aAc                   endif
710aAc                   eval      icduid = ichuid
710aAc                   eval      icdbqty1 = avail1
710aAc                   eval      icdbqty2 = avail2
710aAc                   eval      icdbqty3 = avail3
710aAc                   eval      icdsldsp = ivgdsp
710aAc                   eval      icdwhsdp = ivgwhd
710aAc                   eval      icwhse = ivgwhs
710aAc                   eval      icdslcnt = 'N'
710aAc                   eval      icdsltts = %timestamp
710aAc                   write     icdrec
710aAc                   enddo
710aA*    UPDATE CYCLE COUNT
710aAc                   if        wcyccnt > 0
710aAc     hkey          chain     invhsth
710aAc                   if        %found
710aAc                   eval      ichcycnt = wcyccnt
710aAc                   update    ichrec
710aAc                   endif
710aAc                   endif
710aAc
710aAc                   eval      wcyccnt = 0
710aAC                   ENDSR
