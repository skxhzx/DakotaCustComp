     F*----------------------------------------------------------------
     F*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   24 N. Washington Ave #203
     F*   Batavia, IL 60510
     F*   630.562.0375
     F*----------------------------------------------------------------
     F*
     F*  IT534    Recommend Transfers From Outside Storage - Build
     F*  May 26, 2009
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
520 AF*    05/26/09  MLB  5.20
     F*      - Created.
     F*      - Included client custom code support to program.
640 A*   02/01/11  RH   6.40
     *     - Fix: Change SLKEY4A and SLKEY4B to use ITWHDP, was using
     *       entered value and incorrect if '*ALL' was entered.
640bA*   05/10/12  RTR  6.40b
     *     - Created from IT535 and changed to write to work file
     *       IT535 instead of print file. Item/slot selection logic
     *       is now in this program instead of IT535.
640cA*   05/14/12  RTR  6.40c
     *     - Changed to include the *ORD logic from revision ICBb
     *       as a base option, with new screen field for user selection
     *       of *SLS or *ORD to use for the report.
650aA*   09/18/13  LMC  6.50a
     *     - Exclude repack items from inital piritem selection.
     *       Repack item demand will show under parent item.
     *       These mods are in conjuction with GLPa but are standard
     *       for all clients.
     *     - All calculations will be done at lowest UOM.
650bA*   10/09/13  LMC  6.50b
     *     - Include 'B' type item.
     *       need itemlnk for Base item OSS inventory.
650cA*   03/17/14  RH   6.50c
     *     - Fix: Put 650b mod into Greenleaf only code.
650dA*   11/24/14  LMC  6.50d
     *     - Fix: When client uses *ORD selection from the display
     *       file, they data is never populated, unless you are client
     *       ICB. Added logic to chain to the itemord - *ORD selectioN
700aA*   02/08/16  LMC/RH  7.00a
     *     - Fix: Initialize OSL,
700bA*   06/11/16  DAS  7.00b
     *     - Enh: Added *EACH logic.
     *
750 A*   04/06/21  MLB  7.50  ZD# 3941
     *     - Fix: Revised pgm to increase size of WKQTY1,WKQTY2 and
     *       WKQTY3 to 9,2 from 7,2. Was causing MCH1210 - Receiver
     *       value too small to hold result error. Found at A&D.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*   01/31/11  RH   DRYa
     *     - Changed program to select slots greater than or = aisle
     *       entered.
DRYbA*   04/26/11  RH   DRYb
     *     - Changed program to not count slot w/aisle starting 'T'
DRYc  *   06/06/11  RH   DRYc
      *     - Changed program to not count pick slots in aisle Offsite
DRYd  *   04/29/19  DAS  DRYd
      *     - Changed to select aisles 030 - 050 when not aisle entered
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICBaA*   03/15/12  RH   ICBa
     *     - Changed to select slots = aisle H, I, N, P, R, T
     *       no aisle was entered.
ICBbA*   03/27/12  RH   ICBb
     *     - Enh: allow *ORD for aisle, will use ITEMORD file in place
     *       of ITEMAVG (average sales)
ICBcA*   04/19/12  RBD  ICBc
     *     - Enh: per Brian, added aisle G to list of OSS aisles.
ICBdA*   11/08/13  RH   ICBd
     *     - Enh: Added aisle OSS to list of OSS aisles.
ICBeA*   05/14/14  RH   ICBe
     *     - Enh: Added numeric aisles to list of OSS aisles.
ICBfA*   05/19/14  RH   ICBf
     *     - Fix: Convert ItemOrd qty to lowest uom like ITEMAVG
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLPaA*   09/17/13  LMC  GLPa
     *     - Toland warehouse is considered the main for this report.
     *     Pull pick slots & RP slots in aisles 40 and above.
     *     Outside storage would be considered any aisles below 40
     *     MC and TR.
     *     Mod 650a goes along with GLPa
GLPbA*   10/25/13  LMC  GLPb
     *     - Trailer aisle is now considered Toland local inventory.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods Company
     *
