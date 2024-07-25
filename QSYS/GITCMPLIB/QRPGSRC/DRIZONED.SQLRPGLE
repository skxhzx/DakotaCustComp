      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  DRIZONED    Dakota realtime interface - Zone Detail
     *  04 May 2012
     *  Dave Sommerville
     *
640  *    05/04/12  DAS  6.40
     *      - Created
     *
650aA*    05/06/14  DAS  6.50a
     *      - c#zoned changed to make zdcat and zocat 10 instead of 6.
     *      - Only a recompile needed.
     *
720 A*    02/25/18  KDE  7.20
     *      - Added fields to c#zoned and Store Zone command
     *      - Added command *STRZONE.  This can be a zone for a
     *        company owned Store offsite from primary warehouse
     *        or some other scenario where you are allocating and
     *        and replenishing this remote area
     *        ** See Notes start of GETSTRZINFO Routine   **
     *
720aA*    05/09/18  KDE  7.20a
     *      - Added check for Case Pick as well as Case Item
     *        before sending back store item
     *
720bA*    08/28/18  KDE  7.20b
     *      - Change UPDSLOTSTR to only run for Store Template
     *
720cA*    08/29/18  KDE  7.20c
     *      - Correct issue in finding Case Pick Item when no Breakdown
     *        exist
     *
720dA*    10/16/18  DAS  7.20d
     *      - Added $zd/$zo fields actv, aisl2, rlvl2, clcde.
     *      - Added dump to pssr routine
     *
720eA*    10/25/18  DAS  7.203
     *      - Added $zd/$zo fields pckovf, cstcod
     *
720fA*    09/11/18  KDE  7.20f (was 720d not brought back)
     *      - If case or breakdown slot sent and not in Store return without
     *        doing any store code
     *
720gA*    11/16/18  KDE  7.20g
     *      - Return *OK without any further action if Store Replen request
     *        sent and not store definition.  DRIPRTYRPL can send this command
     *        blindy to see if store definition and this prevents eroneous error
     *        which prevents priority replenishment from being created
     *
     *----------------------------------------------------------------
     * Notes
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADD              Add record
      *
      *      *CHANGE           Change single row/col record
      *
      *      *DELETE           Delete record
      *
      *      *GET              Get single row/col record
      *
720 A *      *STRZONE          Determine if Slot/Item sent in is in
      *                        Store type zone and return "Y" "N"
      *                        flag along with other values
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
620bAFzoneh     if   e           k disk
620bAFoptionz   if   e           k disk
720 Afslot3     if   e           k disk
720 Af                                     rename(slrec:slpckrec)
720 Af                                     prefix(pk_)
720fAfslotStr   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D zdrec         E ds                  extname(zoned) inz(*EXTDFT)
720 AD slrec         E ds                  extname(slot) inz(*EXTDFT)
720 AD sqrec         E ds                  extname(StoreSql) inz(*EXTDFT)
720 AD itrec         E ds                  extname(piritem) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ZONED
     D saveVer#        s                   like($zdver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables
     *----------------------------------------------------------------

720 AD $vcount         s              3p 0
720 AD $vcommand       s              8
720 AD $vdesc          s             30
720 AD $vmessage       s             60
720 AD $vmsgk          s              4
720 AD $vprg           s             10
720 AD $vreturn        s             10
720 AD $vreturn8       s              8

720 AD $vwhdp          s                   like($zdwhdp)
720 AD $vwhse          s              3  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

     D error           s               n
     D forever         s               n   inz(*on)
     D lock            s               n
720 Ad pickinstore     s              1
720 Ad pickinwh        s              1
720 Ad sq              c                   const(x'7D')
720 Ad sqlStmt1        s          32740    varying
     D tbLight         s               n
720 Ad whereclause     s          32740    varying
720 Ad wkBDItm         s             15
720 Ad wkCmd           s              1    inz(' ')
720 Ad wkCaseItm       s             15
720 Ad zdcnt           s              2  0
720 Ad zoneLength      s              2  0

     D $gfCmd          s              1
     D $gfFeature      s              1
     D $gfLight        s              1
     D $gfWhse         s              3p 0

     *----------------------------------------------------------------
     *  OPTIONZ data structure
     *----------------------------------------------------------------
     D opzdta          ds
     D  opzend               117    117

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = By descening stop, then slot location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
416aA*    OPNWPL  -  Start new pallet when aisle changes if build method
416aA*               is 2=Location.
500dA*    OPFORD  -  Maximun orders per pallet.
520dM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510dA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520dA*    OPGCDE  -  USF Group Code (0-9).
520cA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520cA*    OPSPAL  -  Merge pallet should only contain
520cA*               items for single truck pallet (Y=Yes, N=No).
520dA*    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opdta1          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 MD  opbmrg                37     37
500 MD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510dAD  opstop                61     61
520dA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520dAD**opgcde                62     62
520cAD  oppkup                62     62
520cAD  opspal                63     63
520dAD  oppitm                64     67  0 inz(0)
     D  opend1               117    117

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

640aA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata

     C                   eval      $zoned = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

720dAC                   if        $zdver# < 3
720dAC                   eval      $zdactvu = *off
720dAC                   eval      $zdactv = ''
720dAC                   eval      $zdaisl2u = *off
720dAC                   eval      $zdaisl2 = ''
720dAC                   eval      $zdrlvl2u = *off
720dAC                   eval      $zdrlvl2 = 0
720dAC                   eval      $zdclcdeu = *off
720dAC                   eval      $zdclcde = ''
720eAC                   eval      $zdpckovfu = *off
720eAC                   eval      $zdpckovf = ''
720eAC                   eval      $zdcstcodu = *off
720eAC                   eval      $zdcstcod = ''
720dAC                   eval      $zoactvu = *off
720dAC                   eval      $zoactv = ''
720dAC                   eval      $zoaisl2u = *off
720dAC                   eval      $zoaisl2 = ''
720dAC                   eval      $zorlvl2u = *off
720dAC                   eval      $zorlvl2 = 0
720dAC                   eval      $zoclcdeu = *off
720dAC                   eval      $zoclcde = ''
720eAC                   eval      $zopckovfu = *off
720eAC                   eval      $zopckovf = ''
720eAC                   eval      $zocstcodu = *off
720eAC                   eval      $zocstcod = ''
720dAC                   endif

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyAdd
     C                   if        not error
     C                   exsr      AddRec
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyChg
     C                   if        not error
     C                   exsr      ChangeRec
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELETE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      VerifyDel
     C                   if        not error
     C                   exsr      DeleteRec
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      GetRec
     C                   if        not error
     C                   exsr      Rec2DS
     C                   endif

720 AC                   when      $psubcmd = '*STRZONE'
720 AC                   exsr      VerifyStrZ
720 AC                   if        DakotaCall and not error
720 AC                   exsr      GetStrZInfo
720 AC                   endif

720 AC                   when      $psubcmd = '*UPDSTRSLT'
720 AC                   exsr      UpdSlotStr

     C                   when      $psubcmd = '*VERIFYADD'
     C                   exsr      VerifyAdd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   exsr      VerifyChg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   exsr      VerifyDel
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $zoned
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

720dAC                   dump(a)

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr

     *   Get feature info.

     C                   eval      $gfWhse = $zdwhse
     C                   call      'GETFEAT'
     C                   parm      '*GET'        $gfCmd
     C                   parm                    $gfWhse
     C                   parm                    $gfFeature
     C                   parm                    $gfLight
     C                   if        $gfLight = 'Y'
     C                   eval      tbLight = *on
     C                   else
     C                   eval      tbLight = *off
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------

     C     aaacallhost   begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr
     C                   endsr

     *----------------------------------------------------------------
     *  AddRec   Add record
     *----------------------------------------------------------------

     C     AddRec        begsr
      /free

         // Clear record.

         clear zdrec;

         // Move information into fields.

         zdwhse = $zdwhse;
         zdtruk = $zdtruk;
         zdzone = $zdzone;
         zdwhdp = $zdwhdp;

         if $zdstypu;
           zdstyp = $zdstyp;
         endif;

         if $zdaislu;
           zdaisl = $zdaisl;
         endif;

720dA    if $zdaisl2u;
720dA      zdaisl2 = $zdaisl2;
720dA    endif;

         if $zdrlvlu;
           zdrlvl = $zdrlvl;
         endif;

720dA    if $zdrlvl2u;
720dA      zdrlvl2 = $zdrlvl2;
720dA    endif;

         if $zdloc1u;
           zdloc1 = $zdloc1;
         endif;

         if $zdloc2u;
           zdloc2 = $zdloc2;
         endif;

         if $zddesgu;
           zddesg = $zddesg;
         endif;

720dA    if $zdactvu;
720dA      zdactv = $zdactv;
720dA    endif;

         if $zdcatu;
           zdcat = $zdcat;
         endif;

720dA    if $zdclcdeu;
720dA      zdclcde = $zdclcde;
720dA    endif;

720eA    if $zdpckovfu;
720eA      zdpckovf = $zdpckovf;
720eA    endif;

720eA    if $zdcstcodu;
720eA      zdcstcod = $zdcstcod;
720eA    endif;

         if $zdhnd1u;
           zdhnd1 = $zdhnd1;
         endif;

         if $zdhnd2u;
           zdhnd2 = $zdhnd2;
         endif;

         if $zdutypu;
           zdutyp = $zdutyp;
         endif;

         if $zdsideu;
           zdside = $zdside;
         endif;

         // Add record

             exec sql insert into zoned values(:zdrec);

             if sqlstt <> sqlSuccess;
               error = *on;
               $preturn = 'ERRADDREC';
               $pmessage = 'Error creating zone detail record '
                         + '('
                         + %Trim(%editc($zdwhse:'Z'))
                         + '/'
                         + %trim($zdtruk)
                         + '/'
                         + %trim($zdzone)
                         + '/'
                         + %trim($zdwhdp)
                         + ') ' + sqlstt;
               leavesr;
             endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ChangeRec   Change record.
     *----------------------------------------------------------------

     C     ChangeRec     begsr
      /free

         // Move information into fields.

         zdwhdp = $zdwhdp;

         if $zdstypu;
           zdstyp = $zdstyp;
         endif;

         if $zdaislu;
           zdaisl = $zdaisl;
         endif;

720dA    if $zdaisl2u;
720dA      zdaisl2 = $zdaisl2;
720dA    endif;

         if $zdrlvlu;
           zdrlvl = $zdrlvl;
         endif;

