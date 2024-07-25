     H DFTACTGRP(*NO) ACTGRP(*CALLER) BNDDIR('QC2LE') EXPROPTS(*RESDECPOS)
     H DATFMT(*ISO)   TIMFMT(*ISO)    OPTION(*NODEBUGIO)
      *----------------------------------------------------------------
      * DSPDQER  - Display Data Queue Entries                     v4r2
      * Copyright (C) 06/11/1993  Craig Rutledge   <craig_rutledge@mohawkind.com>
      * This program is free software, you can redistribute it and/or modify it under the terms
      * of the GNU General Public License as published by the Free Software Foundation.
      * --------
      *
      * 5/7/2001 V2 - rewrite.  Replace DMPOBJ logic with API to do
      * non-destructive display of dataq entries as messages.
      *
      * Thanks to Dennis Lovelady (www.lovelady.com) this program now uses
      * a user space as a retrieve variable.  Not quite a documented
      * feature, but it works! Now you can retrieve up to 12Meg of entries.
      * If this technique causes anyone problems, please advise me.
      *
      * I do NOT understand 1) why IBM made this API so radically different
      * than the normal qrcvdatq call.  2) why in heck they didn't make
      * this a user space api or at least give a continuation handle so
      * I could get all entries.  Almost makes you want to learn Unix.
      * 6/25/2001 - scan through entries before they are sent to screen to make sure no
      * hex data less than x'40' is embedded.
      * 11/09/2001 - Thomas Raddatz: Changed F4 to F11 to unfold/fold subfile.
      *                              Added hexadecimal display mode.
      *                              Added data column offset.
      * 12/05/2001 - Craig Rutledge: Subfile remains on same screen during Fkeys.
      *                              Added F19-column shift left
      *                              Added F20-column shift right
      * PTF note:  Api qmhrdqm requires PTF
      * sf63313 v4r2, sf63312 v4r3, sf62994 v4r4, sf63182 v5r1
      * be installed on your system to view keyed data queue entrys.
      *
      * 02/02/22  DAS  750a
      *   - Revised to include key in output.
      *   - Revised to chop displayed value to message size
      *
      *----------------------------------------------------------------
      * Program Summary:
      * Call API to retrieve data queue object description
      * Extract entries and load to subfile
      * Display subfile
      *----------------------------------------------------------------
      * API (application program interfaces) used:
      * QMHQRDQD  display data queue object description
      * QMHRDQM   retrieve dataq entries
      *----------------------------------------------------------------
     Fdspdqed   cf   e             workstn sfile(data1:rrn1)
     F                                     infds(dsinf)
      *----------------------------------------------------------------
      *  allow subfile to stay on current screen
     D dsinf           ds
     D   fkey                         1    overlay(dsinf:369)
     D   bgrrn               378    379i 0
     D bgrrnsav        s                   like(bgrrn)
     D  f03            c                   const(X'33')
     D  f05            c                   const(X'35')
     D  f10            c                   const(X'3A')
     D  f11            c                   const(X'3B')
     D  f12            c                   const(X'3C')
     D  f19            C                   const(X'B7')
     D  f20            C                   const(X'B8')
      *
     D rrn1            s              5u 0
     D torecNum        s              5u 0
     D aa              s              5u 0 inz
     D ff              s              5u 0 inz
     D mvr             s              5u 0 inz
     D Shift           s              5u 0 inz(58)
     D hex40           s              1    inz(x'40')
     D cSflPag         c                   const(7)
     D sflDspPag       s             10I 0

     D lastOffset      s             10I 0
     D msgLen          s             10I 0
     D

      *
      *----------------------------------------------------------------
      * Define parms for QMHQRDQD retrieve dataq description.
      *----------------------------------------------------------------
     D qrcvar          ds                  inz
     D  qMsgLength                   10i 0 overlay(qrcvar:9)
     D  qKeyLength                   10i 0 overlay(qrcvar:13)
     D  qAccessTyp            17     17
     D  qText                 20     69
     D  qTrimLen                     10i 0 inz
     D v0200len        s             10i 0
     D ExitPgmFlg      s              1    inz(*off)
      *
      *----------------------------------------------------------------
      * Define parms for QMHRDQM retrieve dataq entries
      *----------------------------------------------------------------
     D vrcvar          ds                  based(uheadptr)
     D vBytesReturned                10i 0 overlay(vrcvar:1)
     D vBytesAvail                   10i 0 overlay(vrcvar:5)
     D vNumMsgRtn                    10i 0 overlay(vrcvar:9)
     D vNumMsgAvl                    10i 0 overlay(vrcvar:13)                                      d
     D vKeyLenRtn                    10i 0 overlay(vrcvar:17)
     D vKeyLenAvl                    10i 0 overlay(vrcvar:21)
     D vMsgTxtRtn                    10i 0 overlay(vrcvar:25)
     D vMsgTxtAvl                    10i 0 overlay(vrcvar:29)
     D vEntryLenRtn                  10i 0 overlay(vrcvar:33)
     D vEntryLenAvl                  10i 0 overlay(vrcvar:37)
     D vOffset1stEnt                 10i 0 overlay(vrcvar:41)
     D vQLib                         10    overlay(vrcvar:45)
     D vMessageData                  20    varying
     D uheadptr        s               *   inz(*null)
      *
      *      ---------------------------------------------------------------------------------------
      *      Move pointer through message entries
      *      ---------------------------------------------------------------------------------------
     D vListEntry      ds                  based(vListPtr)
     D   vNextEntry                  10i 0
     D   vDateTime                    8                                         TOD format
     D   vMsgVar                   1000                                         variable text
      *
      *      ---------------------------------------------------------------------------------------
      *      Message selection info - RDQS0100 nonkeyed queues  RDQS0200 Keyed data queues
      *      ---------------------------------------------------------------------------------------
     D vRDQS0100       ds
     D   v1Selection                  1    inz('A')                             all
     D   v1Reserved                   3
     D   v1MsgByteRtv                10i 0 inz   overlay(vRDQS0100:5)           message bytes to rtv
      *
     D vRDQS0200       ds
     D   v2Selection                  1    inz('K')                             Keyed
     D   v2KeyOrder                   2    inz('GE')
     D   v2MsgByteRtv                10i 0 inz   overlay(vRDQS0200:5)           message bytes to rtv
     D   v2KeyByteRtv                10i 0 inz   overlay(vRDQS0200:9)           keys bytes to rtv
     D   v2KeyLen                    10i 0 inz   overlay(vRDQS0200:13)          key length
     D   v2Key                      256          overlay(vRDQS0200:17)          key value
      *
      *----------------------------------------------------------------
      * get entry date and time from API
      *----------------------------------------------------------------
     D dtDS            ds            16                                         extract C YYMMDD
     D  dtFiller                      1
     D  dtMDY                         6
     D  dtTIME                        6
      *
      *----------------------------------------------------------------
      * Divide entry up into subfile fields
      *----------------------------------------------------------------
     D ViewqDS         ds
     D   Viewq1
     D   Viewq2
     D TempqDS         s            116a
     D isHexMode       s               n   inz(*off)
     D ofs             s             10i 0 inz
     D ColumnShift     s             10i 0 inz
     D x               s             10i 0 inz
     D i               s             10i 0 inz
     D cRuler1         c                   const('....+....1....+....2+
     D                                            ....+....3....+....4+
     D                                            ....+....5....+....6+
     D                                            ....+....7....+....8+
     D                                            ....+....9....+....0+
     D                                            ....+....1....+....2+
     D                                            ....+....3....+....4+
     D                                            ....+....5....+....6+
     D                                            ....+....7....+....8+
     D                                            ....+....9....+....0+
     D                                            ....+....1....+....2')
     D cRuler2         c                   const('. . . . + . . . . 1 +
     D                                            . . . . + . . . . 2 +
     D                                            . . . . + . . . . 3 +
     D                                            . . . . + . . . . 4 +
     D                                            . . . . + . . . . 5 +
     D                                            . . . . + . . . . 6 +
     D                                            . . . . + . . . . 7 +
     D                                            . . . . + . . . . 8 +
     D                                            . . . . + . . . . 9 +
     D                                            . . . . + . . . . 0 +
     D                                            . . . . + . . . . 1 +
     D                                            . . . . + . . . . 2 +
     D                                            . . . . + . . . . 3 +
     D                                            . . . . + . . . . 4 +
     D                                            . . . . + . . . . 5 +
     D                                            . . . . + . . . . 6 +
     D                                            . . . . + . . . . 7 +
     D                                            . . . . + . . . . 8 +
     D                                            . . . . + . . . . 9 +
     D                                            . . . . + . . . . 0 ')
      *
      *----------------------------------------------------------------
      * Error return code parm for APIs.
      *----------------------------------------------------------------
     D vApiErrDs       ds
     D  vbytpv                       10i 0 inz(%size(vApiErrDs))                bytes provided
     D  vbytav                       10i 0 inz(0)                               bytes returned
     D  vmsgid                        7                                         error msgid
     D  vresvd                        1                                         reserved
     D  vrpldta                      50a                                        replacement data
      *
      *---------------------------------------------------------------------------------------------
      * Create Prototypes for calls
      *---------------------------------------------------------------------------------------------
     D qwccvtdt        PR                  ExtPgm('QWCCVTDT')                   api date converter
     D                               10    const                                FROM FORMAT
     D                                8                                         API DATE STAMP
     D                               10    const                                TO FORMAT
     Dd                                    like(dtDS)                           TO DATE
     Db                                    like(vApiErrDS)                      error parm
      *    -------------------------------------------------------------
     D qmhqrdqd        PR                  ExtPgm('QMHQRDQD')                   data q description
     Db                                    like(qrcvar)                         RECIEVER
     D                               10i 0 const                                LENGTH
     D                                8    const                                FORMAT
     Dd                              20                                         Q NAME & LIB
      *    -------------------------------------------------------------
     D qmhrdqm         PR                  ExtPgm('QMHRDQM ')                   get q entry
     Db                                    like(vrcvar)                         RECIEVER
     D                                       Options(*varsize)
     D                               10i 0 const                                LENGTH
     D                                8    const                                FORMAT
     D                               20                                         Q NAME & LIB
     Db                                    like(vRDQS0200) Options(*varsize)    KEY INFORMATION
     D                                        const
     D                               10i 0 const                                KEY INFO LENGTH
     D                                8    const                                INFORMATION
     Db                                    like(vApiErrDS) Options(*varsize)    error data structure
      *    -------------------------------------------------------------
     D quscrtus        PR                  ExtPgm('QUSCRTUS')                   create user space
     D                               20                                         Space Name
     D                               10    const                                Extended Attrb
     D                               10i 0 const                                length of space
     D                                1    const                                Hex0Init
     D                               10    const                                Use Authority
     D                               50    const                                text
     D                               10    const                                replace object
     Db                                    like(vApiErrDS)                      error parm
      *    -------------------------------------------------------------
     D uSpaceName      s             20    inz('DSPDQER   QTEMP     ')
     D qusptrus        PR                  ExtPgm('QUSPTRUS')                   retrieve pointer
     D                               20                                         Space Name
     D                                 *                                        pointer
     Db                                    like(vApiErrDS)                      error parm
      *    -------------------------------------------------------------
     D cvthc           PR                  ExtProc('cvthc')                     Cvt. Hex to Char
     D  i_receiver                     *   value
     D  i_source                       *   value
     D  i_numSrcNib                  10i 0 value
      *    -------------------------------------------------------------
     D main            PR                  extpgm('DSPDQER ')
     D  i_qnamlib                    20A                                        NAME LIB 20
     D  i_qobjtyp                    10A
      *    -------------------------------------------------------------
     D main            PI
     D  i_qnamlib                    20A
     D  i_qobjtyp                    10A
      *---------------------------------------------------------------------------------------------
     C                   eval      vqname=%subst(i_qnamlib:1:10)
     C                   eval      vSflMode = *on
     C                   eval      *in03    = vSflMode                          subfile mode
     C                   eval      vpos     = 1
      *
      * create object list user space
     C                   callp     QUSCRTUS(                                    CREATE USER SPC
     C                             uSpaceName:                                  CREATE USER SPC
     C                             'TEST':                                      EXTENDED ATRIB
     C                             13000000:                                    SIZE IN BYTES
     C                             x'00':                                       INITIAL VALUE
     C                             '*ALL':                                      AUTHORITY
     C                             'List Objects  ':                            TEXT
     C                             '*NO ':                                      REPLACE OBJ
     C                             vApiErrDs)                                   ERROR
      *
      * Get pointer to object list user spaces
     C                   callp     QUSPTRUS(                                    GET POINTER TO SPACE
     C                             uSpaceName:                                  SPACE    LIB
     C                             uHeadPtr:                                    pointer to header
     C                             vApiErrDs)                                   error
      *
      * Call API to retrieve data queue description.
     C                   callp     QMHQRDQD(
     C                             qrcvar:                                      DATA STRUCT
     C                             %size(qrcvar):                               SIZE
     C                             'RDQD0100':                                  TYPE FORMAT
     C                             i_qnamlib)                                   NAME LIB
      *
      * Setup a looping subroutine so user can refresh screen
 1B  C                   dou       ExitPgmFlg=*on
     C                   exsr      RefreshScreen
 1E  C                   enddo
     C                   eval      *inlr = *on                                  PROGRAM END
     C                   return
      *
      *----------------------------------------------------------------
      * Call API to retrieve data queue entries
      *   Different type dataqs require a different parm list to the API.
      *----------------------------------------------------------------
     C     RefreshScreen begsr
      /FREE
 1B    if qAccessTyp ='K';                                                    //keyed

         vacsType = '*KEYED';
         v2MsgByteRtv = qMsgLength;                                           //message bytes to rtv
         v2KeyByteRtv = qKeyLength;                                           //keys bytes to rtv
         v2KeyLen = qKeyLength;                                               //keys length to rtv
         v0200Len=16+qKeyLength;                                              //len of info
         QMHRDQM(
             vrcvar:                                                          //return variable
             12000000:                                                        //len of return var
             'RDQM0200':                                                      //return format
             i_qnamlib:                                                       //NAME LIB
             vRDQS0200:                                                       //key information
             v0200Len:                                                        //key information leng
             'RDQS0200':                                                      //information format
             vApiErrDS);
                                                                //error data structure
 1X    else;

         //  non keyed
         vacsType = '*NON-KEYED';
         v1MsgByteRtv = qMsgLength;                                           //message bytes to rtv
         QMHRDQM(
             vrcvar:                                                          //return variable
             12000000:                                                        //len of return var
             'RDQM0100':                                                      //return format
             i_qnamlib:                                                       //NAME LIB
             vRDQS0100:                                                       //key information
             %size(vRDQS0100):                                                //key information leng
             'RDQS0100':                                                      //information format
             vApiErrDS);                                                      //error data structure
 1E    endif;

       //------------------------------------------------------------------------------------
       // Spin through the dataq entries.
       //   Convert API date/time stamp to human-readable.
       //     Load to subfile.
       //------------------------------------------------------------------------------------
       clear rrn1;
 1B    if vNumMsgRtn >  0;                                                    //there are entries
         //---------------------------------------------------------------------------------------
         //      Move pointer through message entries
         //---------------------------------------------------------------------------------------
         vListPtr=uHeadPtr  + vOffset1stEnt;          //1st offset
         lastOffset = vOffset1stEnt;

 2B      for i = 1 to vNumMsgRtn;

           if vNextEntry > 0;
             msgLen = vNextEntry - lastOffset;
             lastOffset = vNextEntry;
           else;
             msgLen = 0;
           endif;
           exsr DecodeDate;
           exsr srTempqDS;
           exsr srDataToDsp;
           rrn1=rrn1+1;
           write data1;
 3B        if rrn1=9999;                                                      //subfile full
 2L          leave;
 3E        endif;
           vListPtr=uHeadPtr  + vNextEntry;

 2E      endfor;
 1E    endif;

       //----------------------------------------------------------------
       // Display subfile.  Calc number of screens in subfile.
       //----------------------------------------------------------------
       vSrecNum=1;
       ColumnShift=0;
       vlen          = qMsgLength;
       vqTotCnt      = vNumMsgAvl;                                            //total number of entr
 1B    dou 1=2;

         x = ofs + 1;
 2B      dow x > 100;
           x = x - 100;
 2E      enddo;

 2B      if isHexMode;
           vRuler = %subst(cRuler2: (x*2)-1);
 2X      else;
           vRuler = %subst(cRuler1: x);
 2E      endif;

 2B      if ofs = 0;
           %subst(vRuler: 1: 1) = '*';
 2E      endif;

 2B      if vSflMode = *on;
           sflDspPag = cSflPag * 2;
 2X      else;
           sflDspPag = cSflPag;
 2E      endif;

         vqentNum = rrn1;                                                     //# Q ENTRIES
      /END-FREE
     C     rrn1          div       sflDspPag     vScrnNum                       # OF SCREENS
     C                   mvr                     mvr
      /FREE
 2B      if mvr>0;                                                            //OVERFLOW SCREENS
           vScrnNum =  vScrnNum+1;
 2E      endif;
         //
         *in20=(rrn1>sflDspPag);                                              //more
         *in01=(rrn1>0);                                                      //SFLDSP
         *in02 = *on;                                                         //SFLDSPCTL
         //
         write header;                                                        // DISPLAY
         exfmt contrl1;                                                       // SCREENS
         *in03 = vSflMode;
         // exit / cancel
 2B      select;
 2X      when fkey=f03                                                        //F3=exit
               or fkey=f12;                                                   //F12=cancel
           ExitPgmFlg=*on;
           // v4r4---          leavesr
      /END-FREE
goto C                   goto      outtag                                       F3=exit    v4r2
      //
      // refresh
      /FREE
 2X      when fkey=f05;                                                       //refresh
           rrn1=0;
           *in01=*off;
           *in02=*off;
           write contrl1;                                                     //clear
           // v4r4---          leavesr                                                F5=REFRESH
      /END-FREE
goto C                   goto      outtag                                       F5=REFRESH v4r2
      //
      // change display mode
      /FREE
 2X      when fkey=f10;                                                       //F10=Hex
 3B        if isHexMode;
             isHexMode = *off;
             Shift=58;
 3X        else;
             isHexMode = *on;
             Shift=25;
 3E        endif;
           bgrrnSav=bgrrn;
           exsr srUpdSfl;
           bgrrn=bgrrnSav;
           // fold/unfold
 2X      when fkey=f11;                                                       //F11=Fold/Unfold
 3B        if vSflMode = *on;
             vSflMode = *off;
 3X        else;
             vSflMode = *on;
 3E        endif;
           *in03 = vSflMode;
           //
           // shift column position to the left
 2X      when fkey=f19;                                                       //F19=column left
           ColumnShift=ColumnShift-Shift;
 3B        if ColumnShift<0;
             ColumnShift=1;
 3E        endif;
           vdspPos=ColumnShift;
           //
           // shift column position to the right
 2X      when fkey=f20;                                                       //F20=column right
           ColumnShift=ColumnShift+Shift;
 3B        if ColumnShift >= qMsgLength;
             ColumnShift =  qMsgLength - 1;
 3E        endif;
           vdspPos=ColumnShift;
 2E      endsl;
         //
         //---------------------------------------------------------------
         //   Determine which screen the user wants to display.
         //---------------------------------------------------------------
 2B      if vdspNum = 0;                                                      //screen field=0
 3B        if bgrrn=0;
             bgrrn=1;
 3E        endif;
           vsrecNum = bgrrn;
 2X      else;
           torecNum = vdspNum * sflDspPag;
 3B        if torecNum < rrn1;                                                //NOT PAST EOF
             vsrecNum      = torecNum;
 3X        else;
             vsrecNum      = rrn1;                                            //PAST EOF SELCTD
 3E        endif;
 2E      endif;
         //
         //---------------------------------------------------------------
         //   Determine the column offset the user wants to display.
         //---------------------------------------------------------------
 2B      if vdspPos > 0;
           ofs = vdspPos - 1;
 3B        if ofs < 0;
             ofs = 0;
 3E        endif;
 3B        if ofs >= qMsgLength;
             ofs = qMsgLength - 1;
 3E        endif;
           exsr srUpdSfl;
           vpos    = ofs + 1;
           vdspPos = 0;
 2E      endif;
         //
         clear vdspNum;                                                       //REINIT
         clear torecNum;
 1E    enddo;
      /END-FREE
     C     outtag        endsr
      *
      *----------------------------------------------------------------
      * Decode the Date-Time_Stamp into MM/DD/YY and HH:MM:SS
      *----------------------------------------------------------------
     C     DecodeDate    begsr
     C                   callp     QWCCVTDT(                                    API DATE CONVRT
     C                             '*DTS    ':                                  FROM FORMAT
     C                             vDateTime :                                  TO BE CONVERTED
     C                             '*MDY    ':                                  TO FORMAT
     C                             dtDS  :                                      CONVERTED DATE
     C                             vApiErrDs)
     C                   eval      qudate=%subst(dtMDY:1:2) + '/' +
     C                             %subst(dtMDY:3:2) +'/'+ %subst(dtMDY:5:2)
     C                   eval      qutime=%subst(dtTIME:1:2) + ':' +
     C                             %subst(dtTIME:3:2) +':'+ %subst(dtTIME:5:2)
     C                   endsr
      *
      *----------------------------------------------------------------
      * Update Subfile.
      *----------------------------------------------------------------
     C     srUpdSfl      begsr
      /FREE
       vListPtr=uHeadPtr  + vOffset1stEnt;    //1st offset
       lastOffset = vOffset1stEnt;
       for x = 1 to vqentNum;
         if vNextEntry > 0;
           msgLen = vNextEntry - lastOffset;
           lastOffset = vNextEntry;
         else;
           msgLen = 0;
         endif;
         chain x data1;
         exsr srTempqDS;
         exsr srDataToDsp;
         update data1;
         vListPtr=uHeadPtr  + vNextEntry;
 1E    endfor;
       endsr;
      /END-FREE
      *
      *----------------------------------------------------------------
      * Fill TempqDS from User Space Data.
      * Note: If Keyed data queue, then there is an unexplained 5 bytes at the beginning of
      * each key...  not sure if this a bug or an undocumented feature.
      * Also the size of the message entry could be larger than the message variable
      * allowed..  qTrimLen is used to make sure this doesn't blow up here!
      *----------------------------------------------------------------
     C     srTempqDS     begsr
      /FREE
       qTrimLen = qMsgLength - ofs;
 1B    if qAccessTyp ='K';                   //keyed

 2B      //If (5+qKeyLength)+qMsgLength > %size(vMsgVar);
         //  qTrimLen=%size(vmsgvar)-(5+qKeyLength);
 2E      //endif;
 2B      //if qTrimLen > %len(ViewqDS);
         //  qTrimLen = %len(ViewqDS);
 2E      //endif;
         //TempqDS = %subst(vmsgvar:5+qKeyLength+ofs:qTrimLen);  //  extract message

 2B      If (5)+qMsgLength > %size(vMsgVar);
           qTrimLen=%size(vmsgvar)-(5);
 2E      endif;
 2B      if qTrimLen > msgLen and msgLen > 0;
           qTrimLen = msgLen - ofs;
 2E      endif;
 2B      if qTrimLen > %len(ViewqDS);
           qTrimLen = %len(ViewqDS);
 2E      endif;
         TempqDS = %subst(vmsgvar:5+ofs:qTrimLen);  //  extract message

 1X    else;

 2B      If qMsgLength > %size(vMsgVar);
           qTrimLen=%size(vmsgvar);
 2E      endif;
 2B      if qTrimLen > %len(ViewqDS);
           qTrimLen = %len(ViewqDS);
 2E      endif;
         TempqDS  = %subst(vmsgvar:1+ofs:qTrimLen);  //  extract message

 1E    endif;
       endsr;
      /END-FREE
      *----------------------------------------------------------------
      * Move Data to Display Field.
      *----------------------------------------------------------------
     C     srDataToDsp   begsr
 1B  C                   if        isHexMode
     C                   eval      ViewqDS = ''
     C                   callp     cvthc(%addr(ViewqDS)       :
     C                                   %addr(TempqDS)       :
     C                                   qTrimLen * 2         )
 1X  C                   else
     C                   eval      ViewqDS = %subst(TempqDS: 1      )
      *-----------------------------------------------------------------------------------
      *    Drop anything below hex 40 before sending it to the screen.
      *-----------------------------------------------------------------------------------
     C                   eval      ff= qTrimLen
 2B  C                   do        ff            aa
 3B  C                   if        %subst(ViewqDS:aa:1)<Hex40
     C                   eval      %subst(ViewqDS:aa:1)=' '
 3E  C                   endif
 2E  C                   enddo
 1E  C                   endif
     C                   endsr