FFCaA*    11/24/14  LMC  FFCa
     *     - Changed to select slots = aisle 20 -no aisle is entered.
FFCbA*    09/18/15  RH   FFCb
     *     - Changed to add aisle 21 as OSS
FFCcA*    06/08/16  LMC  FFCc
     *     - Changed to add aisle 76 as OSS  - this is in FRZ dept.
     *
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*
     F*----------------------------------------------------------------

     *----------------------------------------------------------------
700aA*  *EACH Notes
     *
     *     Instead of changing the files to include breakdown qtys, it
     *     was decided to create an extra record where '*EACH' is
     *     appended to the item number, like '123456*EACH'.
     *
     *----------------------------------------------------------------

     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FPIRITEM1  IF   E           K DISK
     FITEMAVG   IF   E           K DISK
ICBbAFITEMORD   IF   E           K DISK
650aAFkitcomp1  IF   E           K DISK
650bAFitemlnk   IF   E           K DISK
     FSLOT3     IF   E           K DISK
     F                                     rename(slrec:slrec3)
     FSLOT4     IF   E           K DISK
     F                                     rename(slrec:slrec4)
     FWAREHS    IF   E           K DISK
640bDF*IT535PR   O    E             PRINTER OFLIND(*IN90)
640bAFIT535     O    E             DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*----------------------------------------------------------------
     D*  Customer id
DRYaA /copy qcopysrc,id#dairyla
ICBaA /copy qcopysrc,id#icb
GLPaA /copy qcopysrc,id#glp
FFCaAD/copy qcopysrc,id#fischer
     D*
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Working variable(s)
     D*
GLPaAD day             s              1  0
     D first           s              1a   inz('1')
     D forever         s              1a   inz('1')
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
700bAD kyitem          s                   like(slitem)
     D lclwhseqty      s              7s 0
650aAD lowqty          s              7  0
     D osL             s              3s 0
     D $pdaysply       s              3s 0
     D $pstr           s             60a
     D $pwhse          s                   like(itwhse)
     D rmtwhseqty      s              7s 0
     D rmtwhsslot      s             10a
650aAD sumigaqsw       s                   like(igaqsw)
650aAD savitumq2       s                   like(itumq2)
650aAD savitumq3       s                   like(itumq3)
750 DD*wkqty1          s                   like(igaqsw)
750 MD wkqty1          s              9  2 inz(0)
750 DD*wkqty2          s                   like(igaqsw)
750 MD wkqty2          s              9  2 inz(0)
750 DD*wkqty3          s                   like(igaqsw)
750 MD wkqty3          s              9  2 inz(0)
GLPaAD begloc          s                   like($possloc)
GLPaAD NotToland       s              1a   inz(' ')
     D svwhdp          s                   like(itwhdp)
ICBbAD today           s                   like(slsdte)
     D*
     D*----------------------------------------------------------------
     D*
     D $PERM           DS
     D  XXERM                  1     60
     D  $PMSG                  1      4
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PWHS    - Warehouse number
     C*      $PWHDP   - Warehouse department or *ALL
     C*      $PDYSP   - Days supply to have on-hand
     C*      $POSSLOC - Slot or *all
640cAC*      $PSEL    - Record selection *SLS or *ORD
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $PWHDP            5
     C                   PARM                    $PDYSP            3
     C                   PARM                    $POSSLOC         12
640cAC                   PARM                    $PSEL             4
     C*----------------------------------------------------------------
     C*
     C                   if        $pwhdp <> '*ALL'
     C     itkey1        setll     piritem1
     C                   else
     C     $pwhse        setll     piritem1
     C                   endif
     C
     C                   dow       forever = forever
     C                   if        $pwhdp <> '*ALL'
     C     itkey1        reade     piritem1
     C                   else
     C     $pwhse        reade     piritem1
     C                   endif
     C
     C                   if        %eof(piritem1)
     C                   leave
     C                   endif
     C
     C*  Ignore Alias, Breakdown or SSB item types.
     C                   if           ittype = 'A'
650bDC*                            or ittype = 'B'
     C                             or ittype = 'S'
     C                   iter
     C                   endif