720dA    if $zdrlvl2u;
720dA      zdrlvl2 = $zdrlvl2;
720dA    endif;

         if $zdloc1u;
           zdloc1 = $zdloc1;
         endif;

         if $zdloc2u;
           zdloc2 = $zdloc2;
         endif;

         if $zddesgu;
           zddesg = $zddesg;
         endif;

720dA    if $zdactvu;
720dA      zdactv = $zdactv;
720dA    endif;

         if $zdcatu;
           zdcat = $zdcat;
         endif;

720dA    if $zdclcdeu;
720dA      zdclcde = $zdclcde;
720dA    endif;

720eA    if $zdpckovfu;
720eA      zdpckovf = $zdpckovf;
720eA    endif;

720eA    if $zdcstcodu;
720eA      zdcstcod = $zdcstcod;
720eA    endif;

         if $zdhnd1u;
           zdhnd1 = $zdhnd1;
         endif;

         if $zdhnd2u;
           zdhnd2 = $zdhnd2;
         endif;

         if $zdutypu;
           zdutyp = $zdutyp;
         endif;

         if $zdsideu;
           zdside = $zdside;
         endif;

         exec sql update zoned
                  set zdwhdp = :$zdwhdp,
                      zdstyp = :$zdstyp,
                      zdaisl = :$zdaisl,
720dA                 zdaisl2 = :$zdaisl2,
                      zdrlvl = :$zdrlvl,
720dA                 zdrlvl2 = :$zdrlvl2,
                      zdloc1 = :$zdloc1,
                      zdloc2 = :$zdloc2,
                      zddesg = :$zddesg,
720dA                 zdactv = :$zdactv,
                      zdcat  = :$zdcat,
720dA                 zdclcde = :$zdclcde,
720eA                 zdpckovf = :$zdpckovf,
720eA                 zdcstcod = :$zdcstcod,
                      zdhnd1 = :$zdhnd1,
                      zdhnd2 = :$zdhnd2,
                      zdutyp = :$zdutyp,
                      zdside = :$zdside

                  where zdwhse = :$zdwhse
                    and zdtruk = :$zdtruk
                    and zdzone = :$zdzone
                    and zdwhdp = :$zowhdp
                    and zdstyp = :$zostyp
                    and zdaisl = :$zoaisl
720dA               and zdaisl2 = :$zoaisl2
                    and zdrlvl = :$zorlvl
720dA               and zdrlvl2 = :$zorlvl2
                    and zdloc1 = :$zoloc1
                    and zdloc2 = :$zoloc2
                    and zddesg = :$zodesg
720dA               and zdactv = :$zoactv
                    and zdcat  = :$zocat
720dA               and zdclcde = :$zoclcde
720eA               and zdpckovf = :$zopckovf
720eA               and zdcstcod = :$zocstcod
                    and zdhnd1 = :$zohnd1
                    and zdhnd2 = :$zohnd2
                    and zdutyp = :$zoutyp
                    and zdside = :$zoside;

         if sqlstt <> sqlSuccess;
           error = *on;
           $preturn = 'ERRUPDREC';
           $pmessage = 'Error updating zone detail '
                     + '('
                     + %Trim(%editc($zdwhse:'Z'))
                     + '/'
                     + %trim($zdtruk)
                     + '/'
                     + %trim($zdzone)
                     + '/'
                     + %trim($zdwhdp)
                     + ') ' + sqlstt;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ClearErrFlags  Clear error flag fields.
     *----------------------------------------------------------------

     C     ClearErrFlags begsr
      /free

         if $zdwhsee = '1';
           $zdwhsee = '0';
         endif;

         if $zdtruke = '1';
           $zdtruke = '0';
         endif;

         if $zdwhdpe = '1';
           $zdwhdpe = '0';
         endif;

         if $zdstype = '1';
           $zdstype = '0';
         endif;

         if $zdaisle = '1';
           $zdaisle = '0';
         endif;

720dA    if $zdaisl2e = '1';
720dA      $zdaisl2e = '0';
720dA    endif;

         if $zdrlvle = '1';
           $zdrlvle = '0';
         endif;

720dA    if $zdrlvl2e = '1';
720dA      $zdrlvl2e = '0';
720dA    endif;

         if $zdloc1e = '1';
           $zdloc1e = '0';
         endif;

         if $zdloc2e = '1';
           $zdloc2e = '0';
         endif;

         if $zddesge = '1';
           $zddesge = '0';
         endif;

720dA    if $zdactve = '1';
720dA      $zdactve = '0';
720dA    endif;

         if $zdcate = '1';
           $zdcate = '0';
         endif;

720dA    if $zdclcdee = '1';
720dA      $zdclcdee = '0';
720dA    endif;

720eA    if $zdpckovfe = '1';
720eA      $zdpckovfe = '0';
720eA    endif;

720eA    if $zdcstcode = '1';
720eA      $zdcstcode = '0';
720eA    endif;

         if $zdhnd1e = '1';
           $zdhnd1e = '0';
         endif;

         if $zdhnd2e = '1';
           $zdhnd2e = '0';
         endif;

         if $zdutype = '1';
           $zdutype = '0';
         endif;

         if $zdsidee = '1';
           $zdsidee = '0';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  DeleteRec   Delete record
     *----------------------------------------------------------------

     C     DeleteRec     begsr
      /free
         error = *off;

         // Skip actual delete for *VERIFY.

         if $psubcmd = '*VERIFYDEL';
           leavesr;
         endif;

         // Delete all records for the row

         exec sql delete from zoned
                  where zdwhse = :$zdwhse
                    and zdtruk = :$zdtruk
                    and zdzone = :$zdzone
                    and zdwhdp = :$zdwhdp
                    and zdstyp = :$zdstyp
                    and zdaisl = :$zdaisl
720dA               and zdaisl2 = :$zdaisl2
                    and zdrlvl = :$zdrlvl
720dA               and zdrlvl2 = :$zdrlvl2
                    and zdloc1 = :$zdloc1
                    and zdloc2 = :$zdloc2
                    and zddesg = :$zddesg
720dA               and zdactv = :$zdactv
                    and zdcat  = :$zdcat
720dA               and zdclcde = :$zdclcde
720eA               and zdpckovf = :$zdpckovf
720eA               and zdcstcod = :$zdcstcod
                    and zdhnd1 = :$zdhnd1
                    and zdhnd2 = :$zdhnd2
                    and zdutyp = :$zdutyp
                    and zdside = :$zdside;

         if sqlstt <> sqlSuccess and sqlstt <> sqlNoData;
           error = *on;
           $preturn = 'ERRDELREC';
           $pmessage = 'Error deleting row '
                     + '('
                     + %Trim(%editc($zdwhse:'Z'))
                     + '/'
                     + %trim($zdtruk)
                     + '/'
                     + %trim($zdzone)
                     + '/'
                     + %trim($zdwhdp)
                     + ') ' + sqlstt;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  GetRec     Get record
     *----------------------------------------------------------------

     C     GetRec        begsr
      /free

         exec sql select * into :zdrec
                  from zoned
                  where zdwhse = :$zdwhse
                    and zdtruk = :$zdtruk
                    and zdzone = :$zdzone
                    and zdwhdp = :$zdwhdp
                    and zdstyp = :$zdstyp
                    and zdaisl = :$zdaisl
720dA               and zdaisl2 = :$zdaisl2
                    and zdrlvl = :$zdrlvl
720dA               and zdrlvl2 = :$zdrlvl2
                    and zdloc1 = :$zdloc1
                    and zdloc2 = :$zdloc2
                    and zddesg = :$zddesg
720dA               and zdactv = :$zdactv
                    and zdcat  = :$zdcat
720dA               and zdclcde = :$zdclcde
720eA               and zdpckovf = :$zdpckovf
720eA               and zdcstcod = :$zdcstcod
                    and zdhnd1 = :$zdhnd1
                    and zdhnd2 = :$zdhnd2
                    and zdutyp = :$zdutyp
                    and zdside = :$zdside;

         if sqlstt = sqlSuccess;
           error = *on;
           $preturn = 'RECNOTFND';
           $pmessage = 'Record not found '
                     + '('
                     + %Trim(%editc($zdwhse:'Z'))
                     + '/'
                     + %trim($zdtruk)
                     + '/'
                     + %trim($zdzone)
                     + '/'
                     + %trim($zdwhdp)
                     + ') ' + sqlstt;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  GetMsg   Get message for error code.
     *----------------------------------------------------------------

     C     GetMsg        begsr
      /free

         select;

           when $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#prog);

           other;
             $pmessage = %trim($preturn) + ': Unkown return code';

         endsl;

      /end-free
     C                   endsr

720 A*----------------------------------------------------------------
720 A*  GetStrZinfo Get Store Zone Info
720 A*----------------------------------------------------------------
720 A
     C     getStrZinfo   begsr
720 A /free
720bA    if %subst($zdtstTruk:1:1)='!';
         exsr updSlotStr;
720fA    // If either Breakdown Pick or Case Pick slot sent
720fA    // and it IS NOT IN THE STORE ZONE then return without
720fA    // going further into whether Store Slot
720fA    if $zdstrcpcku;
720fA       chain ($zdwhse:$zdwhdp:$zdstrcpck) slotStr;
720fA       if not %found(slotStr);
720fA          $zdstgflg='N';
720fA          leavesr;
720fA       endif;
720fA    endif;
720fA    if $zdstrbpcku;
720fA       chain ($zdwhse:$zdwhdp:$zdstrbpck) slotStr;
720fA       if not %found(slotStr);
720fA          $zdstgflg='N';
720fA          leavesr;
720fA       endif;
720fA    endif;
         // setup where clause addition to join out to file SlotStr
         // to ensure slot is a Store slot
720 A    zonelength = %len(%trim($zdtstTruk));
         whereclause = ' stwhse=slwhse and stwhdp=slwhdp and' +
                       ' stdisp=sldisp and' +
                       ' substring(sttruk,1,' + %char(zonelength) + ')=' +
                       sq + %subst($zdtstTruk:1:zonelength) + sq +
                       ' and slstat<>' + sq + 'Z' + sq;
