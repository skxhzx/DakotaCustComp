     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SCD323  Build SCD323A Work File - slot check digits from
     *          slotdgt and slotdgta.
     *
     *  12 September 2007
     *  Retha Davis
     *
     *  Revisions
     *
     *    09/12/07  RBD  5.10
     *      - Created
640a *    06/21/12  LMC  6.40a
     *      - Enh: build single record to accomodate the 5 pos check
     *      digit we now allow.
640b *    07/10/12  LMC  6.40cb
     *      - Fix:  Losing leading zeros on check digit
     *----------------------------------------------------------------
      *  Notes
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  21 - 30   Field input error (Reverse Display)
      *  90        View mode (Protect input fields)
      *  91        Change mode (Protect key)
      *  97        Always ON (Used for SFLEND Keyword)
      *  98        Error on screen (Sound buzzer)
      *  99        Universal record indicator (Very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Fslotdgt   if   e           k disk
     Fslotdgta  if   e           k disk
     Fscd323a   o  a e           k disk

      *----------------------------------------------------------------
      *  Data Structures
      *
     D                 ds
     D wktime                  1     12  0
     D htime                   1      6  0
     D hdate                   7     12  0

      *----------------------------------------------------------------
      *  Variables
      *
     D alpha6          S              6
     D forever         S              1
     D wk1             S              3
     D wk2             S              3
     D wk3             S              3
     D wk9             S              9

      *----------------------------------------------------------------
      *  Let the show begin .....

      *----------------------------------------------------------------
      *  Main line

     *  Write slotdgt records to work file
     *
     C                   dow       forever = forever
     C                   read      slotdgt
     C                   if        %eof
     C                   leave
     C                   endif
     C                   eval      swkwhs = scdwhs
     C                   eval      swkwhd = scdwhd
     C                   eval      swkdsp = scddsp
640bDC*                  eval      wk1 = %char(scddgt)
640bMC                   eval      wk1 = %Trim(%EditC(scddgt:'X'))
640aDC*                  eval      swkdgt = scddgt
     C                   eval      swkadt = scdadt
     C                   eval      swkatm = scdatm
     C                   eval      swkaby = scdaby
     C                   eval      swkvdt = scdvdt
     C                   eval      swkvtm = scdvtm
     C                   eval      swkvby = scdvby
640aA * Go get the 2 remaining slot digit fields
640aA /free
640aA   chain (scdwhs:scdwhd:scddsp) slotdgta;
640aA   if %found(slotdgta);
640bD     //wk2 = %char(scddgt2);
640bD     //wk3 = %char(scddgt3);
640bM     wk2 = %Trim(%EditC(scddgt2:'X'));
640bM     wk3 = %Trim(%EditC(scddgt3:'X'));
640aA   else;
640aA     wk2 = ' ';
640aA     wk3 = ' ';
640aA   endif;
640aA   wk9 = wk1 + wk2 + wk3;
640aA /end-free
640aAc                   move      wk9           swkdgt
     C                   write     s323a
     C                   enddo

     *  Write slotdgta records to work file
     *
     c                   goto      endthis
     C                   dow       forever = forever
     C                   read      slotdgta
     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        scddgt2 <> 0
     C                   eval      swkwhs = scdwhsa
     C                   eval      swkwhd = scdwhda
     C                   eval      swkdsp = scddspa
     C                   eval      swkdgt = scddgt2
     C                   eval      swkadt = scdadt2
     C                   eval      swkatm = scdatm2
     C                   eval      swkaby = scdaby2
     C                   eval      swkvdt = scdvdt2
     C                   eval      swkvtm = scdvtm2
     C                   eval      swkvby = scdvby2
     C                   write     s323a
     C                   endif

     C                   if        scddgt3 <> 0
     C                   eval      swkwhs = scdwhsa
     C                   eval      swkwhd = scdwhda
     C                   eval      swkdsp = scddspa
     C                   eval      swkdgt = scddgt3
     C                   eval      swkadt = scdadt3
     C                   eval      swkatm = scdatm3
     C                   eval      swkaby = scdaby3
     C                   eval      swkvdt = scdvdt3
     C                   eval      swkvtm = scdvtm3
     C                   eval      swkvby = scdvby3
     C                   write     s323a
     C                   endif

     C                   enddo

     c     endthis       tag
     C                   eval      *inlr = *on
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

     C                   endsr

      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
      *
      *  Initialize message handling
      *
     C                   exsr      zzinz
     C                   endsr