650aAC*  repack items only inlclude if slot with RP status
650cMc                   if        client = Greenleaf
650bAc                   if        ittype <> 'B'
650aAC                   eval      kypick = 'Y'
650aAC                   eval      kystat = 'RP'
650aAc     slkey3        chain     slot3
650aAc                   if        not %found(slot3)
650aAc                   iter
650aAc                   endif
650bAc                   endif
650aAC*  only want items that have at least a pick slot at Toland
650cDc**                 if        client = Greenleaf
GLPaAc                   eval      begloc = '40'
GLPaAc                   eval      NotToland = ' '
GLPaAc     slkey4c       setll     slot4
GLPaAc                   dow       forever = forever
GLPaAc     slkey4b       reade     slot4
GLPaAc                   if        %eof(slot4)
GLPaAc                   eval      NotToland = 'Y'
GLPaAc                   leave
GLPaAc                   endif
GLPaAc                   if        slpick = 'Y'
GLPaAc                   leave
GLPaAc                   endif
GLPaAc                   enddo
650cDc**                 endif
GLPaAc                   if        NotToland = 'Y'
GLPaAc                   iter
GLPaAc                   endif
650cMc                   endif
     C
650aAc                   eval      savitumq2 = itumq2
650aAc                   eval      savitumq3 = itumq3
     C*  If processing all departtments, see if dept changed.
     C                   if            itwhdp <> svwhdp
     C                             and $pwhdp = '*ALL '
     C                   eval      svwhdp = itwhdp
     C                   eval      *in90 = '1'
     C                   endif
     C*
      * B type items need to use BASE item for outside storage inventoy
      /free
        chain (itwhse: ititem) itemlnk;
        if %found(itemlnk);
        else;
          ilitm2 = ' ';
        endif;
      /end-free
     C*  Accumulate total qty in outside storage.
     C                   eval      rmtwhseqty = 0
640bAC                   eval      rmtwhsslot = *blanks
650bAc                   if        ittype = 'B'
650bAC     slkey4ab      setll     slot4
650bAc                   else
     C     slkey4a       setll     slot4
650bAc                   endif
     C                   dow       forever = forever
650bAc                   if        ittype = 'B'
650bAC     slkey4bb      reade     slot4
650bAc                   else
     C     slkey4b       reade     slot4
650bAc                   endif
DRYaAC                   select
DRYaAC                   when      client = dairyland
DRYaAC                   if        %eof(slot4)
DRYaAC                   leave
DRYaAC                   endif
DRYdAC                   if        slwhse = 55
DRYdAC                             and (slaisl < '030' or slaisl > '050')
DRYdAC                   iter
DRYdAC                   endif
ICBaAC*
ICBaAC                   when      client = icb
ICBaAC                   if        %eof(slot4)
ICBaAC                   leave
ICBaAC                   endif
ICBeAC                   if        %subst(slaisl:3:1)>='0' and
ICBeAC                             %subst(slaisl:3:1)<='9'
ICBeAC                   else
ICBaAC
ICBaAC                   if        slaisl <> '  H' and
ICBaAC                             slaisl <> '  I' and
ICBaAC                             slaisl <> '  N' and
ICBaAC                             slaisl <> '  P' and
ICBaAC                             slaisl <> '  R' and
ICBcMC                             slaisl <> '  T' and
ICBdAC                             slaisl <> 'OSS' and
ICBcAC                             slaisl <> '  G'
ICBaAC                   iter
ICBaAC                   endif
ICBeAC                   endif
ICBaAC*
FFCaAC                   when      client = FischerFoods
FFCaAC                   if        %eof(slot4)
FFCaAC                   leave
FFCaAC                   endif
FFCaAC
FFCaAC                   if        slaisl <> ' 20' and
FFCbAC                             slaisl <> ' 21'
FFCcAC                             and slaisl <> ' 76'
FFCaAC                   iter
FFCaAC                   endif
FFCaAC*
GLPaAC*
GLPaAC                   when      client = Greenleaf
GLPaAC                   if        %eof(slot4)
GLPaAC                   leave
GLPaAC                   endif
GLPaAC                   if        slaisl > ' 40'
GLPaAC                   iter
GLPaAC                   endif
GLPbAC                   if        slaisl = ' TR'
GLPbAC                   iter
GLPbAC                   endif
GLPaAC*
DRYaAC                   other
     C                   if        %eof(slot4)
     C                             or %subst(sldisp:1:osL)
     C                             > $possloc
     C                   leave
     C                   endif