720 A
720 A    // It is possible you could send in a pick or case slot
720 A    // that is not in the store and the return values will
720 A    // include the pick and overflow slots in the store so
720 A    // DRIPRTYRPL will not include those slots in the replen
720 A    // for the warehouse slot.  It should only do this when
720 A    // pick slots exist for both warehouse and store.  So in
720 A    // the case of sending the Warehouse slot it will determine
720 A    // that slot does not exist in the store but then look to
720 A    // see if that item has pick and overflow slots in the store.
720 A    // if so it will returns those slots to ensure not considered
720 A    // in Warehouse replen but the $zdStgFlg will be sent back as
720 a    // "N" for no.  IMPORTANT:  The $zdStgFlg should be set to
720 a    // "Y" or "N" based on what request was sent.  Case Item sent
720 a    // and Case ITem in Store it will be a "Y", otherwise "N".  Uses
720 a    // same logic for Case Slot, Breakdown Item, Breakdown Slot.
720 A
720 A    // when breakdown slot is sent
720 A    if $zdstrbpcku;
720 A       exsr getBrkFslt;
720 A    endif;
720 A
720 A    // When Breakdown Item is sent
720 A    if $zdstrbitmu;
720 A       exsr getBrkDown;
720 A    endif;
720 A
720 A    // when Case Slot is sent
720 A    if $zdstrcpcku;
720 A       // read case pick slot record to get case item.  Also ensures
720 A       // in Store Zone.  Otherwise returns N in zdstgflg
720 A       sqlStmt1= 'select * from slot ' +
720 A                 '  where slwhse = ' + %char($zdwhse) +
720 A                 ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                 ' and sldisp=' + sq + %trim($zdstrcpck) + sq +
                      ' and slstat<>' + sq + 'Z' + sq;
720 A       exec sql PREPARE sdc FROM :SqlStmt1;
720 A       exec sql DECLARE sdtlc SCROLL CURSOR FOR sdc;
720 A       exec sql OPEN sdtlc;
720 A       exec sql fetch first from sdtlc into :slrec;
720 A       if sqlstt = sqlSuccess or sqlstt='01503';
720 A          // once case pick slot item found we set
720 A          // Case Item and let that fill information
               $zdstrcpck = sldisp;
               $zdstrcitm=slitem;
            else;
720 A          $zdstrcpck = *blanks;
               $zdstrcitm=*blanks;
            endif;
720 A       exec sql close sdtlc;
720 A    endif;
720 A
720 A    // When Case Item is sent
720 A    if $zdstrcitmu or ($zdstrcitm<>*blanks and $zdstrcpck<>*blanks);
720 A       // if breakdown item is found get that information
720 A       wkbditm=*blanks;
720 A       sqlStmt1= 'select ilitem from itemlnk, piritem' +
720 A                 '  where ilwhse = ' + %char($zdwhse) +
720 A                 ' and ilitm2=' + sq + %trim($zdstrcitm) + sq +
720 A                 ' and ilwhse=itwhse and ilitem=ititem and ' +
720 A                 ' ittype=' + sq + 'B' + sq;
720 A       exec sql PREPARE illop FROM :SqlStmt1;
720 A       exec sql DECLARE illoop SCROLL CURSOR FOR illop;
720 A       exec sql OPEN illoop;
720 A       exec sql fetch first from illoop into :wkbditm;
            dow sqlstt = sqlSuccess and $zdstrbpck=*blanks;
720 A          if wkbditm<>*blanks;
720 A             $zdstrbitm = wkbditm;
720 A             exsr getBrkDown;
720 A          else;
720 A             $zdstrbitm = *blanks;
720 A          endif;
720 A          exec sql fetch next from illoop into :wkbditm;
            enddo;

720cA       // If no breakdown found for sent case item look only
720cA       // for Case slot.
720cA       if wkbditm = *blanks;
720cA       sqlStmt1= 'select slot.* from slot,slotstr ' +
720cA                 '  where slwhse = ' + %char($zdwhse) +
720cA                 ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720cA                 ' and slitem=' + sq + %trim($zdstrcitm) + sq +
720cA                 ' and slpick=' + sq + 'Y' + sq +
720cA                 ' and slstat<>' + sq + 'Z' + sq +
720cA                 ' and ' + %trim(whereClause);
720cA       exec sql PREPARE csl FROM :SqlStmt1;
720cA       exec sql DECLARE csllc SCROLL CURSOR FOR csl;
720cA       exec sql OPEN csllc;
720cA       exec sql fetch first from csllc into :slrec;
720cA       if sqlstt = sqlSuccess or sqlstt='01503';
720cA          // once case pick slot item found we set
720cA          // Case Item and let that fill information
720cA          $zdstrcpck = sldisp;
720cA          $zdstrcitm=slitem;
720cA       else;
720cA          $zdstrcpck = *blanks;
720cA          $zdstrcitm=*blanks;
720cA       endif;
720cA       exec sql close sdtlc;
720cA       endif;

720 A       exec sql close illoop;
720 A       // If Case Pick Slot is empty coming back from Breakdown Item
720 A       // routine we should look to see if Case Item is in Zone since
720 A       // it was sent in specifically. The reason this could happen is
720 A       // the code used when Case Item requested is to look for breakdown
720 A       // for that Case Item and populate that data in getBrkDown.  If
720 A       // that breakdown does not exist or not within the store zone it
720 A       // will not populate the Case Pick Slot.  However, the Case Item
720 A       // and a Case Pick Slot could exist in Store Zone.  Therefore,
720 A       // when it returns from getBrkDown we query Slot file for the Case
720 A       // as a pick in the Store Zone. If it is found we populate the
720 A       // Store Pick Slot and place a "Y" in StgFlg since Case ITem was
720 A       // specifically asked for.
720 A       sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                 '  where slwhse = ' + %char($zdwhse) +
720 A                 ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                 ' and sldisp=' + sq + %trim($zdstrcpck) + sq +
720 A                 ' and slpick=' + sq + 'Y' + sq +
720 A                 ' and ' + %trim(whereClause);
720 A       exec sql PREPARE idbcc FROM :SqlStmt1;
720 A       exec sql DECLARE idtlbcc SCROLL CURSOR FOR idbcc;
720 A       exec sql OPEN idtlbcc;
720 A       exec sql fetch first from idtlbcc into :slrec;
720 A       if sqlstt = sqlSuccess or sqlstt='01503'
720aA          and $zdstrcpcku=*off and $zdstrcitmu=*off;
               $zdstgflg='Y';
720 A       else;
720 A          // Case Item Pick Slot not found in Store Zone
               $zdstgflg='N';
720 A       endif;
720 A       exec sql close idtlbcc;

            // Now get any overflow for case item found in store zone
720 A       sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                 '  where slwhse = ' + %char($zdwhse) +
720 A                 ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                 ' and slitem=' + sq + %trim($zdstrcitm) + sq +
720 A                 ' and slpick <>' + sq + 'Y' + sq +
720 A                 ' and ' + %trim(whereClause);
720 A       exec sql PREPARE ovic FROM :SqlStmt1;
720 A       exec sql DECLARE oflic SCROLL CURSOR FOR ovic;
720 A       exec sql OPEN oflic;
720 A       exec sql fetch first from oflic into :slrec;
720 A       dow sqlStt = sqlSuccess or sqlstt='01503';
720 A          select;
720 A             when $zdstrovf1 = *blanks;
720 A                  $zdstrovf1 = sldisp;
720 A             when $zdstrovf2 = *blanks;
720 A                  $zdstrovf2 = sldisp;
720 A               when $zdstrovf3 = *blanks;
720 A                    $zdstrovf3 = sldisp;
720 A                    leave;
720 A            endsl;
720 A            exec sql fetch next from oflic into :slrec;
720 A       enddo;
720 A       exec sql close oflic;
720 A    endif;
720 A
720 A
720 A    // Look to see if either the case item has pick slots in both
720 A    // the store and warehouse.  Field $zdwhcpck='Y' if they exist in both
720 A    // this loops through slot3 looking at each available pick slot for the
720 A    // item in this warehouse.  By hitting each with the whereclause we can
720 A    // determine if in the store.  If slot lives in the store we set a pick
720 A    // otherwise pickinwh.  At end of loop it sets return value of $zdwhcpc
720 A    // if pick slots exist in both Store and Warehouse, otherwise set to 'N
720 A    pickinstore = *blanks;
720 A    pickinwh = *blanks;
720 A    if $zdStgFlg='Y' and $zdstrcitm<>*blanks;
720 A       setll ($zdwhse:$zdstrcitm:'A':'Y') slot3;
720 A       reade ($zdwhse:$zdstrcitm:'A':'Y') slot3;
720 A       dow not %eof(slot3);
720 A          sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                    '  where slwhse = ' + %char(pk_slwhse) +
720 A                    ' and slwhdp=' + sq + %trim(pk_slwhdp) + sq +
720 A                    ' and sldisp=' + sq + %trim(pk_sldisp) + sq +
720 A                    ' and ' + %trim(whereClause);
720 A          exec sql PREPARE whcpk FROM :SqlStmt1;
720 A          exec sql DECLARE whcpck SCROLL CURSOR FOR whcpk;
720 A          exec sql OPEN whcpck;
720 A          exec sql fetch first from whcpck into :slrec;
720 A          if sqlStt = sqlSuccess or sqlstt='01503';
720 A             pickinstore = 'Y';
720 A          else;
720 A             pickinwh = 'Y';
720 A          endif;
720 A          exec sql close whcpck;
720 A          reade ($zdwhse:$zdstrcitm:'A':'Y') slot3;
720 A       enddo;  // Read thru all active Picks for this item
720 A    endif;     // Case Item is not blank
720 A    if pickinstore='Y' and pickinwh='Y';
720 A       $zdwhcpck = 'Y';
720 A    else;
720 A       $zdwhcpck = 'N';
720 A    endif;
720 A
720 A
720 A    // Look to see if either the Breakdown item has pick slots in both
720 A    // the store and warehouse.  Field $zdwhbpck='Y' if they exist in both
720 A    // this loops through slot3 looking at each available pick slot for the
720 A    // item in this warehouse.  By hitting each with the whereclause we can
720 A    // determine if in the store.  If slot lives in the store we set a pick
720 A    // otherwise pickinwh.  At end of loop it sets return value of $zdwhbpc
720 A    // if pick slots exist in both Store and Warehouse, otherwise set to 'N
720 A    pickinstore = *blanks;
720 A    pickinwh = *blanks;
720 A    if $zdStgFlg='Y' and $zdstrbitm<>*blanks;
720 A       setll ($zdwhse:$zdstrbitm:'A':'Y') slot3;
720 A       reade ($zdwhse:$zdstrbitm:'A':'Y') slot3;
720 A       dow not %eof(slot3);
720 A          sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                    '  where slwhse = ' + %char(pk_slwhse) +
720 A                    ' and slwhdp=' + sq + %trim(pk_slwhdp) + sq +
720 A                    ' and sldisp=' + sq + %trim(pk_sldisp) + sq +
720 A                    ' and slpick=' + sq + 'Y' + sq +
720 A                    ' and ' + %trim(whereClause);
720 A          exec sql PREPARE whbpk FROM :SqlStmt1;
720 A          exec sql DECLARE whbpck SCROLL CURSOR FOR whbpk;
720 A          exec sql OPEN whbpck;
720 A          exec sql fetch first from whbpck into :slrec;
720 A          if sqlStt = sqlSuccess or sqlstt='01503';
720 A             pickinstore = 'Y';
720 A          else;
720 A             pickinwh = 'Y';
720 A          endif;
720 A          exec sql close whbpck;
720 A          reade ($zdwhse:$zdstrbitm:'A':'Y') slot3;
720 A       enddo;  // Read thru all active Picks for this item
720 A    endif;     // Case Item is not blank
720 A    if pickinstore='Y' and pickinwh='Y';
720 A       $zdwhbpck = 'Y';
720 A    else;
720 A       $zdwhbpck = 'N';
720 A    endif;
720 A
720bA    endif;    // Truck begins with !
720 A /end-free
720 Ac     endgetstrZ    endsr

