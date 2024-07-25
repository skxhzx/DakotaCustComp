      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  TOTE      Creates file to ftp TOTE/TRAX for CASHWA
     *  15 March 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions:
     *
CWDaA*    03/15/12  LMC  CWDa
     *      - Created.
650aA*    11/25/14  JCJ  650a
     *      - Recompiled for TOTEDATA change of TGSEQ# from 3,0 to 5,0
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. TOTEHDR file had order id added
     *        to make file key unique.
     *
     *----------------------------------------------------------------
CWDaA*----------------------------------------------------------------
CWDaA*  Client Custom Revisions: CashWa
CWDaA*
CWDaA*    03/19/12  LMC  CWDa
     *      - Added call to TOTE for export of file for photo link.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *
     *    Input Parameters
     *      $pwhse       Warehouse number
     *      $prteid      Route id
     *      $prte        Customer route number
     *      $ptrn#       Transaction Number
     *
     *    Output Parameters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     ftotehdr1  if   e           k disk
     fordp3     if   e           k disk
     flabel33   if   e           k disk
     fpltsum9   if   e           k disk    prefix(p_)
     Ftotedata  o    e           k disk

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

     D client          s             10
     D/COPY QCOPYSRC,ID#CASHWA

     *----------------------------------------------------------------
     *  Data conversion data structure
     *----------------------------------------------------------------

     D currdatestamp   s               z

     D dateconv        ds
     D  tsdatetime             1     26
     D  tsyear                 1      4
     D  tsmonth                6      7
     D  tsday                  9     10
     D  tshour                12     13
     D  tsmin                 15     16
     D  tssec                 18     19
     D  tssbsec               21     26

     *----------------------------------------------------------------
     *  Re-definition data structures
     *----------------------------------------------------------------



     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d $pwhse          s              3  0
     d xswhse          s              3  0
     d $prteid         s              5
     d $prte           s              5
     d $ptrn#          s              7  0
     d $totefound      s              1
     d*xstrn#          s              7  0
     d $pcmd           s              8
     d $pmbr           s             10
     d $pfile          s             30
     d $rrtn           s             10
     d $rmsg           s             30
     D currstamp       s               z
     D gottotenum      s              1
     D len             S              3s 0 inz(0)
     D start           S              3s 0 inz(0)
     D totecnt         S              3s 0
     D useq#           S              5
     d $wrk9           s              9
     d w3              s              3
     d w2              s              2
     d w1              s              1

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $pcmd
     C                   parm                    $prteid
     C                   parm                    $prte
     C                   parm                    $ptrn#
     C                   parm                    $totefound

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c                   exsr      zzinz2


     c                   Select
     c                   when      $pcmd = '*CREATE'
     c                   exsr      zzcreate
     c                   when      $pcmd = '*SEND  '
     c                   exsr      zzsend
     C                   endsl
     c                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  procetoteftp - Process Tote File FTP.
     *----------------------------------------------------------------

     C     proctoteftp   begsr

     *    Call FTP program to send file to CASHWA
     C                   call      'TOTEFTP'
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $prteid
     C                   parm                    $prte
     C                   parm                    $ptrn#
     C                   parm      *blanks       $pmbr
     C                   parm      *blanks       $pfile
     C                   parm      *blanks       $rrtn
     C                   parm      *blanks       $rmsg

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Extra program initialization.
     *----------------------------------------------------------------

     c     zzinz2        begsr

     * Key definitions

     *  Define partial key for ordp3

     c     ordp3tote     klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid
     c                   kfld                    tohml#

     *  Define partial key for ordp3

     c     ordp3detail   klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid
     c                   kfld                    lblbl#

     *
     *  Define partial key for totehdr file
     *
     c     totehdrky     klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid

     *
     *  Define partial key for label33 file
     *
     *
     c     label33ky     klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid
     c                   kfld                    tohtr#

     *  Define key for ordh

     c     ordhkey       klist
     c                   kfld                    $pwhse
     c                   kfld                    orpord

     c     pltsumky      klist
     c                   kfld                    $pwhse
     c                   kfld                    $prteid
     c                   kfld                    psszon
     c                   kfld                    lbstop

     *  Set initial values.
     c                   eval      xswhse = $pwhse

     c                   endsr
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id

     c                   call      'GETCLIENT'
     c                   parm                    client

     c                   endsr

     *----------------------------------------------------------------
     *  zzcreate  create totedata records only
     *----------------------------------------------------------------

      /free
       begsr zzcreate;

         // first check to make sure tran# belongs to a tote
         chain ($ptrn#) totehdr1;
         $totefound = ' ';
         if %found(totehdr1) and $prteid = tohrid;
           $totefound = 'Y';
         else;
           $totefound = ' ';
         endif;
         if $totefound = ' ';
           leavesr;
         endif;
         // continue if transaction is a tote
         tgwhse = $pwhse;
         tgrtid = $prteid;
         tgrte  = $prte;
         tgtrn# = $ptrn#;
         // now get the data for the detail records
         setll ($pwhse: $prteid: tohtr#) label33;
         dow forever = forever;
           reade ($pwhse: $prteid: tohtr#) label33;
           if %eof(label33);
             leave;
           endif;
           tgcord# = ohcord;
           tgseq# = odor2;
           tgitem = lbitem;
           tgpckq = lbqpck;
           // now have to get the correct tote number needed
           if gottotenum = ' ';
             totecnt = 0;
             setll ($pwhse: $prteid: psszon: lbstop) pltsum9;
             dow forever = forever;
               reade ($pwhse: $prteid: psszon: lbstop) pltsum9;
               if %eof(pltsum9);
                 leave;
               endif;
               totecnt = totecnt + 1;
               if p_pstrn# = $ptrn#;
                 gottotenum = 'Y';
                 leave;
               endif;
             enddo;
           endif;
           tghcnt = totecnt;
           tgtrax = ' ';
           // write the tote data header record
           write tgrec;
         enddo;

         // Now process the tote record
         chain ($pwhse: $prteid: tohml#) ordp3;
         if %found(ordp3);
           tgcord# = 0;
           tgseq# = 0;
           tgpckq = 0;
           tgitem = ' ';
           useq# = %editc(orpup#:'X');
           tgtrax = (orprid) + (useq#);
           write tgrec;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzsend
     *----------------------------------------------------------------

     c     zzsend        begsr

     c                   exsr      proctoteftp

     C     endsend       endsr