DRYaAC                   endsl
     C
DRYcAC                   select
DRYcAC                   when      client = dairyland
DRYcAC                   if        slstat <> 'A ' or
DRYcAC                             slpick = 'Y'
DRYcAC                   iter
DRYcAC                   endif
DRYcAC                   other
     C                   if        slstat <> 'A '
     C                   iter
     C                   endif
DRYcAC                   endsl
     C
650aAC                   if        itumq2 <= 0
650aAC                   eval      itumq2 = 1
650aAC                   endif

650aAC                   if        itumq3 <= 0
650aAC                   eval      itumq3 = 1
650aAC                   endif

650aAC                   eval      lowqty   = (slstk1  * itumq2 * itumq3)
650aAC                                      + (slstk2  * itumq3)
650aAC                                      + slstk3
650aAc                   eval      rmtwhseqty = rmtwhseqty + lowqty
650aDC*                  eval      rmtwhseqty = rmtwhseqty + slstk1
640bAC*  Save first OSS slot to print
640bAC                   if        rmtwhsslot = *blanks
640bAC                   eval      rmtwhsslot = sldisp
640bAC                   endif
     C                   enddo
     C*
     C*  Item has not qty in outside storage, skip item.
     C                   if        rmtwhseqty <= 0
     C                   iter
     C                   endif
     C*
     C*  Retrieve Item Averages.
650aAc                   eval      sumigaqsw = 0
GLPaAc                   select
GLPaAc                   when      client = greenleaf
GLPaAC                   eval      igaqsw = 0
GLPaAc                   other
     C     igkey         chain     itemavg
     C                   if        not %found(itemavg)
     C                   eval      igaqsw = 0
     C                   endif