720 A*----------------------------------------------------------------
720 A*  UpdSlotStr  Update Slot Store and StoreSql based on Command
720 A*----------------------------------------------------------------
720 A
     C     updSlotStr    begsr

      /free
720 A    // Build SQL where clause with all Zone selections
720 A    // from Zoned to use as checkpoint against SlotStr to
720 A    // determine add and deletes per maintenance
720 A
720 A    // Build ZONED query for Template passed in and requested
720bA    if %subst($zdtstTruk:1:1)='!';
         if  $zdCmd = 'A';
720 A     zonelength = %len(%trim($zdtstTruk));
720 A     sqlStmt1 = 'select * from zoned ' +
720 A               '  where zdwhse = ' + %char($zdwhse) +
720 A               ' and substring(zdTruk,1,' + %char(zonelength) + ')=' +
720 A               sq + %subst($zdtstTruk:1:zonelength) + sq;
720 A     exec sql PREPARE zd FROM :SqlStmt1;
720 A     exec sql DECLARE zdtl SCROLL CURSOR FOR zd;
720 A     exec sql OPEN zdtl;
720 A     exec sql fetch first from zdtl into :zdrec;
720 A
720 A     whereclause = *blanks;
720 A     dow sqlStt = '00000';
720 A        // build where clause to do and's between each field
720 A        // for each defined Zoned record for given Zone definition
720 A        // and do or's between records.  In other words the Zone
720 A        // definition passed in could be represented in one or many
720 A        // Zone definitions records and it considers them all to
720 A        // determine if Item or Slot sent belong to said Zone

720 A        // Notcluase is used to determine if any pick slots exist
720 A        // in the warehouse when they exist in the Store
720 A
720 A        if whereclause <> *blanks;
720 A           // this means previous record(s) read and need or
720 A           whereclause = %trim(whereclause) + ') or (';
720 A        else;
720 A           whereclause = '(';
720 A        endif;
720 A
720 A        if zdwhdp<>*blanks;   // Department
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slwhdp=' +
720 A                       sq + %trim(zdwhdp) + sq;
720 A        endif;
720 A        if zdstyp<>*blanks;   // Section Type
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slstyp=' +
720 A                        sq + %trim(zdstyp) + sq;
720 A        endif;
720 A        if zdaisl<>*blanks;   // Slot Aisle
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slaisl=' +
720 A                        sq + zdaisl + sq;
720 A        endif;
720 A        if zdrlvl<>*zeros;   // Slot Level
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slrlvl=' +
720 A                        %char(zdrlvl);
720 A        endif;
720 A        // always include from Location even if zero
720 A        exsr IncAnd;
720 A        whereClause = %trim(whereclause) + ' slloc>=' +
720 A                        %char(zdloc1);
720 A
720 A        if zdloc2<>*zeros;   // To Location
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slloc<=' +
720 A                        %char(zdloc2);
720 A        endif;
720 A        if zddesg<>*blanks;  // Designation
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' sldesg=' +
720 A                        sq + %trim(zddesg) + sq;
720 A        endif;
720 A        // always include from Hand even if blank
720 A        exsr IncAnd;
720 A        whereClause = %trim(whereclause) + ' slhand>=' +
720 A                      sq + %trim(zdhnd1) + sq;
720 A        if zdhnd2<>*blanks;  // To Hand
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slhand<=' +
720 A                        sq + %trim(zdhnd2) + sq;
720 A        endif;
720 A        if zdside<>*blanks;  // Side
720 A          exsr IncAnd;
720 A          whereClause = %trim(whereclause) + ' slside=' +
720 A                        sq + %trim(zdside) + sq;
720 A        endif;
720 A        exec sql fetch next from zdtl into :zdrec;
720 A     enddo;
720 A     exec sql close zdtl;
720 A     whereclause = '(' + %trim(whereclause) + '))';
          exec sql select * into :sqrec
                from STORESQL
                   where sqwhse=:zdwhse and sqtruk=:zdtruk;
          if sqlStt = '00000';
             sqwhere = %trim(whereclause);
             $zdtsttruk = sqtruk;
             exec sql update STORESQL set sqWhere=:sqwhere
                    where sqwhse=:zdwhse and sqtruk=:zdtruk;
          else;
             sqwhse = zdwhse;
             sqtruk = zdtruk;
             $zdtsttruk = zdtruk;
             sqwhere = %trim(whereclause);
             exec sql insert into STORESQL
                    values(:sqwhse,:sqtruk,:sqwhere);
          endif;

          // Delete any records in SlotStr but not in Slot Store Zone
          // This is only ran when changes are made to the Zoned Template
          // since the joins with Slot and Slotstr exclude any slots with
          // status of Z.  This reduces runtime during replenishments and
          // other activities checking slot to see if in store.  The add
          // still occurs on every call since slots can be created all
          // the time.
          sqlstmt1= 'delete from SlotStr ' +
                    'Where ' +
                    '(select count(*) from slot where ' +
                    'stwhse=slwhse and stwhdp=slwhdp and ' +
                    'stdisp=sldisp and sttruk=' + sq + %trim($zdtstTruk) +
                    sq + ' and ' + %trim(whereclause) + ')=0';

          exec sql execute immediate :sqlStmt1;

         else;

            // when "A" is not sent as command (ALL) then simply
            // retrieve latest modified store sql where clause to
            // use in Addition and Deletion sql's below to make
            // sure SlotStr (Store Slots) file is dynamically updated
720 A       zonelength = %len(%trim($zdtstTruk));
720 A       sqlStmt1 = 'select * from StoreSql ' +
720 A                 '  where sqwhse = ' + %char($zdwhse) +
720 A                ' and substring(sqTruk,1,' + %char(zonelength) + ')=' +
720 A                 sq + %subst($zdtstTruk:1:zonelength) + sq;
720 A       exec sql PREPARE ss FROM :SqlStmt1;
720 A       exec sql DECLARE ssql SCROLL CURSOR FOR ss;
720 A       exec sql OPEN ssql;
720 A       exec sql fetch first from ssql into :sqrec;
            if SqlStt = '00000';
               $zdtsttruk = sqtruk;
               whereclause = %trim(sqWhere);
            else;
               $zdtsttruk = *blanks;
               whereClause = *blanks;
            endif;
720 A       exec sql CLOSE ssql;
         endif;

         //  Add any records to SlotStr that are in Slot Store Zone
         //  but not in SlotStr
         sqlstmt1= 'insert into SlotStr ' +
                   'select slwhse,slwhdp,sldisp,' + sq + %trim($zdtstTruk) +
                   sq + ' from slot Where ' + %trim(whereClause) +
                   ' and (select count(*) from slotstr where ' +
                   'stwhse=slwhse and stwhdp=slwhdp and ' +
                   'stdisp=sldisp and sttruk=' + sq + %trim($zdtstTruk) +
                   sq + ')=0';

         exec sql execute immediate :sqlStmt1;
720bA  endif;    // do not perform unless Store Template (exclamation point)
      /end-free
     C                   endsr
720 A
720 A*----------------------------------------------------------------
720 A*  IncAnd  Include "And" in complex SQL String
720 A*----------------------------------------------------------------
720 A
720 AC     IncAnd        begsr
720 A /free
720 A         if %subst(%trim(whereclause):%len(%trim(whereclause))
720 A                      :1) <> '(';
720 A            whereclause = %trim(whereclause) + ' and ';
720 A         endif;
720 A /end-free
720 AC                   endsr

720 A*----------------------------------------------------------------
720 A*  GetBrkFslt  Get Breakdown information from Breakdown Slot
720 A*----------------------------------------------------------------
720 A
720 AC     GetBrkFslt    begsr
720 A /free
720 A       // since slot sent in see if this slot is found in
720 A       // the criteria for Zone passed in with whereclause
720 A       sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                 '  where slwhse = ' + %char($zdwhse) +
720 A                 ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                 ' and sldisp=' + sq + %trim($zdstrbpck) + sq +
720 A                 ' and ' + %trim(whereClause);
720 A       exec sql PREPARE sd FROM :SqlStmt1;
720 A       exec sql DECLARE sdtl SCROLL CURSOR FOR sd;
720 A       exec sql OPEN sdtl;
720 A       exec sql fetch first from sdtl into :slrec;
720 A       if sqlstt = sqlSuccess or sqlstt='01503';
720 A          // Passed in Slot was found in Store Zone passed
720 A          $zdstgflg = 'Y';
720 A          $zdstrbitm = slitem;
720 A          // if Breakdown item get case item
720 A          wkcaseitm=*blanks;
720 A          exec sql select ilitm2 into :wkcaseitm
720 A                    from itemlnk,piritem
720 A                     where ilwhse=:$zdwhse and
720 A                      ilitem=:$zdstrbitm and ilwhse=itwhse
720 A                      and ilitem=ititem and (ittype='S' or ittype='B')
720 A                       fetch first row only;
720 A          if sqlstt = sqlSuccess;
720 A             $zdstrcitm = wkcaseitm;
720 A             sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                       '  where slwhse = ' + %char($zdwhse) +
720 A                       ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                       ' and slitem=' + sq + %trim(wkCaseitm) + sq +
                            ' and slpick=' + sq + 'Y' + sq +
720 A                       ' and ' + %trim(whereClause);
720 A             exec sql PREPARE scs FROM :SqlStmt1;
720 A             exec sql DECLARE scas SCROLL CURSOR FOR scs;
720 A             exec sql OPEN scas;
720 A             exec sql fetch first from scas into :slrec;
                  // setup Case Pick Slot return based on previous query
                  if sqlStt = sqlSuccess or sqlstt='01503';
