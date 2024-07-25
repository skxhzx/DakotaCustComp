640aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT726S    Stage Export - Item adjustments
     *  21 January 2011
     *  Dave Sommerville
     *
     *  This program was based on IT726. All IT726 revision comments
     *  were kept in this program. See 640 notes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
213 A*    05/20/96  DAS
213 A*      - Added fields IAWHDP, IADISP and IACWTA.
     *
411 A*    07/04/99  DAS 4.11
     *      - Created this program from IT725.
     *
416 A*    12/27/01  DAS  4.16
     *      - Added file ADJMISC.
     *      - Revised to only write a record to the export file if
     *        the adjustment code is defined for updating the Host
     *        system.
     *
500 A*    12/06/05  MLB  5.00
     *      - Enh: Revised program to not write adjustments to export
     *        file that have blank item numbers.
     *
510 A*    07/14/06  MLB  5.10
     *      - Enh: Added client custom code support to program.
510aA*    07/14/06  MLB  5.10a
     *      - Enh: Converted program to ILE.
510aA*    07/17/06  RMC  5.10a
     *      - Enh: Recompile only - added misc. fields to ITEMEXT.
510bA*    08/27/06  MLB  5.10b
     *      - Enh: ITEMEXT file changed. Recompiled program.
610aA*    01/06/10  RH   610a
     *      - Enh: Revised program to NOT export '@' system adjustment
     *
640aA*    01/21/11  DAS  640a
     *      - IT726S created.
     *      - Revised to use new LF ITEMADJ4 instead of opnqryf file.
     *      - Revised to use staging file EXPSADJ instead of EXPFADJ.
     *      - Packers code stripped out.
     *
650 A*    12/04/13  MLB  6.50
     *      - Enh: Added INFDS to EXPSADJ.
     *
700  *    06/23/15  RTR  7.00
     *      - Added check and call to send returns as adjustments.
     *
720a *    03/24/18  RTR  7.20a
     *      - Changed to not send MV adjustments EVER.
720b *    10/14/18  RTR  7.20b
     *      - Changed to use EXPSADJ2 for decimal adjustment qtys.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    09/07/09  RH   SVLa
     *      - Revised program to NOT export '@' system adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hasey
     *
HALaA*    11/11/09  JCJ  HALa
     *      - Revised program to NOT export '@' system adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    01/18/13  MLB  HKW
     *      - Revised program to map MO adj code to 17 and MP to 18.
     *        Per Carl W. Foodman doesn't support alpha adj codes.
     *      - Added file, ADJCODE to pgm.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/04/13  MLB  DRY
     *      - Revised pgm to call Host export program, BFCEIA05C to send
     *        exported adjustments to Host JDEdwards system.
     *      - Added /copy mbr, C#FILE1DS to retrieve files library to
     *        pass to Host pgm, along with whse number.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic
     *
EOPa *    10/11/18  RTR  EOPa
     *      - Revised pgm to break down UOM for adjustment
     *      - Revised pgm to handle -DZ special repack items
EOPb *    12/13/18  RTR  EOPb
     *      - Fix for DZ/HD items.
EOPc *    01/09/19  RTR  EOPc
     *      - Fixes for breakdown qty.
EOPd *    05/10/19  RTR  EOPd
     *      - Changes for new CI processing on VAM.
EOPe *    08/27/19  RTR  EOPe
     *      - Fix for CS/HD items, currently only herbs.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for ITEMADJ
     *
     *----------------------------------------------------------------
     * File Specs
     *
640aDF*temadj   up   e           k disk
640aMFitemadj4  uf   e           k disk
HKW AFadjcode   if   e           k disk    usropn
416 AFadjmisc   if   e           k disk
EOPaAfpiritem   if   e           k disk
640aDF*xpfadj   o  a e           k disk
720bDF*xpsadj   o  a e           k disk
720bMFexpsadj2  o  a e           k disk
650 AF                                     infds(file1ds)
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
SVLaA /COPY QCOPYSRC,ID#saval
HALaA /COPY QCOPYSRC,ID#halsey
HKW A /COPY QCOPYSRC,ID#hkw
DRY A /COPY QCOPYSRC,ID#dairyla
EOPaA /COPY QCOPYSRC,ID#eop
640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
510 A*
700aA*----------------------------------------------------------------
700aA* Data structure
700aA*
700aA*----------------------------------------------------------------
700aA*  *RETURNS -  Customer Returns options
700aA*----------------------------------------------------------------
700aA*
700aA* Fields
700aA*
700aA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
700aA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
700aA*    OPRFLB  -  Force return label entry. (Y/N)
700aA*    OPREXQ  -  Export Quick returns.(Y/N)
700aA*    OPRULB  -  Use label for putaway.(Y/N)
700aA*    OPREAD  -  Export as adjustments. (Y/N)
700aA*    OPREAC  -  Adjustment code to use.
700aA*
700aA* Data structure
700aA*
700aAD oprdta          ds
700aAD  oprqch                 1      1
700aAD  oprqec                 2      2
700aAD  oprflb                 3      3
700aAD  oprexq                 4      4
700aAD  oprulb                 5      5
700aAD  opread                 6      6
700aAD  opreac                 7      8
700aAD  oprend               117    117
700aAD  oprdata                1    117
700aA*
510aA*----------------------------------------------------------------
510aA*  Working variables
510aA*
640aAD batId           s             11
640aAD forever         s               n
640aAD haveBatId       s               n
DRY Ad hrtn            s              8
EOPaAD pos             s              8s 0
640aAD rtnCode         s             10
640aAD rtnMessage      s            200
640aAD stamp           s               z
640aAD stampUC         s               z
510aAD today           s              8  0
510aAD updhst          s              1
640aAD zeroUploadDate  s              8s 0
     *----------------------------------------------------------------
     *  Constants
     *
     D forevr          c                   const('1')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  Prototypes