GLPaAc                   endsl
650aA * need to convert to lowest uom
650aAc                   eval      sumigaqsw = sumigaqsw +
650aAc                              (igaqsw * itumq2 * itumq3)
700bA *
700bA * Add in *EACH average
700bA *
700bAc                   if        client <> greenleaf
700bAC                   eval      kyitem = %trim(ititem) + '*EACH'
700bAC     eakey         chain     itemavg
700bAC                   if        %found(itemavg)
700bAc                   eval      sumigaqsw = sumigaqsw +
700bAc                              (igaqsw * itumq3)
700bAC                   endif
700bAC                   endif
700bA *
650aA * now need to get linked item averages
650aA /free
650aA   setll ($pwhse:ititem) kitcomp1;
650aA   dow not %eof(kitcomp1);
650aA     reade ($pwhse:ititem) kitcomp1;
650aA     if %eof(kitcomp1);
650aA       leave;
650aA     endif;
650aA     // get sales for linked item
650aA     chain ($pwhse:kcitem) itemavg;
650aA     if not %found(itemavg);
650aA       iter;
650aA     endif;
GLPaA     // need to pull actual day averages for greenleaf
GLPaA     select;
GLPaA       when client = greenleaf;
GLPaA         select;
GLPaA           when $pdaysply = 1;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = igaqs2 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = igaqs3 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = igaqs4 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = igaqs5 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = igaqs6 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = igaqs7 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = igaqs1 * ((kcqty1 * itumq2 * itumq3) +
GLPaA                                   (kcqty2 * itumq3) +
GLPaA                                   (kcqty3));
GLPaA             endsl;
GLPaA           when $pdaysply = 2;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = (igaqs2 + igaqs3) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = (igaqs3 + igaqs4) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = (igaqs4 + igaqs5) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = (igaqs5 + igaqs6) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = (igaqs6 + igaqs7) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = (igaqs7 + igaqs1) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = (igaqs1 + igaqs2) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA             endsl;
GLPaA           when $pdaysply = 3;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = (igaqs2 + igaqs3 + igaqs4) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = (igaqs3 + igaqs4 + igaqs5) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = (igaqs4 + igaqs5 + igaqs6) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = (igaqs5 + igaqs6 + igaqs7) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = (igaqs6 + igaqs7 + igaqs1) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = (igaqs7 + igaqs1 + igaqs2) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = (igaqs1 + igaqs2 + igaqs3) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA             endsl;
GLPaA           when $pdaysply = 4;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = (igaqs2 + igaqs3 + igaqs4 + igaqs5) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = (igaqs3 + igaqs4 + igaqs5 + igaqs6) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = (igaqs4 + igaqs5 + igaqs6 + igaqs7) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = (igaqs5 + igaqs6 + igaqs7 + igaqs1) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = (igaqs6 + igaqs7 + igaqs1 + igaqs2) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = (igaqs7 + igaqs1 + igaqs2 + igaqs3) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = (igaqs1 + igaqs2 + igaqs3 + igaqs4) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA             endsl;
GLPaA           when $pdaysply = 5;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = (igaqs2 + igaqs3 + igaqs4 + igaqs5 +
GLPaA                           igaqs6) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = (igaqs3 + igaqs4 + igaqs5 + igaqs6 +
GLPaA                           igaqs7) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = (igaqs4 + igaqs5 + igaqs6 + igaqs7 +
GLPaA                           igaqs1) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = (igaqs5 + igaqs6 + igaqs7 + igaqs1 +
GLPaA                           igaqs2) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = (igaqs6 + igaqs7 + igaqs1 + igaqs2 +
GLPaA                           igaqs3) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = (igaqs7 + igaqs1 + igaqs2 + igaqs3 +
GLPaA                           igaqs4) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = (igaqs1 + igaqs2 + igaqs3 + igaqs4 +
GLPaA                           igaqs5) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA             endsl;
GLPaA           when $pdaysply = 6;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = (igaqs2 + igaqs3 + igaqs4 + igaqs5 +
GLPaA                           igaqs6 + igaqs7) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = (igaqs3 + igaqs4 + igaqs5 + igaqs6 +
GLPaA                           igaqs7 + igaqs1) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = (igaqs4 + igaqs5 + igaqs6 + igaqs7 +
GLPaA                           igaqs1 + igaqs2) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = (igaqs5 + igaqs6 + igaqs7 + igaqs1 +
GLPaA                           igaqs2 + igaqs3) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = (igaqs6 + igaqs7 + igaqs1 + igaqs2 +
GLPaA                           igaqs3 + igaqs4) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = (igaqs7 + igaqs1 + igaqs2 + igaqs3 +
GLPaA                           igaqs4 + igaqs5) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = (igaqs1 + igaqs2 + igaqs3 + igaqs4 +
GLPaA                           igaqs5 + igaqs6) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA             endsl;
GLPaA           when $pdaysply = 7;
GLPaA             select;
GLPaA               when day = 1;
GLPaA                 lowqty = (igaqs2 + igaqs3 + igaqs4 + igaqs5 +
GLPaA                           igaqs6 + igaqs7 + igaqs1) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 2;
GLPaA                 lowqty = (igaqs3 + igaqs4 + igaqs5 + igaqs6 +
GLPaA                           igaqs7 + igaqs1 + igaqs2) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 3;
GLPaA                 lowqty = (igaqs4 + igaqs5 + igaqs6 + igaqs7 +
GLPaA                           igaqs1 + igaqs2 + igaqs3) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 4;
GLPaA                 lowqty = (igaqs5 + igaqs6 + igaqs7 + igaqs1 +
GLPaA                           igaqs2 + igaqs3 + igaqs4) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 5;
GLPaA                 lowqty = (igaqs6 + igaqs7 + igaqs1 + igaqs2 +
GLPaA                           igaqs3 + igaqs4 + igaqs5) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 6;
GLPaA                 lowqty = (igaqs7 + igaqs1 + igaqs2 + igaqs3 +
GLPaA                           igaqs4 + igaqs5 + igaqs6) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA               when day = 7;
GLPaA                 lowqty = (igaqs1 + igaqs2 + igaqs3 + igaqs4 +
GLPaA                           igaqs5 + igaqs6 + igaqs7) * +
GLPaA                          ((kcqty1 * itumq2 * itumq3) +
GLPaA                          (kcqty2 * itumq3) +
GLPaA                          (kcqty3));
GLPaA             endsl;
GLPaA         endsl;
GLPaA     other;
650aA     // found sales convert to lowest uom
650aA     lowqty = igaqsw * ((kcqty1 * itumq2 * itumq3) +
650aA                       (kcqty2 * itumq3) +
650aA                       (kcqty3));
GLPaA     endsl;
650aA     sumigaqsw = sumigaqsw + lowqty;
650aA   enddo;
650aA /end-free
ICBb C*  Retrieve Item Order Quantity.
ICBaAC                   select
ICBaAC                   when      client = icb
650dAC                             or $psel = '*ORD'
ICBaAC     igkey         chain     itemord
ICBaAC                   if        not %found(itemord)
ICBaAC                   eval      iitqo = 0
ICBbAC                   else
ICBbAC                   if        iiidte < today
ICBbAC                   eval      iitqo = 0
ICBbAC                   endif
ICBbAC                   endif
ICBfAC*  Convert to Lowest UOM.
ICBfAC                   eval      iitqo = (iitqo * itumq2 * itumq3)
700bAC*  Add in *EACH
700bAC     eakey         chain     itemord
700bAC                   if        not %found(itemord)
700bAC                   eval      iitqo = 0
700bAC                   else
700bAC                   if        iiidte < today
700bAC                   eval      iitqo = 0
700bAC                   endif
700bAC                   endif
700bAC                   eval      iitqo = (iitqo * itumq3)
ICBfAC*
ICBbAC                   endsl
     C
     C*
     C*  Accumulate total qty at warehouse location.
     C                   eval      lclwhseqty = 0