720 A                $zdstrcitm=slitem;
720 A                $zdstrcpck=sldisp;
                  else;
720 A                $zdstrcitm=wkcaseitm;
720 A                $zdstrcpck=*blanks;
                  endif;
720 A             exec sql close scas;
720 A          else;
720 A             $zdstrcitm=*blanks;
720 A             $zdstrcpck=*blanks;
720 A          endif;
               if wkcaseitm <> *blanks;
720 A          sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                    '  where slwhse = ' + %char($zdwhse) +
720 A                    ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                    ' and slitem=' + sq + %trim(wkcaseitm) + sq +
720 A                    ' and slpick <>' + sq + 'Y' + sq +
720 A                    ' and ' + %trim(whereClause);
720 A          exec sql PREPARE ovr FROM :SqlStmt1;
720 A          exec sql DECLARE oflw SCROLL CURSOR FOR ovr;
720 A          exec sql OPEN oflw;
720 A          exec sql fetch first from oflw into :slrec;
720 A          dow sqlStt = sqlSuccess or sqlstt='01503';
720 A             select;
720 A                when $zdstrovf1 = *blanks;
720 A                   $zdstrovf1 = sldisp;
720 A                when $zdstrovf2 = *blanks;
720 A                   $zdstrovf2 = sldisp;
720 A                when $zdstrovf3 = *blanks;
720 A                   $zdstrovf3 = sldisp;
720 A                   leave;
720 A             endsl;
720 A             exec sql fetch next from oflw into :slrec;
720 A          enddo;
720 A          exec sql close oflw;
720 A          endif;
720 A       else;
720 A         // Slot not found in Store Zone.  Get item for Brakdown Slot,
              // check to see if item shows another slot as store slot, and
              // return as zdStgFlg='N' since passed in slot not in store.
              // ** The reason we return the defined Store Pick Slot even
              // though passed slot not in store is to exclude the Store slot
              // from any type replenishment **
720 A         exec sql select slitem into :$zdstrbitm      // get item in bd slo
                          from slot
720 A                      where slwhse = :$zdwhse
720 A                        and slwhdp=:$zdwhdp
720 A                        and sldisp=:$zdstrbpck;
              exsr getBrkDown;
720 A         $zdstgflg='N';
720 A       endif;
720 A       exec sql close sdtl;
720 A /end-free
720 AC                   endsr

720 A*----------------------------------------------------------------
720 A*  GetBrkDown  Get Breakdown information from passed BD Item
720 A*----------------------------------------------------------------
720 A
720 AC     GetBrkDown    begsr
720 A /free
720 A       // when item is sent see if pick slot exist in
720 A       // Zoned passed in.
720 A       sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                 '  where slwhse = ' + %char($zdwhse) +
720 A                 ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                 ' and slitem=' + sq + %trim($zdstrbitm) + sq +
720 A                 ' and slpick=' + sq + 'Y' + sq +
720 A                 ' and ' + %trim(whereClause);
720 A       exec sql PREPARE id FROM :SqlStmt1;
720 A       exec sql DECLARE idtl SCROLL CURSOR FOR id;
720 A       exec sql OPEN idtl;
720 A       exec sql fetch first from idtl into :slrec;
720 A       if sqlstt = sqlSuccess or sqlstt='01503';
720 A          // Passed in Slot was found in Store Zone passed
720 A          // but only mark as Stgflg='Y' if Breakdown was passed in
720 A          // and not looping here because of Case Item passed in
720aD   //     if $zdstrcitmu = *off;
720aA          if $zdstrcitmu = *off and $zdstrcpcku = *off;
720 A             $zdstgflg = 'Y';
               endif;
720 A          $zdstrbpck = sldisp;
720 A          // Since Breakdown item get case
720 A          wkcaseitm=*blanks;
720 A          exec sql select ilitm2 into :wkcaseitm
720 A                    from itemlnk,piritem
720 A                     where ilwhse=:$zdwhse and
720 A                      ilitem=:$zdstrbitm and ilwhse=itwhse
720 A                      and ilitem=ititem and (ittype='S' or ittype='B')
720 A                       fetch first row only;
720 A          // if case item sent use that instead
720 A          if $zdstrcitmu = *on and wkcaseitm=*blanks;
720 A             wkcaseitm = $zdstrcitm;
720 A          endif;
720 A          if sqlstt = sqlSuccess or wkcaseitm<>*blanks;
720 A             sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                       '  where slwhse = ' + %char($zdwhse) +
720 A                       ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                       ' and slitem=' + sq + %trim(wkcaseitm) + sq +
720 A                       ' and slpick=' + sq + 'Y' + sq +
720 A                       ' and ' + %trim(whereClause);
720 A             exec sql PREPARE idbc FROM :SqlStmt1;
720 A             exec sql DECLARE idtlbc SCROLL CURSOR FOR idbc;
720 A             exec sql OPEN idtlbc;
720 A             exec sql fetch first from idtlbc into :slrec;
720 A             if sqlstt = sqlSuccess or sqlstt='01503';
720aA                if $zdstrcitmu = *off;
720 A                   $zdstrcitm = wkcaseitm;
720aA                endif;
720aA                if $zdstrcpcku = *off;
720 A                   $zdstrcpck = sldisp;
720aA                endif;
720 A             else;
720 A                // Case Item Pick Slot not found in Store Zone
720 A                $zdstrcitm = wkcaseitm;
720 A                $zdstrcpck = *blanks;
720 A             endif;
                  // Now get any overflow for case item found in store zone
720 A             sqlStmt1= 'select slot.* from slot,slotstr ' +
720 A                       '  where slwhse = ' + %char($zdwhse) +
720 A                       ' and slwhdp=' + sq + %trim($zdwhdp) + sq +
720 A                       ' and slitem=' + sq + %trim(wkcaseitm) + sq +
720 A                       ' and slpick <>' + sq + 'Y' + sq +
720 A                       ' and ' + %trim(whereClause);
720 A             exec sql PREPARE ovi FROM :SqlStmt1;
720 A             exec sql DECLARE ofli SCROLL CURSOR FOR ovi;
720 A             exec sql OPEN ofli;
720 A             exec sql fetch first from ofli into :slrec;
720 A             dow sqlStt = sqlSuccess or sqlstt='01503';
720 A                select;
720 A                   when $zdstrovf1 = *blanks;
720 A                         $zdstrovf1 = sldisp;
720 A                      when $zdstrovf2 = *blanks;
720 A                         $zdstrovf2 = sldisp;
720 A                      when $zdstrovf3 = *blanks;
720 A                         $zdstrovf3 = sldisp;
720 A                         leave;
720 A                   endsl;
720 A                   exec sql fetch next from ofli into :slrec;
720 A                enddo;
720 A                exec sql close idtlbc;
720 A             exec sql close ofli;
720 A          else;
720 A             // Case Item not found
720 A             $zdstrcitm = *blanks;
720 A             $zdstrcpck = *blanks;
720 A          endif;
720 A       else;
720 A         // Slot not found in Store Zone passed
              exec sql select ilitm2 into :$zdstrcitm
                  from itemlnk
                    where ilwhse=:$zdwhse and ilitem=:$zdstrbitm;
720 A         $zdstgflg='N';
720 A       endif;
720 A       exec sql close idtl;
720 A /end-free
720 AC                   endsr

     *----------------------------------------------------------------
     *  Rec2DS  Move fields to data structure fields
     *----------------------------------------------------------------

     C     Rec2DS        begsr
      /free

         // Initialize data structure

         savever# = $zdver#;
         clear $zoned;
         $zdver# = savever#;

         // Move information to data structure.

         $zdwhse = zdwhse;
         $zdtruk = zdtruk;
         $zdwhdp = zdwhdp;
         $zdstyp = zdstyp;
         $zdaisl = zdaisl;
720dA    $zdaisl2 = zdaisl2;
         $zdrlvl = zdrlvl;
720dA    $zdrlvl2 = zdrlvl2;
         $zdloc1 = zdloc1;
         $zdloc2 = zdloc2;
         $zddesg = zddesg;
720dA    $zdactv = zdactv;
         $zdcat  = zdcat;
720dA    $zdclcde = zdclcde;
720eA    $zdpckovf = zdpckovf;
720eA    $zdcstcod = zdcstcod;
         $zdhnd1 = zdhnd1;
         $zdhnd2 = zdhnd2;
         $zdutyp = zdutyp;
         $zdside = zdside;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VerifyAdd  Verify information when adding.
     *----------------------------------------------------------------

     C     VerifyAdd     begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr VfyzdSent;
         if error;
           leavesr;
         endif;

         // Zone header record must exist

         exsr vfyzoneh;
         if error;
           leavesr;
         endif;

         // Verify department

         exsr vfyzdwhdp;
         if error;
           leavesr;
         endif;

         // Verify PRE is okay

         exsr vfyPRE;
         if error;
           leavesr;
         endif;

         // Verify section

         exsr vfyzdstyp;
         if error;
           leavesr;
         endif;

         // Verify aisle

         exsr vfyzdaisl;
         if error;
           leavesr;
         endif;

         // Verify Truck Builder Light

         exsr vfyLight;
         if error;
           leavesr;
         endif;

         // Verify level

         exsr vfyzdrlvl;
         if error;
           leavesr;
         endif;

         // Verify location

         exsr vfyzdloc;
         if error;
           leavesr;
         endif;

         // Verify handstack

         exsr vfyzdhnd;
         if error;
           leavesr;
         endif;

         // Verify designation

         exsr vfyzddesg;
         if error;
           leavesr;
         endif;

720dA    // Verify activity zone
720dA
720dA    exsr vfyzdactv;
720dA    if error;
720dA      leavesr;
720dA    endif;

         // Verify category

         exsr vfyzdcat;
         if error;
           leavesr;
         endif;

720dA    // Verify class code
720dA
720dA    exsr vfyzdclcde;
720dA    if error;
720dA      leavesr;
720dA    endif;

720eA    // Verify slot type (pick/overflow)
720eA
720eA    exsr vfyzdpckovf;
720eA    if error;
720eA      leavesr;
720eA    endif;

