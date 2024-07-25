     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  NOTE!!!!   MUST BE COMPILED WITH THE FOLLOWING OPTIONS:
     *             COMMIT(*NONE) CLOSQLCSR(*ENDMOD)
     *
     *  TIEHIGHS  Export tie/high info - Post - Staging
     *  28 January 2011
     *  Jose G. Duque
     *                     Copied from Pirmodscbi, compiled into
     *                     Pircstm700 - it was not found in N.V.
     *                     7/20/15
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for TIEHIGHCC
     *
     *  Note:     TIEHIGHCC is used instead of TIEHIGHC because the latter
     *            is a single field record. That was the way MainFrame want
     *            it,unformatted. The file is created by query "Tiehighc",
     *            it needs to be changed to write a record formatted as the
     *            record found in file TIEHIGHCC below.
     *
     *----------------------------------------------------------------
     F*  Client Custom Revisions
     F*
CBI AF*    09/12/13  CBI-JGD
     F*      Add logic for new EXPSTIHIGH field "TESLOTYP", this new
     F*      field carries the slot definition.
     F*
     E*----------------------------------------------------------------
     * File Specs
     *
416 AFtiehighcc if   e           k disk
640aMFexpstihigho  a e           k disk
510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*
SVLaA /COPY QCOPYSRC,ID#saval
HALaA /COPY QCOPYSRC,ID#halsey
640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
510 A*
510aA*----------------------------------------------------------------
510aA*  Working variables
510aA*
640aAD batId           s             11
640aAD forever         s               n
640aAD haveBatId       s               n
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

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

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
640aA*  This is a simple read/write process that loops through
640aA*  "Slotted Items Tie/High: to be uploaded. The input
640aA*  file "Tiehigcc" (new in test) created by CLP Getiehigh
640aA*  remotelly executed from the mainframe.
640aA*  (the end of the loop is at the end of the mainline code)
640aA
640aA /free
640aA    haveBatId = *off;
640aA
640aA    dow forever = forever;
640aA
640aA      read tiehighcc;
640aA
640aA      if %eof(tiehighcc);
640aA        leave;
640aA      endif;
640aA
640aA /end-free
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
     C                   write     terrec                               79
640aA
     *
640aA /free
640aA    enddo;
640aA
640aA    if haveBatId;
640aA      exsr zzzEnd;
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
     C                   clear                   terrec
     *
     *  Move fields from cases loaded file to export file
     *  and set its control fields up.
     *
640aAC                   exsr      zzzGetStamps
     C                   eval      tewhse   = twhse
     C                   eval      teitem   = titem
     C                   eval      tedisp   = tdisp
     C                   eval      tetie    = ttie
     C                   eval      tehigh   = thigh
CBI AC                   eval      teslotyp = tslotyp

640aAC                   exsr      zzzGetStamps
640aAC                   eval      tebatid  = batId
640aAC                   eval      testatus = 'R'
640aAC                   eval      teststs  = stamp
640aAC                   eval      testsuc  = stampuc
640aAC                   eval      teaddts  = stamp
640aAC                   eval      teadduc  = stampuc
     *
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetBatId    Get batch id
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPCBITIHI': 'W':
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