650aAc                   eval      r1disp = ' '
     C     slkey4b       setll     slot4
     C                   dow       forever = forever
     C     slkey4b       reade     slot4
     C                   if        %eof(slot4)
     C                   leave
     C                   endif
     C
DRYaAC                   select
DRYaAC                   when      client = dairyland
DRYa C*  Skip slots that are not active
DRYa C                   if        slstat <> 'A '
DRYa C*  or Outside storage slots.
DRYa C                             or slaisl >= $possloc
DRYa C                                and $possloc > ''
DRYdAC                             or (slwhse = 55
DRYdAC                                 and slaisl >= '030' and slaisl <= '050')
DRYbAC*  or Outside trailer slots.
DRYbAC                             or %subst(sldisp:1:1)= 'T'
DRYa C                   iter
DRYa C                   endif
ICBa C*
ICBaAC                   when      client = icb
ICBa C*  Skip slots that are not active
ICBa C                   if        slstat <> 'A '
ICBa C*  or Outside storage slots.
ICBa C                             or slaisl = '  H'
ICBa C                             or slaisl = '  I'
ICBa C                             or slaisl = '  N'
ICBa C                             or slaisl = '  P'
ICBa C                             or slaisl = '  R'
ICBa C                             or slaisl = '  T'
ICBcAC                             or slaisl = '  G'
ICBdAC                             or slaisl = 'OSS'
ICBeAC                             or %subst(slaisl:3:1)='0'
ICBeAC                             or %subst(slaisl:3:1)='1'
ICBeAC                             or %subst(slaisl:3:1)='2'
ICBeAC                             or %subst(slaisl:3:1)='3'
ICBeAC                             or %subst(slaisl:3:1)='4'
ICBeAC                             or %subst(slaisl:3:1)='5'
ICBeAC                             or %subst(slaisl:3:1)='6'
ICBeAC                             or %subst(slaisl:3:1)='7'
ICBeAC                             or %subst(slaisl:3:1)='8'
ICBeAC                             or %subst(slaisl:3:1)='9'
ICBaAC*  or transfer Door slots.
ICBaAC***                          or slaisl = 'TRD'
ICBa C                   iter
ICBa C                   endif
ICBa C*
FFCaAC                   when      client = FischerFoods
FFCa C*  Skip slots that are not active
FFCa C                   if        slstat <> 'A '
FFCa C*  or Outside storage slots.
FFCa C                             or slaisl = ' 20'
FFCbAC                             or slaisl = ' 21'
FFCcAC                             or slaisl = ' 76'
FFCa C                   iter
FFCa C                   endif
GLPaAC                   when      client = Greenleaf
GLPA C*  Skip slots that are not active
GLPa C                   if        slstat <> 'A ' and slstat <> 'RP'
GLPa C*  or Slots not defined as Toland warehouse ?? RPK
GLPa C                             or slaisl < ' 40'
GLPbAc                                and slaisl <> ' TR'
GLPa C                             or slaisl = ' MC'
GLPbDC*                            or slaisl = ' TR'
GLPa C                   iter
GLPa C                   endif
GLPa C*
DRYa C                   other
     C*  Skip slots that are not active
     C                   if        slstat <> 'A '
     C*  or Outside storage slots.
     C                             or %subst(sldisp:1:osL)
     C                                = $possloc
     C                   iter
     C                   endif