720eA    // Verify customer code
720eA
720eA    exsr vfyzdcstcod;
720eA    if error;
720eA      leavesr;
720eA    endif;

         // Verify UOM type

         exsr vfyzdutyp;
         if error;
           leavesr;
         endif;

         // Verify Side

         exsr vfyzdside;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VerifyChg   Verfify slot information for change
     *----------------------------------------------------------------

     C     VerifyChg     begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzdSent;
         if error;
           leavesr;
         endif;

         exsr vfyzoSent;
         if error;
           leavesr;
         endif;

         // Verify department

         exsr vfyzdwhdp;
         if error;
           leavesr;
         endif;

         // Verify PRE is okay

         exsr vfyPRE;
         if error;
           leavesr;
         endif;

         // Verify section

         exsr vfyzdstyp;
         if error;
           leavesr;
         endif;

         // Verify aisle

         exsr vfyzdaisl;
         if error;
           leavesr;
         endif;

         // Verify Truck Builder Light

         exsr vfyLight;
         if error;
           leavesr;
         endif;

         // Verify level

         exsr vfyzdrlvl;
         if error;
           leavesr;
         endif;

         // Verify location

         exsr vfyzdloc;
         if error;
           leavesr;
         endif;

         // Verify handstack

         exsr vfyzdhnd;
         if error;
           leavesr;
         endif;

         // Verify designation

         exsr vfyzddesg;
         if error;
           leavesr;
         endif;

720dA    // Verify activity zone
720dA
720dA    exsr vfyzdactv;
720dA    if error;
720dA      leavesr;
720dA    endif;

         // Verify category

         exsr vfyzdcat;
         if error;
           leavesr;
         endif;

720dA    // Verify class code
720dA
720dA    exsr vfyzdclcde;
720dA    if error;
720dA      leavesr;
720dA    endif;

720eA    // Verify slot type (pick, overflow)
720eA
720eA    exsr vfyzdpckovf;
720eA    if error;
720eA      leavesr;
720eA    endif;

720eA    // Verify customer code
720eA
720eA    exsr vfyzdcstcod;
720eA    if error;
720eA      leavesr;
720eA    endif;

         // Verify UOM type

         exsr vfyzdutyp;
         if error;
           leavesr;
         endif;

         // Verify Side

         exsr vfyzdside;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VerifyDel  Verify information when deleting
     *----------------------------------------------------------------

     C     VerifyDel     begsr
      /free

         exsr clearerrflags;

         // Verify that necessary fields were sent.

         exsr vfyzdSent;
         if error;
           leavesr;
         endif;

      /end-free
     C                   endsr

720 A*----------------------------------------------------------------
720 A*  VerifyStrZ  Verify information sent to check/retieve info
720 A*              regarding Zone Store is valid
720 A*----------------------------------------------------------------
720 A
720 AC     VerifyStrZ    begsr
720 A
720bAc                   eval      error=*off
720bA
720 A*  Verify warehouse.
720 A
720 AC                   call(e)   'VFYWHSE'
720 AC                   parm      '*VERIFY'     $vcommand
720 AC                   parm      '*NONE'       $vprg
720 AC                   parm      $zdwhse       $vwhse
720 AC                   parm      ' '           $vdesc
720 AC                   parm      ' '           $vreturn
720 AC                   parm      ' '           $vmessage
720 AC                   parm      ' '           $vmsgk
720 A
720 AC                   select
720 AC                   when      %error
720 AC                   eval      error = *on
720 AC                   eval      $zdwhsee = '1'
720 AC                   eval      $preturn  = 'CALLERROR'
720 AC                   eval      $pmessage = 'Error occured on call to '
720 AC                                       + 'VFYWHSE'
720 AC                                       + '/' + %trim($vcommand)
720 AC                                       + ' from ' + #prog
720 AC                   goto      endvfystr
720 A
720 AC                   when      $vreturn <> '*OK'
720 AC                   eval      error = *on
720 AC                   eval      $zdwhsee = '1'
720 AC                   eval      $preturn = $vreturn
720 AC                   eval      $pmessage = $vmessage
720 AC                   goto      endvfystr
720 A
720 AC                   endsl
720 A
720 A*  Verify warehouse department.
720 A
720 AC                   call(e)   'VFYWHDP'
720 AC                   parm      '*VERIFY'     $vcommand
720 AC                   parm      '*NONE'       $vprg
720 AC                   parm      $zdwhse       $vwhse
720 AC                   parm      $zdwhdp       $vwhdp
720 AC                   parm      ' '           $vdesc
720 AC                   parm      ' '           $vreturn
720 AC                   parm      ' '           $vmessage
720 AC                   parm      ' '           $vmsgk
720 A
720 AC                   select
720 AC                   when      %error
720 AC                   eval      error = *on
720 AC                   eval      $zdwhdpe = '1'
720 AC                   eval      $preturn  = 'CALLERROR'
720 AC                   eval      $pmessage = 'Error occured on call to '
720 AC                                       + 'VFYWHDP'
720 AC                                       + '/' + %trim($vcommand)
720 AC                                       + ' from ' + #prog
720 AC                   goto      endvfystr
720 AC                   when      $vreturn <> '*OK'
720 AC                   eval      error = *on
720 AC                   eval      $zdwhdpe = '1'
720 AC                   eval      $preturn = $vreturn
720 AC                   eval      $pmessage = $vmessage
720 AC                   goto      endvfystr
720 AC                   endsl
720 A
720 A*  Verify incoming Truck Definition.  Store/Remote
720 A*  Truck must begin with ! (exclamation point)
720 A
720 A /free
720 A            if not $zdtsttruku;
720bA               error = *on;
720 A               $preturn = 'TRUKEMPTY';
720 A               $pMEssage = 'Truck Definition must'
720 A                         + 'be sent with Store Zone check';
720 A /end-free
720 AC                   goto      endvfystr
720 A /free
720 A            else;
720 A          // if Store Truck was sent ensure it begins with
720 A          // exclamation point and portion sent is found
720 A          // in ZoneD file
720 A               if %subst($zdTstTruk:1:1) <> '!';
720bA               error = *on;
720 A               $preturn = 'FRSTZCHAR';
720 A               $pMEssage = 'Trucknition must'
720 A                         + 'begin with ! for Store Zone';
720 A /end-free
720 AC                   goto      endvfystr
720 A /free
720 A               else;
720 A                  // since incoming truck begins with !
720 A                  // lets check to make sure we get hit
720 A                  // in Zone file
720 A                  zonelength = %len(%trim($zdtstTruk));
720 A                  sqlStmt1= 'select * from zoned ' +
720 A                            '  where zdwhse = ' + %char($zdwhse) +
720 A                            ' and substring(zdtruk,1,' + %char(zonelength)
720 A                            + ')=' + sq +
720 A                            %subst($zdtstTruk:1:zonelength) + sq;
720 A                  exec sql PREPARE zd1 FROM :SqlStmt1;
720 A                  exec sql DECLARE zdtl1 SCROLL CURSOR FOR zd1;
720 A                  exec sql OPEN zdtl1;
720 A                  exec sql fetch first from zdtl1 into :zdrec;
720 A                  if sqlStt <> sqlSuccess;
720gD  //                 error = *on;
720gD  //                 $preturn = 'STRZNEINV';
720gD  //                 $pMEssage = 'Store Zone sent '
720gD  //                     + 'must exist in Zoned file';
720 A /end-free
720gDc*                  goto      endvfystr
720gAc                   return
720 A /free
720 A                  endif;
720 A                  exec sql close zdtl1;
720 A               endif;
720 A            endif;
720 A
720 A            //  Verify Slot or Item was sent.
720 A            if not $zdstrbpcku and not $zdstrbitmu and not $zdstrcitmu
                     and not $zdstrcpcku;
720bA               error = *on;
720 A               $preturn = 'NOITEMSLT';
 20 A               $pMEssage = 'Either Item or Pick Slot '
720 A                         + 'must be sent to check Store Zone';
720 A /end-free
720 AC                   goto      endvfystr
720 A /free
720 A            endif;
720 A
720 A            //  Verify only Slot or Item sent, not both
720 A            if $zdstrbpcku and $zdstrbitmu or
720 A               $zdstrbpcku and $zdstrcitmu or
720 A               $zdstrbitmu and $zdstrcitmu or
720bA               error = *on;
720 A               $preturn = 'NOTBITMSL';
720 A               $pMEssage = 'Must send only Pick Slot '
720 A                         + 'or item, any two';
720 A /end-free
720 AC                   goto      endvfystr
720 A /free
720 A            endif;
720 A
720 A            //  If Breakdown item sent verify it is a breakdown item
720 A            if $zdstrbitmu;
720 A               exec sql select * into :itrec
720 A                    from piritem
720 A                     where itwhse=:$zdwhse and itwhdp=:$zdwhdp
720 A                       and ititem=:$zdstrbitm and (ittype='B'
720 A                       or ittype='S');
720 A               if sqlstt <> sqlSuccess;
720bA                  error = *on;
720 A                  $preturn = 'NOTBRKITM';
720 A                  $pMEssage = 'Breakdown item sent is '
720 A                            + 'not defined as such';
720 A /end-free
720 AC                   goto      endvfystr
720 A /free
720 A               endif;
720 A            endif;
720 A
720 A            //  If Case Item sent verify it is a Case item
720 A            if $zdstrcitmu;
720 A               exec sql select * into :itrec
720 A                    from piritem
720 A                     where itwhse=:$zdwhse and itwhdp=:$zdwhdp
720 A                       and ititem=:$zdstrcitm and (ittype=' ');
720 A               if sqlstt <> sqlSuccess;
720bA                  error = *on;
720 A                  $preturn = 'NOTCSEITM';
720 A                  $pMEssage = 'Case item sent is '
720 A                            + 'not defined as such';
720 A /end-free
720 AC                   goto      endvfystr
720 A /free
720 A               endif;
720 A            endif;
720 A /end-free
720 A
720 Ac     endvfystr     endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Field Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  vfyLight       Verify Truck Builder Light
     *----------------------------------------------------------------

     C     VfyLight      begsr
      /free

        if not tbLight;
          leavesr;
        endif;

        // Some entries not allowed for Truck Builder Light.

        if $zdrlvl <> 0
         or $zdloc1 <> 0
         or $zdloc2 <> 0
         or $zdhnd1 <> ' '
         or $zdhnd2 <> ' '
         or $zddesg <> ' '
         or $zdcat <> ' '
         or $zdutyp <> ' '
         or $zdside <> ' ';
           error = *on;
           $preturn  = 'FLDNOTALW';
           $pmessage = 'Only Department, Section and Aisle '
                     + 'allowed for Truck Builder Light';
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdaisl      Verify aisle
     *----------------------------------------------------------------

     C     Vfyzdaisl     begsr
      /free

        // Aisle must be entered if Location, Level or Hand entered.

        if $zdaisl = ' ';
          if $zdrlvl <> 0