640aA*----------------------------------------------------------------
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

DRY A*
DRY Ad DryExportPgm    pr                  Extpgm('BFCEIA05C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8

650 A*----------------------------------------------------------------
650 A*  File info data structures
650  *----------------------------------------------------------------
650 A
650 A /COPY qcopysrc,c#file1ds
650 A

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
640aA
640aA*  Loop through adjustments that have not been uploaded yet.
640aA*  (the end of the loop is at the end of the mainline code)
640aA
640aA /free
640aA    haveBatId = *off;
640aA    setll ($pWhse: zeroUploadDate) itemadj4;
640aA
640aA    dow forever = forever;
640aA
640aA      reade ($pWhse: zeroUploadDate) itemadj4;
640aA
640aA      if %eof(itemadj4);
640aA        leave;
640aA      endif;
640aA
640aA /end-free
416 A*
416 A*  Get system to update.
416 A*
416 AC     iacode        chain     adjmisc                            79
416 AC                   if        not *in79  and
416 AC                             admsys = 'D'
416 AC                   eval      updhst = *off
416 AC                   else
416 AC                   eval      updhst = *on
416 AC                   endif
HKW A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW A*    Retrieve adjcode desc. for mapping adj codes.
HKW AC     iacode        chain     adjcode
HKW AC                   if        not %found(adjcode)
HKW AC                   eval      addesc = ' '
HKW AC                   endif
HKW A*
HKW AC                   endsl
SVLa *
SVLaA*  Saval - Do not export system adj begin with '@'
SVLaAC                   if        client = saval
HALaAC                             or client = halsey
SVLaAC                   movel     iacode        temp1
SVLaAC                   if        temp1 = '@'
SVL AC                   eval      updhst = *off
SVL AC                   endif
SVL AC                   endif
     *
610aA*  Do not export system adj begin with '@'
610aAC                   movel     iacode        temp1             1
610aAC                   if        temp1 = '@'
610aAC                   eval      updhst = *off
610aAC                   endif
720aA
720aA*  Do not export MV adjustments EVER.
720aAC                   if        iacode = 'MV'
720aAC                   eval      updhst = *off
720aAC                   endif
720aA
     *  Add item adjustments to export file.
     *
416 AC                   if        updhst = *on  and
500 AC                             iaitem > *blanks
720aAC                             and iacode <> 'MV'
640aA
640aA*    If first time, get batch id.
640aA*      If error, get out.
640aA
640aAC                   if        not haveBatId
640aAC                   exsr      zzzGetBatId
640aAC                   if        batId = ' '
640aAC                   leave
640aAC                   endif
640aAC                   eval      haveBatId = *on
640aAC                   endif
640aA
640aA*    Initialize fields and write record.
640aA
     C                   exsr      filie
EOPaA /free
EOPaA    //  For Earl's, convert qtys
EOPaA    if client = EarlsOrganic;
EOPaA      exsr zzEOPconvert;
EOPaA    endif;
EOPdA    if client = EarlsOrganic
EOPdA     and iecode = 'CI'
EOPdA     and (ieqty1 < 0 or ieqty2 < 0 or ieqty3 < 0);
EOPdA      // skip writing record
EOPdA      else;
EOPaA /end-free
     C                   write     ierec                                79
EOPdAC                   endif

640aA
416 AC                   endif
     *
     *  Update item adjustment file with upload date and time.
     *
     C                   eval      iaudte = today
     C                   time                    iautim
     C                   update    iarec
     *
640aA /free
640aA    enddo;
700aA
700aA   // Check to see if returns need to be sent.
700aA   // Get options record for returns.
700aA   exec sql select opdata into :oprdata from options
700aA             where opwhse = :$pwhse
700aA               and opcode = '*RETURNS';
700aA   if sqlstt <> sqlSuccess;
700aA     clear oprdata;
700aA   endif;
700aA /end-free
700aAC                   if        opread = 'Y'
EOPaAC                   call      'OR737S2'
700aAC                   parm                    $pWhse3a
700aAC                   parm                    BatId
700aAC                   parm                    rtnCode
700aAC                   parm                    rtnMessage
700aAC                   if        BatId <> *blank
700aAC                   eval      haveBatId = *on
700aAC                   endif
700aAC                   endif
700aA /free
640aA
640aA    if haveBatId;
640aA      exsr zzzEnd;
DRY A
DRY A      if client = Dairyland;
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm($pwhse:batid:f1library:hrtn);
DRY A        endif;
DRY A      endif;
DRY A
640aA    endif;
640aA
640aA /end-free
     C     bottom        tag
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client           10
510 AC                   parm                    clientloc        10
510 A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW AC                   if        not %open(adjcode)
HKW AC                   open      adjcode
HKW AC                   endif
HKW AC                   endsl
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILIE    Fill export fields.
     *
     C     filie         begsr
     *
     *  Initialize record
     *
     C                   clear                   ierec
     *
     *  Move fields from item adjustment file to export file.
     *
     C                   eval      iewhse = iawhse
     C                   eval      ieitem = iaitem
     C                   eval      iedate = iadate
     C                   eval      ietime = iatime
     C                   eval      ieby = iaby
213 AC                   eval      iewhdp = iawhdp
213 AC                   eval      iedisp = iadisp
213 AC                   eval      iecwta = iacwta
     C                   eval      ieqty1 = iaqty1
     C                   eval      ieqty2 = iaqty2
     C                   eval      ieqty3 = iaqty3
HKW A*
HKW AC                   select
HKW AC                   when      client = hearnkirkwood
HKW A*
HKW AC                   if           (iacode = 'MO'
HKW AC                              or iacode = 'MP')
HKW AC                             and %subst(addesc:29:2) > ' '
HKW AC                   eval      iecode = %subst(addesc:29:2)
HKW AC                   else
HKW AC                   eval      iecode = iacode
HKW AC                   endif
HKW AC
HKW AC                   other
HKW A*
     C                   eval      iecode = iacode
     C                   endsl
HKW A*
     C                   eval      iememo = iamemo

640aAC                   exsr      zzzGetStamps
640aAC                   eval      iebatid = batId
640aAC                   eval      iestatus = 'R'
640aAC                   eval      ieststs = stamp
640aAC                   eval      iestsuc = stampuc
640aAC                   eval      ieaddts = stamp
640aAC                   eval      ieadduc = stampuc
     *
     C                   endsr

EOPaA*----------------------------------------------------------------
EOPaA*  zzEOPConvert   Earls - Convert qty for breakdown
EOPaA*----------------------------------------------------------------
EOPaA
EOPaA /free
EOPaA   begsr zzEOPConvert;
EOPaA
EOPaA     chain (iawhse: iaitem) piritem;
EOPaA     if %found();
EOPaA       // Look for '-DZ' 2.5 DZ repack item;
EOPaA       pos = %scan('-DZ': ititem);
EOPaA       select;
EOPaA         when pos > 0;
EOPaA           ieitem = %subst(ititem: 1: pos-1);
EOPaA         when itum1 = 'D2';
EOPaA           ieqty1 = (ieqty1 * 2.5) + (ieqty2 / 2);
EOPaA           ieqty2 = 0;
EOPeA         when itum1 = 'CS' and itum2 = 'HD';
EOPeA           ieqty1 = (ieqty1 * 2) + ieqty2;
EOPeA           ieqty2 = 0;
EOPbM         when itflg1 = 'Y' and itum2 = 'HD' and itumq2 = 2;
EOPbM           ieqty1 = ieqty1 + (ieqty2 / itumq2);
EOPaA           ieqty2 = 0;
EOPcA         when itflg1 = 'Y';
EOPcA           ieqty1 = (ieqty1 * itumq2) + ieqty2;
EOPcA           ieqty2 = 0;
EOPaA       endsl;
EOPcA       if ieqty3 <> 0 and itum3 = 'HD';
EOPcA         ieqty1 = ieqty1 + (ieqty3 / 2);
EOPcA         ieqty3 = 0;
EOPaA       endif;
EOPaA     endif;
EOPaA
EOPdA     if iecode = 'CI';
EOPdA       select;
EOPdA         when %subst(iememo:1:3) = 'Fr ';
EOPdA           eval iememo = %subst(iememo:4:8);
EOPdA         when %subst(iememo:1:5) = 'From ';
EOPdA           eval iememo = %subst(iememo:6:8);
EOPdA       endsl;
EOPdA     endif;
EOPaA
EOPaA   endsr; // zzEOPConvert
EOPaA /end-free

640aA*----------------------------------------------------------------
640aA*  zzzGetBatId    Get batch id
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPADJUST': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

      /end-free
     c                   endsr