DRYa C                   endsl
     C
650aAc                   if        slpick = 'Y'
650aAc                   eval      r1disp = sldisp
650aAc                   endif
650aAC                   eval      lowqty   = (slstk1  * itumq2 * itumq3)
650aAC                                      + (slstk2  * itumq3)
650aAC                                      + slstk3
650aDC*                  eval      lclwhseqty = lclwhseqty + slstk1
650aAC                   eval      lclwhseqty = lclwhseqty + lowqty
     C                   enddo
     C*
     C*  Compute days supply of item needed.
ICBb C*
ICBbAC                   select
640cDC*                  when      client = icb
ICBbAC*  Set to order qty for *ORD.
640cDC*                  if        $possloc = '*ORD'
640cAC                   when      $psel = '*ORD'
ICBbAC                   eval      r1demd = iitqo
640cDC*                  else
640cDC*                  eval      r1demd = igaqsw / 5 * $pdaysply
640CDC*                  endif
GLPaAc                   when      client = greenleaf
GLPaAc                   eval      r1demd = sumigaqsw
ICBbAC                   other
     C                   eval      r1demd = igaqsw / 5 * $pdaysply
ICBbAC                   endsl
     C*
     C*  Item has sufficient qty in local warehouse, skip item.
     C*  or item has no weekly demand, skip item.
     C                   if        r1demd <= lclwhseqty
     C                             or r1demd <= 0
     C                   iter
     C                   endif
     C*
     C*  Find pick slot for item.
     C                   eval      kypick = 'Y'
     C                   eval      kystat = 'A '
     C     slkey3        setll     slot3
     C     slkey3        reade     slot3
     C                   if        %eof(slot3)
     C                   eval      sldisp = ' '
     C                   endif
     C*
650aA * need to convert back to normal uom
650aA * local qty
650aAc                   eval      wkqty3 = lclwhseqty
650aAc                   exsr      zzupqty
650aAc                   eval      lclwhseqty = wkqty1
650aA * remote qty
650aAc                   eval      wkqty3 = rmtwhseqty
650aAc                   exsr      zzupqty
650aAc                   eval      rmtwhseqty = wkqty1
650aA * demand
650aAc                   eval      wkqty3 = r1demd
650aAc                   exsr      zzupqty
650aAc                   eval      r1demd     = wkqty1
     C*  Item needs to have quantity transferred from outside storage.
     C                   eval      r1tfrq = r1demd - lclwhseqty
650aAc                   if        r1tfrq < 1
650aAc                   eval      r1tfrq = 1
650aAc                   endif
     C                   eval      r1locq = lclwhseqty
     C                   eval      r1rmtq = rmtwhseqty