720dA      or ($zdrlvl2u and $zdrlvl2 <> 0)
           or $zdloc1 <> 0
           or $zdloc2 <> 0
           or $zdhnd1 <> ' '
           or $zdhnd2 <> ' ';
             error = *on;
             $zdaisle = $drierror;
             $preturn  = 'NOAISLE';
             $pmessage = 'Aisle must be entered if '
                       + 'Loc, Level or Hand is entered';
             leavesr;
          endif;
          leavesr;
        endif;

720dM   // From Aisle must exist in department

        evalr $zdaisl = %trim($zdaisl);

        exec sql select slaisl into :zdaisl
                 from slot
                 where slwhse = :$zdwhse
                   and slwhdp = :$zdwhdp
                   and slaisl = :$zdaisl
                 fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
           error = *on;
           $zdaisle = $drierror;
           $preturn  = 'INVLDAISL';
720dM      $pmessage = 'Invalid From aisle (' + $zdaisl + ')';
         endif;

720dA   if not $zdaisl2u;
720dA     leavesr;
720dA   endif;

720dA   // To Aisle must exist in department
720dA
720dA   if $zdaisl2 <> '';
720dA
720dA     evalr $zdaisl2 = %trim($zdaisl2);
720dA
720dA     exec sql select slaisl into :zdaisl2
720dA              from slot
720dA              where slwhse = :$zdwhse
720dA                and slwhdp = :$zdwhdp
720dA                and slaisl = :$zdaisl2
720dA              fetch first 1 rows only;
720dA
720dA     if sqlstt <> sqlSuccess;
720dA       error = *on;
720dA       $zdaisl2e = $drierror;
720dA       $preturn  = 'INVLDAISL2';
720dA       $pmessage = 'Invalid To aisle (' + $zdaisl2 + ')';
720dA     endif;
720dA
720dA   endif;
720dA
720dA   // If To Aisle > ' '
720dA   // Then To Aisle must be greater than or equal to From Aisle
720dA
720dA   if $zdaisl2 > '' and $zdaisl2 < $zdaisl;
720dA     error = *on;
720dA     $zdaisl2e = $drierror;
720dA     $preturn  = 'INVLDAISL3';
720dA     $pmessage = 'To aisle cannot be less than From '
720dA               + 'aisle';
720dA     leavesr;
720dA   endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdcat       Verify category
     *----------------------------------------------------------------

     C     Vfyzdcat      begsr
      /free

        if not $zdcatu or $zdcat = ' ';
          leavesr;
        endif;

        exec sql select iccode into :zdcat
                 from itemcat
                 where iccode = :$zdcat;

        if sqlstt <> sqlSuccess;
           error = *on;
           $zdcate = $drierror;
           $preturn  = 'INVLDCAT';
           $pmessage = 'Invalid Category (' + $zdcat + ')';
         endif;

      /end-free
     C                   endsr

720dA*----------------------------------------------------------------
720dA*  vfyzdclcde     Verify class code
720dA*----------------------------------------------------------------
720dA
720dAC     Vfyzdclcde    begsr
      /free

        if not $zdclcdeu or $zdclcde = ' ';
          leavesr;
        endif;

        exec sql select cacode into :zdclcde
                 from class
                 where cacode = :$zdclcde;

        if sqlstt <> sqlSuccess;
           error = *on;
           $zdclcdee = $drierror;
           $preturn  = 'INVLDCLCDE';
           $pmessage = 'Invalid Class Code (' + $zdclcde + ')';
         endif;

      /end-free
     C                   endsr

720eA*----------------------------------------------------------------
720eA*  vfyzdpckovf    Verify slot type (pick, overflow)
720eA*----------------------------------------------------------------
720eA
720eAC     Vfyzdpckovf   begsr
      /free

        if not $zdpckovfu or $zdpckovf = ' ';
          leavesr;
        endif;

        if $zdpckovf <> 'P' and $zdpckovf <> 'O';
           error = *on;
           $zdpckovfe = $drierror;
           $preturn  = 'INVLDPCKOVF';
           $pmessage = 'Invalid Slot Type (' + $zdpckovf + ')';
         endif;

      /end-free
     C                   endsr

720eA*----------------------------------------------------------------
720eA*  vfyzdcstcod    Verify customer code
720eA*----------------------------------------------------------------
720eA
720eAC     Vfyzdcstcod   begsr
      /free

        if not $zdcstcodu or $zdcstcod = ' ';
          leavesr;
        endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzddesg      Verify designation
     *----------------------------------------------------------------

     C     Vfyzddesg     begsr
      /free

        if not $zddesgu or $zddesg = ' ';
          leavesr;
        endif;

        exec sql select dscode into :zddesg
                 from desig
                 where dscode = :$zddesg;

        if sqlstt <> sqlSuccess;
           error = *on;
           $zddesge = $drierror;
           $preturn  = 'INVLDDESG';
           $pmessage = 'Invalid Designation (' + $zddesg + ')';
         endif;

      /end-free
     C                   endsr

720dA*----------------------------------------------------------------
720dA*  vfyzdactv      Verify activity code
720dA*----------------------------------------------------------------
720dA
720dAC     Vfyzdactv     begsr
      /free

        if not $zdactvu or $zdactv = ' ';
          leavesr;
        endif;

        exec sql select accode into :zdactv
                 from activity
                 where accode = :$zdactv;

        if sqlstt <> sqlSuccess;
           error = *on;
           $zdactve = $drierror;
           $preturn  = 'INVLDACTV';
           $pmessage = 'Invalid Activity Code (' + $zdactv + ')';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdloc       Verify location
     *----------------------------------------------------------------

     C     Vfyzdloc      begsr
      /free

        // Locations can't be negative

        if $zdloc1 < 0;
          error = *on;
          $zdloc1e = $drierror;
          $preturn  = 'INVLDLOC1';
          $pmessage = 'From location cannot be less than zero';
          leavesr;
        endif;

        if $zdloc2 < 0;
          error = *on;
          $zdloc2e = $drierror;
          $preturn  = 'INVLDLOC2';
          $pmessage = 'To location cannot be less than zero';
          leavesr;
        endif;

        // To location must be greater than or equal to From location

        if $zdloc2 < $zdloc1;
          error = *on;
          $zdloc2e = $drierror;
          $preturn  = 'INVLDLOC';
          $pmessage = 'To location cannot be less than From '
                    + 'location';
          leavesr;
        endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdhnd       Verify handstack
     *----------------------------------------------------------------

     C     Vfyzdhnd      begsr
      /free

        if not $zdhnd1u and not $zdhnd2u;
          leavesr;
        endif;

        if $zdhnd1 = ' ' and $zdhnd2 = ' ';
          leavesr;
        endif;

        evalr $zdhnd1 = %trim($zdhnd1);
        evalr $zdhnd2 = %trim($zdhnd2);

        // To location must be greater than or equal to From location

        if $zdhnd2 < $zdhnd1;
          error = *on;
          $zdhnd2e = $drierror;
          $preturn  = 'INVLDHND';
          $pmessage = 'To handstack cannot be less than From '
                    + 'handstack';
          leavesr;
        endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdrlvl      Verify level
     *----------------------------------------------------------------

     C     Vfyzdrlvl     begsr
      /free

        if $zdrlvl < 0;
          error = *on;
          $zdrlvle = $drierror;
          $preturn  = 'INVLDRLVL';
720dM     $pmessage = 'From Level cannot be less than zero';
          leavesr;
        endif;

720dA   if not $zdrlvl2u;
720dA     leavesr;
720dA   endif;