650aDC*                  eval      r1disp = sldisp
640bAC                   eval      r1oss  = rmtwhsslot
     C*
     C*  Report Heading
     C*
     C     *IN90         IFEQ      '1'
     C     FIRST         OREQ      '1'
     C                   EXSR      ZRHEAD
     C                   END
     C*
     C* Detail Calcs
     C*
     C                   write     wkrec
     C*
     C                   enddo
     C
     C                   eval      *inlr = *on
     C*
     C                   if        first = '1'
     C                   exsr      zrhead
     C*                  write     detail2
     C                   endif
     C*
640bDC***                write     foot1
     C*
     C*****************************************************************
     C*
     C*  *INZSR  Initialization subroutine
     C*
     CSR   *INZSR        BEGSR
     C*
     C* Get client id.
     C*
     C                   CALL      'GETCLIENT'
     C                   PARM                    CLIENT           10
     C                   PARM                    CLIENTLOC        10
     C*
     C     igkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
700bAC*
700bAC     eakey         klist
700bAC                   kfld                    $pwhse
700bAC                   kfld                    kyitem
     C*
     C     itkey1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C*
     C     slkey3        klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C*
     C     slkey4a       klist
     C                   kfld                    $pwhse
640 DC*                  kfld                    $pwhdp
640 MC                   kfld                    itwhdp
     C                   kfld                    ititem
     C                   kfld                    $possloc
     C*
650bAC     slkey4ab      klist
650bAC                   kfld                    $pwhse
650bAC                   kfld                    itwhdp
650bAC                   kfld                    ilitm2
650bAC                   kfld                    $possloc
     C*
     C     slkey4b       klist
     C                   kfld                    $pwhse
640 DC*                  kfld                    $pwhdp
640 MC                   kfld                    itwhdp
     C                   kfld                    ititem
650bAC*
650bAC     slkey4bb      klist
650bAC                   kfld                    $pwhse
650bAC                   kfld                    itwhdp
650bAC                   kfld                    ilitm2
     C*
GLPaAC     slkey4c       klist
GLPaAC                   kfld                    $pwhse
GLPaAC                   kfld                    itwhdp
GLPaAC                   kfld                    ititem
GLPaAC                   kfld                    begloc
     C*
     C                   move      $pwhs         $pwhse
     C                   move      $pdysp        $pdaysply
700aAC     ' '           checkr    $possloc      osL
700aAC                   if        osL <= 0
700aAC                   eval      osL = 1
700aAC                   endif
     C*
     C                   exsr      zrfrmt
GLPaA*  Get current date.
GLPaA
GLPaAC                   eval      $cvcmd = '*CURCMD '
GLPaAC                   call      @cvtdt
GLPaAC                   parm                    $cvtdt
GLPaAC                   eval      Today = $cvd8o
GLPaA
GLPaA*  Convert current date to day number.
GLPaA
GLPaAC                   eval      $cvcmd = '*CMDNBR '
GLPaAC                   move      today         $cvd8i
GLPaAC                   call      @cvtdt
GLPaAC                   parm                    $cvtdt
GLPaAC                   eval      Day = $cvd6o
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C     ZRFRMT        BEGSR
     C*
     C                   ENDSR
     C*****************************************************************
     CSR   ZRHEAD        BEGSR
     C*
     CSR                 ENDSR
650aA*----------------------------------------------------------------
650aA*  ZZUPQTY       Up quantity
650aA*----------------------------------------------------------------
650aA
650aAC     zzupqty       begsr

650aAc                   eval      wkqty2 = 0
650aAc                   eval      wkqty1 = 0
650aAc                   if        savitumq3 = 0
650aAc                   eval      savitumq3 = 1
650aAc                   endif
650aAc                   if        savitumq2 = 0
650aAc                   eval      savitumq2 = 1
650aAc                   endif
650aAC                   dow       savitumq3 > 0 and +
650aAC                             wkqty3 >= savitumq3
650aAC                   eval      wkqty3 -= savitumq3
650aAC                   eval      wkqty2 += 1
650aAC                   enddo

650aAC                   dow       savitumq2 > 0 and +
650aAC                               wkqty2 >= savitumq2
650aAC                   eval      wkqty2 -= savitumq2
650aAc                   eval      wkqty1 += 1
650aAC                   enddo

650aAC                   endsr