720dA   if $zdrlvl2 < 0;
720dA     error = *on;
720dA     $zdrlvl2e = $drierror;
720dA     $preturn  = 'INVLDRLVL2';
720dA     $pmessage = 'To Level cannot be less than zero';
720dA     leavesr;
720dA   endif;
720dA
720dA   // If To level > 0
720dA   // Then To level must be greater than or equal to From level
720dA
720dA   if $zdrlvl2 > 0 and $zdrlvl2 < $zdrlvl;
720dA     error = *on;
720dA     $zdrlvl2e = $drierror;
720dA     $preturn  = 'INVLDRLVL3';
720dA     $pmessage = 'To level cannot be less than From '
720dA               + 'level';
720dA     leavesr;
720dA   endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdside      Verify side
     *----------------------------------------------------------------

     C     Vfyzdside     begsr
      /free

        if $zdside <> ' '
         and $zdside <> 'O'
         and $zdside <> 'E';
           error = *on;
           $zdsidee = $drierror;
           $preturn  = 'INVLDSIDE';
           $pmessage = 'Invalid Side (' + $zdside + ')';
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdstyp      Verify section
     *----------------------------------------------------------------

     C     Vfyzdstyp     begsr
      /free

        if $zdstyp <> ' '
         and $zdstyp <> 'F'
         and $zdstyp <> 'P';
           error = *on;
           $zdstype = $drierror;
           $preturn  = 'INVLDSTYP';
           $pmessage = 'Invalid section (' + $zdstyp + ')';
           leavesr;
         endif;

        // Section must be entered if Aisle, Level, Location or Hand are entered

        if $zdstyp = ' ';
          if $zdaisl <> ' '
           or $zdrlvl <> 0
           or $zdloc1 <> 0
           or $zdloc2 <> 0
           or $zdhnd1 <> ' '
           or $zdhnd2 <> ' ';
             error = *on;
             $zdstype = $drierror;
             $preturn  = 'NOSTYP';
             $pmessage = 'Section must be entered if Aisle, '
                       + 'Location, Level or Handstack is entered';
             leavesr;
           endif;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdutyp      Verify UOM type
     *----------------------------------------------------------------

     C     Vfyzdutyp     begsr
      /free

        if $zdutyp <> ' '
         and $zdutyp <> 'N'
         and $zdutyp <> '1'
         and $zdutyp <> '2';
           error = *on;
           $zdutype = $drierror;
           $preturn  = 'INVLDUTYP';
           $pmessage = 'Invalid UOM type (' + $zdutyp + ')';
           leavesr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzdwhdp      Verify department
     *----------------------------------------------------------------

     C     Vfyzdwhdp     begsr
      /free

        exec sql select wdcode into :zdwhdp
                 from whdept
                 where wdwhse = :$zdwhse
                   and wdcode = :$zdwhdp;

        if sqlstt <> sqlSuccess;
           error = *on;
           $zdwhdpe = $drierror;
           $preturn  = 'INVLDWHDP';
           $pmessage = 'Invalid department (' + $zdwhdp + ')';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyPRE         Verify PRE is okay
     *----------------------------------------------------------------

     C     VfyPRE        begsr
      /free

        if $zdaisl <> 'PRE';
          leavesr;
        endif;

         // Only one 'S' zone is allowed.

         setll ($zdwhse: $zdtruk) zoneh;

         dow forever = forever;

           reade ($zdwhse: $zdtruk) zoneh;

           if %eof(zoneh);
             leave;
           endif;

           // If zone is 'S', return error.

           chain  ('*PICK': zhwhse: zhtruk: zhzone) optionz;
           if %found(optionz);
             opdta1 = opzdta;
             if opptyp = 'S';
               error = *on;
               $zdaisle = $drierror;
               $preturn  = 'PRENOTALW';
               $pmessage = 'Cannot use aisle PRE because '
                         + 'an S zone is defined';
               leavesr;
             endif;
           endif;

         enddo;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  vfyzoneh       Verify ZONEH record exists
     *----------------------------------------------------------------

     C     Vfyzoneh      begsr
      /free

        exec sql select zhzone into :zdzone
                 from zoneh
                 where zhwhse = :$zdwhse
                   and zhtruk = :$zdtruk
                   and zhzone = :$zdzone;

        if sqlstt <> sqlSuccess;
          error = *on;
          $preturn  = 'ZONHNOTFND';
          $pmessage = 'Zone Header must exist '
                    + '('
                    + %Trim(%editc($zdwhse:'Z'))
                    + '/'
                    + %trim($zdtruk)
                    + '/'
                    + %trim($zdzone)
                    + ') ' + sqlstt;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Sent Verification Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  VfyzdSent  Verify all zd fields sent
     *----------------------------------------------------------------

     C     VfyzdSent     begsr
      /free

         exsr VfyzdwhseSent;
         exsr VfyzdtrukSent;
         exsr VfyzdzoneSent;
         exsr VfyzdwhdpSent;
         exsr VfyzdaislSent;
         exsr VfyzdrlvlSent;
         exsr Vfyzdloc1Sent;
         exsr Vfyzdloc2Sent;
         exsr VfyzddesgSent;
         exsr VfyzdcatSent;
         exsr Vfyzdhnd1Sent;
         exsr Vfyzdhnd2Sent;
         exsr VfyzdutypSent;
         exsr VfyzdsideSent;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzoSent  Verify all zo fields sent
     *----------------------------------------------------------------

     C     VfyzoSent     begsr
      /free

         exsr VfyzowhdpSent;
         exsr VfyzoaislSent;
         exsr VfyzorlvlSent;
         exsr Vfyzoloc1Sent;
         exsr Vfyzoloc2Sent;
         exsr VfyzodesgSent;
         exsr VfyzocatSent;
         exsr Vfyzohnd1Sent;
         exsr Vfyzohnd2Sent;
         exsr VfyzoutypSent;
         exsr VfyzosideSent;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdtrukSent  Verify truck was sent
     *----------------------------------------------------------------

     C     VfyzdtrukSent begsr
      /free

         if not $zdtruku;
           error = *on;
           $zdtruke = $drierror;
           $preturn  = 'TRUKNOTSNT';
           $pmessage = 'Truck code must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdwhseSent  Verify warehouse was sent
     *----------------------------------------------------------------

     C     VfyzdwhseSent begsr
      /free

         if not $zdwhseu;
           error = *on;
           $zdwhsee = $drierror;
           $preturn  = 'WHSNOTSNT';
           $pmessage = 'Warehouse must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdzoneSent  Verify zone was sent
     *----------------------------------------------------------------

     C     VfyzdzoneSent begsr
      /free

         if not $zdzoneu;
           error = *on;
           $zdzonee = $drierror;
           $preturn  = 'ZONENOTSNT';
           $pmessage = 'Zone must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdwhdpSent  Verify department was sent
     *----------------------------------------------------------------

     C     VfyzdwhdpSent begsr
      /free

         if not $zdwhdpu;
           error = *on;
           $zdwhdpe = $drierror;
           $preturn  = 'DPTNOTSNT';
           $pmessage = 'Department must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdaislSent  Verify aisle was sent
     *----------------------------------------------------------------

     C     VfyzdaislSent begsr
      /free

         if not $zdaislu;
           error = *on;
           $zdaisle = $drierror;
           $preturn  = 'ASLNOTSNT';
           $pmessage = 'Aisle must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdrlvlSent  Verify level was sent
     *----------------------------------------------------------------

     C     VfyzdrlvlSent begsr
      /free

         if not $zdrlvlu;
           error = *on;
           $zdrlvle = $drierror;
           $preturn  = 'LVLNOTSNT';
           $pmessage = 'Level must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzdloc1Sent  Verify from location was sent
     *----------------------------------------------------------------

     C     Vfyzdloc1Sent begsr
      /free

         if not $zdloc1u;
           error = *on;
           $zdloc1e = $drierror;
           $preturn  = 'LOC1NOTSNT';
           $pmessage = 'From location must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzdloc2Sent  Verify to location was sent
     *----------------------------------------------------------------

     C     Vfyzdloc2Sent begsr
      /free

         if not $zdloc2u;
           error = *on;
           $zdloc2e = $drierror;
           $preturn  = 'LOC2NOTSNT';
           $pmessage = 'To location must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzddesgSent  Verify designation was sent
     *----------------------------------------------------------------

     C     VfyzddesgSent begsr
      /free

         if not $zddesgu;
           error = *on;
           $zddesge = $drierror;
           $preturn  = 'DSGNOTSNT';
           $pmessage = 'Designation must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdcatSent  Verify category was sent
     *----------------------------------------------------------------

     C     VfyzdcatSent  begsr
      /free

         if not $zdcatu;
           error = *on;
           $zdcate = $drierror;
           $preturn  = 'CATNOTSNT';
           $pmessage = 'Category must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzdhdn1Sent  Verify from handstack was sent
     *----------------------------------------------------------------

     C     Vfyzdhnd1Sent begsr
      /free

         if not $zdhnd1u;
           error = *on;
           $zdhnd1e = $drierror;
           $preturn  = 'HND1NOTSNT';
           $pmessage = 'From handstack must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzdhdn2Sent  Verify to handstack was sent
     *----------------------------------------------------------------

     C     Vfyzdhnd2Sent begsr
      /free

         if not $zdhnd2u;
           error = *on;
           $zdhnd2e = $drierror;
           $preturn  = 'HND2NOTSNT';
           $pmessage = 'To handstack must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdutypSent  Verify UOM type was sent
     *----------------------------------------------------------------

     C     VfyzdutypSent begsr
      /free

         if not $zdutypu;
           error = *on;
           $zdutype = $drierror;
           $preturn  = 'UTYPNOTSNT';
           $pmessage = 'UOM type must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzdsideSent  Verify side was sent
     *----------------------------------------------------------------

     C     VfyzdsideSent begsr
      /free

         if not $zdsideu;
           error = *on;
           $zdsidee = $drierror;
           $preturn  = 'SIDENOTSNT';
           $pmessage = 'Side must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzowhdpSent  Verify original department was sent
     *----------------------------------------------------------------

     C     VfyzowhdpSent begsr
      /free

         if not $zowhdpu;
           error = *on;
           $zowhdpe = $drierror;
           $preturn  = 'ODPTNOTSNT';
           $pmessage = 'Original Department must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzoaislSent  Verify original aisle was sent
     *----------------------------------------------------------------

     C     VfyzoaislSent begsr
      /free

         if not $zoaislu;
           error = *on;
           $zoaisle = $drierror;
           $preturn  = 'OASLNOTSNT';
           $pmessage = 'Original Aisle must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzorlvlSent  Verify Original level was sent
     *----------------------------------------------------------------

     C     VfyzorlvlSent begsr
      /free

         if not $zorlvlu;
           error = *on;
           $zorlvle = $drierror;
           $preturn  = 'OLVLNOTSNT';
           $pmessage = 'Original Level must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzoloc1Sent  Verify original from location was sent
     *----------------------------------------------------------------

     C     Vfyzoloc1Sent begsr
      /free

         if not $zoloc1u;
           error = *on;
           $zoloc1e = $drierror;
           $preturn  = 'OLOC1NOTSN';
           $pmessage = 'Original From location must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzoloc2Sent  Verify original to location was sent
     *----------------------------------------------------------------

     C     Vfyzoloc2Sent begsr
      /free

         if not $zoloc2u;
           error = *on;
           $zoloc2e = $drierror;
           $preturn  = 'OLOC2NOTSN';
           $pmessage = 'Original To location must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzodesgSent  Verify original designation was sent
     *----------------------------------------------------------------

     C     VfyzodesgSent begsr
      /free

         if not $zodesgu;
           error = *on;
           $zodesge = $drierror;
           $preturn  = 'ODSGNOTSNT';
           $pmessage = 'Original Designation must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzocatSent  Verify original category was sent
     *----------------------------------------------------------------

     C     VfyzocatSent  begsr
      /free

         if not $zocatu;
           error = *on;
           $zocate = $drierror;
           $preturn  = 'OCATNOTSNT';
           $pmessage = 'Original Category must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzohdn1Sent  Verify original from handstack was sent
     *----------------------------------------------------------------

     C     Vfyzohnd1Sent begsr
      /free

         if not $zohnd1u;
           error = *on;
           $zohnd1e = $drierror;
           $preturn  = 'OHND1NOTSN';
           $pmessage = 'Original From handstack must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  Vfyzohdn2Sent  Verify original to handstack was sent
     *----------------------------------------------------------------

     C     Vfyzohnd2Sent begsr
      /free

         if not $zohnd2u;
           error = *on;
           $zohnd2e = $drierror;
           $preturn  = 'OHND2NOTSN';
           $pmessage = 'Original To handstack must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzoutypSent  Verify original UOM type was sent
     *----------------------------------------------------------------

     C     VfyzoutypSent begsr
      /free

         if not $zoutypu;
           error = *on;
           $zoutype = $drierror;
           $preturn  = 'OUTYPNOTSN';
           $pmessage = 'Original UOM type must be sent';
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  VfyzosideSent  Verify original side was sent
     *----------------------------------------------------------------

     C     VfyzosideSent begsr
      /free

         if not $zosideu;
           error = *on;
           $zosidee = $drierror;
           $preturn  = 'OSIDENOTSN';
           $pmessage = 'Original Side must be sent';
         endif;

      /end-free
     C                   endsr
