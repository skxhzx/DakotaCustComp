     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT116     Item Maintenance - Repack Components
     *            This program is called from IT112 for Repack Items
     *            only.  The sole purpose is to maintain a component
     *            list of items that are required to create a repack
     *            item.  This list is maintained in a User Space
     *            created and stored in QTEMP/ARYRPD IT112 will create
     *            before the call and remove before exiting.
     *  07 February 2013
     *  Kenneth Elder
     *  Created using CW112
     *
     *  Revisions
     *
     *    02/20/13  KE   6.50
650  *      - Created
     *
650a *    04/23/13  KDE  6.50a
     *      Changed to not allow a Repack item to be entered as a parent on
     *      a On-Demand repack item.  Work Order repacks have been changed
     *      to accept this and have been fully tested.  Also prevent user
     *      from including the same repack item on the same item being
     *      being modified
     *
650b *    09/10/13  KDE  6.50b
     *      Changed to allow parent slot to have Repack Item instead of
     *      parent.  This allows a customer to use a repack item as the
     *      ordered and stocked item such as Green Leaf does when certain
     *      items can only be ordered certain times of rhte year.
     *
650c *    02/19/14  KDE  6.50b
     *      Was not trapping error during addition of new repack item
     *      when user did not enter at least one uom
700a *    02/11/16  RH   7.00a
     *      Added code found at Food Pro during 6.50 update.
     *
720 A*    09/20/18  KDE  7.20
     *      Easy access to creating Virtual Slot for item
     *
     *----------------------------------------------------------------
     * Merit Foods Custom Revisions:
     *
MRTaA*    07/31/18  MRTaA
     *      - ENH: Return Virtual slot if one exist when
     *             doing ODR Repack maintenance at Merit Foods.
     *             Merit uses virtals for there ODR repack slots
MRTbA*    10/02/18  MRTbA
     *      - Fix: Minor fix to MRTa mod
     *
     *----------------------------------------------------------------
     * Greco Custom Revisions:
     *
GRCaA*    10/02/18  GRCaA
     *      - ENH: Apply Merit changes above
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  70        Protect top entry of Control Screen
     *  71        Protect Slot in subfile
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  92        Protect Breakdown 2 if not entered SCR2 IT112
     *  93        Protect On-Demand Slot if Work Order Repack Type
     *  96        Protect Breakdown 1 if not entered SCR2 IT112
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
720 Df**IT116FM   cf   e             workstn
720 AfIT11601   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     fpiritem   if   e           k disk
     Fwarehs    if   e           k disk
     Foptions   if   e           k disk
     Fkititem   if   e           k disk
     Fslot2     if   e           k disk
     Fslot3     if   e           k disk    prefix(s3_)
     f                                     rename(slrec:slrec3)
MRTaAFvslot1    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D err             s             50    dim(15) ctdata perrcd(1)
     *
     *   definitions to work with user space setup
     *     in IT112 prior to call
     *
     *   API to retrieve a pointer to the user space
     D RtvPtrToUsrSpc  pr                  extpgm('QUSPTRUS')
     D   Name                        20a   const
     D   Ptr                           *
     D   Qusec                             LikeDS(Qusec)

     *   API return information for API QUSPTRUS
     dQusec            ds
     d qusbprv                 1      4b 0
     d qusbavl                 5      8b 0
     d qusei                   9     15
     d quserved               16     16

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item

     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#EI
      /COPY QCOPYSRC,ID#TPC
      /copy qcopysrc,id#renzi
      /copy qcopysrc,id#saval
      /copy qcopysrc,id#cashwa
      /copy qcopysrc,id#dairyla
      /copy qcopysrc,id#packers
      /copy qcopysrc,id#nichola
      /copy qcopysrc,id#glazier
MRTaA /copy qcopysrc,id#MRT
GRCaA /copy qcopysrc,id#grc
     *
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $ptrn#                22     28  0
     D  $pitem                29     43
     D  $pseq#                44     48  0
     d  $plbl#                49     55  0
     d  $pcw#                 56     58  0
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $lrack                22     26
     D  $litem                22     36
     D  $litem2               27     41
     D  $ldisp                42     53
     *
     D  $lbld                 19     20
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     d  opwrnc                 5      5
     d  oprg1c                 6      8  1
     d  oprg2c                 9     11  1
     d  opimpi                12     12
     d  opicw                 13     13
     d  opuci                 36     36
     D  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     *----------------------------------------------------------------
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status               369    369
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  used to determine decimal remaining in math eval
     *----------------------------------------------------------------
     D                 ds
     D  wopqndec               1      5  2
     D  dec                    4      5  0
     *----------------------------------------------------------------
     * Work Variable
     *----------------------------------------------------------------
     *
     *  Data Structure (array) to save previous pass subfile records
     *
     D                 ds
     D aryhldSFL                     48    dim(6)
     D  hlsitm2                      15a   overlay(aryhldSFL:*next)
     D  hlsdisp                      12a   overlay(aryhldSFL:*next)
     D  hlsqty1                       3p 0 overlay(aryhldSFL:*next)
     D  hlsum1                        2a   overlay(aryhldSFL:*next)
     D  hlsqty2                       3p 0 overlay(aryhldSFL:*next)
     D  hlsum2                        2a   overlay(aryhldSFL:*next)
     D  hlsitpe                       1a   overlay(aryhldSFL:*next)
     D  hlsqty3                       3p 0 overlay(aryhldSFL:*next)
     D  hlsum3                        2a   overlay(aryhldSFL:*next)
     D  hlaryrec                      5  0 overlay(aryhldSFL:*next)
     *
     *  Data Structure for Repack data elements
     *  Pointer to the auto-extending user space Repack array
     *     found in QTEMP/aryrpd
     D ptrRPD          s               *
     *  Dynamically allocated array stored in the user space
     D RepackData      ds                  based(ptrRPD)
     D aryRPD                              dim(700)
     d  aeitem                       15a   overlay(aryRPD:*next)
     D  aedelcd                       1a   overlay(aryRPD:*next)
     D  aesitm2                      15a   overlay(aryRPD:*next)
     D  aesdisp                      12a   overlay(aryRPD:*next)
     D  aesqty1                       3p 0 overlay(aryRPD:*next)
     D  aesum1                        2a   overlay(aryRPD:*next)
     D  aesqty2                       3p 0 overlay(aryRPD:*next)
     D  aesum2                        2a   overlay(aryRPD:*next)
     D  aesqty3                       3p 0 overlay(aryRPD:*next)
     D  aesum3                        2a   overlay(aryRPD:*next)
     D  aerptp                        1a   overlay(aryRPD:*next)
     D  aedisp                       12a   overlay(aryRPD:*next)
     D  aerqty1                       3p 0 overlay(aryRPD:*next)
     D  aerum1                        2a   overlay(aryRPD:*next)
     D  aerqty2                       3p 0 overlay(aryRPD:*next)
     D  aerum2                        2a   overlay(aryRPD:*next)
     d  aesitpe                       1a   overlay(aryRPD:*next)
     D  aerqty3                       3p 0 overlay(aryRPD:*next)
     D  aerum3                        2a   overlay(aryRPD:*next)
     D  aearyrec                      5  0 overlay(aryRPD:*next)
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D clear           c                   const(X'BD')
     D help            c                   const(X'F3')
MRTaAd hldrsrv         s                   like(slrsrv)
     D enter           c                   const(X'F1')
     D rolldn          C                   const(X'F4')
     D rollup          C                   const(X'F5')
     D f20             C                   const(X'B8')
     D f12             C                   const(X'3C')
     D error           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D W1cqty1         s              3  0
     D W1cqty2         s              3  0
     D W1cqty3         s              3  0
     D addItm          s              4  0
     D filPtr          s              4  0
     d sflerr          s              1    inz('0')
     d reccnt          s              4  0
     D w2rum1          s                   like($itum2)
     D w2rum2          s                   like($itum2)
     D w2rum3          s                   like($itum2)
     d chksize         s              8  0
     d savfrst         s              5  0
     d savlast         s              5  0
     d savdisp         s             12
     d savoutq         s              5  0
     d savitem         s             15
     d savrptp         s              1
     d updateAlready   s              1
     D recno           s              4  0
     D redspl          s              1
     D sclear          s              1
     d warn            s              1
     d howManyGood     s              4  0
     d pagcmd          s              8
     D refrsh          s              1
     D FirstAction     s               n
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D @Caller         S             10
     D @Counter        S             15  5
     D opicwflag       s              1
     D opwrncflag      s              1
     D zmsflag         s               n
     D IT112RpItm      s                   like($ititem)
     D IT112RpWdp      s                   like($itwhdp)
     D wkdisp          s                   like($ifodrslot)
     d baseODRSlot     s                   like($sldisp)
     D Errorcde        s          32767A
     D nxtItm          s              4  0
     D clrItm          s              4  0
     D bldItm          s              4  0
     D fndItm          s              4  0
     D chk4err         s               n
     D drierr          s               n
     D wrkitm          s                   like($ititem)
     D wrkqty1         s                   like($itumq2)
     D wrkqty2         s                   like($itumq2)
     D wrkqty3         s                   like($itumq2)
     D saveVer#        s                   like($slver#)
     D #svitver#       s                   like($itver#)
     D #svitwhse       s                   like($itwhse)
     D #svititem       s                   like($ititem)
     D #svitmitem      s                   like($itmitem)
     D #svitcitem      s                   like($itcitem)
     D #svittype       s                   like($ittype)
     D #svitdesc       s                   like($itdesc)
     D #svitstyp       s                   like($itstyp)
     D #svitwhdp       s                   like($itwhdp)
     D #svitdesg       s                   like($itdesg)
     D #svitactv       s                   like($itactv)
     D #svitupc        s                   like($itupc)
     D #svitbld        s                   like($itbld)
     D #svitven#       s                   like($itven#)
     D #svitvit#       s                   like($itvit#)
     D #svitpdsc       s                   like($itpdsc)
     D #svitum1        s                   like($itum1)
     D #svitflg1       s                   like($itflg1)
     D #svitum2        s                   like($itum2)
     D #svitumq2       s                   like($itumq2)
     D #svitflg2       s                   like($itflg2)
     D #svitum3        s                   like($itum3)
     D #svitumq3       s                   like($itumq3)
     D #svitulen       s                   like($itulen)
     D #svituwdt       s                   like($ituwdt)
     D #svituhgt       s                   like($ituhgt)
     D #svitcube       s                   like($itcube)
     D #svitswgt       s                   like($itswgt)
     D #svitcwgt       s                   like($itcwgt)
     D #svitreor       s                   like($itreor)
     D #svitrepl       s                   like($itrepl)
     D #svitrcvd       s                   like($itrcvd)
     D #svitflgd       s                   like($itflgd)
     D #svitflgb       s                   like($itflgb)
     D #svitslif       s                   like($itslif)
     D #svitnday       s                   like($itnday)
     D #svitsdef       s              2    dim(5)
     D #svittie        s              4s 0 dim(5)
     D #svithigh       s              2s 0 dim(5)
     D #svitum         s              1    dim(5)
     D #svitpref       s              1    dim(5)
     D #svixdsc1       s                   like($ixdsc1)
     D #svixdsc2       s                   like($ixdsc2)
     D #svimtie        s                   like($imtie)
     D #svimhigh       s                   like($imhigh)
     D #svimmflg       s                   like($immflg)
     D #svimdday       s                   like($imdday)
     D #svimuday       s                   like($imuday)
     D #svimmday       s                   like($immday)
     D #svimwrnc       s                   like($imwrnc)
     D #svimrg1c       s                   like($imrg1c)
     D #svimrg2c       s                   like($imrg2c)
     D #svimapck       s                   like($imapck)
     D #svimnrpk       s                   like($imnrpk)
     D #svimnslt       s                   like($imnslt)
     D #svimxdck       s                   like($imxdck)
     D #svimbnbr       s                   like($imbnbr)
     D #svimbnam       s                   like($imbnam)
     D #svimvnam       s                   like($imvnam)
     D #svimbrnd       s                   like($imbrnd)
     D #svimlot        s                   like($imlot)
     D #svimltrk       s                   like($imltrk)
     D #svimoday       s                   like($imoday)
     D #svifcat        s                   like($ifcat)
     D #svifodrslot    s                   like($ifodrslot)
     D #svifcaseovf    s                   like($ifcaseovf)
     D #svifucicde     s                   like($ifucicde)
     D #svifrcvmth     s                   like($ifrcvmth)
     D #svifsltmth     s                   like($ifsltmth)
     D #svifbrdflg     s                   like($ifbrdflg)
     D #svkcdisp       s                   like($kcdisp)
     D #svkcqty1       s                   like($kcqty1)
     D #svkcqty2       s                   like($kcqty2)
     D #svkcqty3       s                   like($kcqty3)
     D #svkidisp       s                   like($kidisp)
     D #svkirptp       s                   like($kirptp)
     D #svkiqty1       s                   like($kiqty1)
     D #svkiqty2       s                   like($kiqty2)
     D #svkiqty3       s                   like($kiqty3)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *              *WORKTIE - Work with tie/highs
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.

     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *Entry        plist
     C                   parm                    $parms
     *
     *  Pass Repack Normal and Breakdown UOM from Screen 2
     *  along with item# and description for repack items
     c                   parm                    w2rum1
     c                   parm                    w2rum2
     c                   parm                    w2rum3
     c                   parm                    IT112RpItm
     c                   parm                    wodesc
     c                   parm                    IT112RpWdp
     *
     *  return calling program
     *
     C     UI866P        Plist
     C                   Parm                    @Caller
     C                   Parm                    @Counter
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = ' '
     C                   eval      $perm = ' '
     c                   eval      firstAction = *on
     C                   exsr      zzinz1
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     c                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
      *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *  if Repack Item Repack Slot changes then change throughout array
     *
     c                   if        savDisp <> w1disp
     c                              or savoutq <> w1RQty1
     c                   eval      fnditm = 1
     c                   dow       fnditm <= %elem(aryRPD)
     c                   if        aeDelcd(fnditm) = 'G' or aeDelcd(fndItm)='D'
     c                   eval      aeDisp(fndItm) = w1disp
     c                   eval      aeRQty1(fndItm) = w1RQty1
     c                   eval      aeRQty1(fndItm) = w1RQty1
     c                   eval      aeRptp(fndItm) = w1Rptp
     c                   eval      savDisp = w1disp
     c                   eval      savOutq = w1RQty1
     c                   eval      savrptp = w1rptp
     c                   else
     c                   eval      savDisp = w1disp
     c                   eval      savOutq = w1RQty1
     c                   eval      savrptp = w1rptp
     c                   leave
     c                   endif
     c                   eval      fnditm = fnditm + 1
     c                   enddo
     c                   endif
     *
     *  save several key screen variables
     *
     c                   eval      savDisp = W1Disp
     c                   eval      savOutq = W1RQty1
     c                   eval      savrptp = w1rptp
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   select
     *
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      head1                                  50
     *
     C                   when      nxtscr = '02 '
     C                   exfmt     typmsg
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       192072
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       394046
     C                   setoff                                       989394
     C                   setoff                                       959441
     C                   setoff                                       40
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01  Screen 1 page routines
     *
      /free
        begsr pag01;
           select;
             when pagcmd = '*NEXT';
                exsr pag1fw;

             when pagcmd = '*PREV';
                exsr pag1bk;
           endsl;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  pag1bk  Let's see the previous page
     *
      /free
        begsr pag1bk;

          //  determine array pointer, clear sfl and call zzfil1

          // since the user is requesting to page back start with the
          // array element from subfile record 1 and go back 6 (full
          // page) elements and then fill subfile from that point
          bldItm = hlaryrec(1) - 1;
          reccnt = 0;  // this will be cleared and reset before leave
          dow bldItm >0 and reccnt<6;
             if aedelcd(bldItm) = 'G';
                reccnt = reccnt+1;
             endif;
             bldItm -=1;
          enddo;
          // if counter went below zero start the page back with array
          // element 1
          blditm +=1;
          if bldItm<1;
             filPtr = 1;
          else;
             // else start with element from the loop above
             filPtr = bldItm;
          endif;
          // clear the subfile and reload with requested records
          exsr sflclr;
          exsr zzfil1;
          redspl = *on;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  pag1fw  Let's see that next page of records
     *
      /free
       begsr pag1fw;
         // user has requested to page forward.  If reccnt is less than
         // 6 there is no where to forward.  Just set redisplay *on and
         // redisplay current screen.
         if reccnt<6;  //at end of subfile
            redspl = *on;
         else;
            // else, find the array pointer from record 6 of the subfile
            // and add 1 to that pointer to loop through array and build
            // subfile with next 1-6 available records
            bldItm = hlaryrec(6) + 1;
            reccnt = 0;  // this will be cleared and reset before leave
            dow bldItm <=%Elem(aryRPD) and reccnt<1;
               // once you locate the 1st good record leave loop
               // this will become the array pointer for the next page
               if aedelcd(bldItm) = 'G';
                  reccnt = reccnt+1;
               endif;
               bldItm +=1; //look for next good record
            enddo;
            if reccnt = 1;
               filptr = bldItm-1; //set array pointer to start next screen
               exsr sflclr;
               exsr zzfil1;
               redspl = *on;
            else;
               filPtr = hlaryrec(1);
               redspl = *on;
            endif;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ROLL01  Screen 1 roll up/down routine
     *
      /free
        begsr roll01;
           select;
             when status = rollup;
                pagcmd = '*NEXT';

             when status = rolldn;
                pagcmd = '*PREV';

             other;
                pagcmd = '*NONE';
           endsl;
           exsr pag01;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     c                   eval      *in70 = *on
     c                   eval      *in72 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     *  call zzfil1 to load array data passed back and forth between
     *    IT112 and IT116
     c                   exsr      zzdft1
     C                   exsr      zzfil1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     c                   exsr      sflclr
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     c                   eval      redspl = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  if Repack Item Repack Slot changes then change throughout array
     *
     c                   if        savDisp <> w1disp
     c                              or savoutq <> w1RQty1
     c                   eval      fnditm = 1
     c                   dow       fnditm <= %elem(aryRPD)
     c                   if        aeDelcd(fnditm) = 'G' or aeDelcd(fndItm)='D'
     c                   eval      aeDisp(fndItm) = w1disp
     c                   eval      aeRQty1(fndItm) = w1RQty1
     c                   eval      aeRptp(fndItm) = w1Rptp
     c                   eval      savDisp = w1disp
     c                   eval      savOutq = w1RQty1
     c                   eval      savrptp = w1rptp
     c                   else
     c                   eval      savDisp = w1disp
     c                   eval      savOutq = w1RQty1
     c                   eval      savrptp = w1rptp
     c                   leave
     c                   endif
     c                   eval      fnditm = fnditm + 1
     c                   enddo
     c                   endif
     *
     *  Test roll keys BEFORE verification and update.
     *
     c     status        caseq     rollup        roll01
     c     status        caseq     rolldn        roll01
     c                   endcs
     c     redspl        cabeq     *on           endsc1
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Check for any subfile errors after CMD20 changes type
     *
     *
     *  Some other key pressed.
     *
     *  if user changes repack type then change array data and display
     *   with any errors
     *
     c                   if        w1rptp<>savrptp and savrptp<>' '
     c                              and w1rptp<>'2'
     c                   eval      nxtScr = '02'
     c                   eval      savrptp = w1rptp
     c                   goto      endsc1
     c                   endif
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     c                   exsr      sflerrs
     C     error         cabeq     *on           endsc1
      *  if no errors and redisplay is on check for an add first
      *   if an add is requested let the zzupd1 process to add
      *   otherwise redisplay
     c                   if        w1citm2=' '
     C     redspl        cabeq     *on           endsc1
     c                   endif
     C                   exsr      zzupd1
     C     redspl        cabeq     *on           endsc1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2 - Warning for changing Repack Type
     *
     C     sc2           begsr
     *
     *  Test for CMD Keys
     *
     c                   select
     c                   when      status = f20
     c                   exsr      toggleType
      *
     c                   when      status = f12
     c                   eval      nxtscr = '01 '
     c                   if        w1rptp = '1'
     c                   eval      w1rptp='2'
     c                   else
     c                   eval      w1rptp='1'
     c                   endif
     *
     c                   endsl
     *
     *  If no command keys pressed just redisplay window with message
     *
     c                   eval      redspl = *on
     *
     C     endsc2        endsr
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
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *  Initialize subfile values
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz

      * Determine Calling program

     C                   Eval      @Counter = 4
     C                   Eval      @Caller  = ' '

     C                   Call      'UI866'       UI866P

     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     c                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   eval      *in85 = *on

     c                   if        w1sum2 = ' '
     c                   eval      w1sqty2 = 0
     c                   endif

     c                   if        w1sum3 = ' '
     c                   eval      w1sqty3 = 0
     c                   endif

     *
     *  save array pointers to subfile
     *
     c                   if        reccnt = 1
     c                   eval      savfrst = filPtr
     c                   else
     c                   eval      savlast = filPtr
     c                   endif
     *
     *  Set erros for subfile if found during the write               ls
     *
     c                   select
     c                   when      w1rptp = '2' and
     c                               w1sdisp=' '
     c                   eval      *in41 = *on
     c                   eval      sflerr = '1'
     C                   eval      errmsg = err(8)
     c                   eval      error = *on
     c                   other
      /free
              errmsg = ' ';
              if w1sItm2<>' ' and *in41 = *off;
                 wrkitm = w1sItm2;
                 wrkqty1 = w1sQty1;
                 wrkqty2 = w1sQty2;
                 wrkqty3 = w1sQty3;
       // if it is decided to enforce a zero decimal relationship between
       // output qty and parent qty you can un-remark zzverqty
       //        exsr zzverqty;
                 if error = *on;
                    errmsg = err(13);
                    *in40 = *on;
                    *in41 = *on;
                 else;
                    *in40 = *off;
                    *in41 = *off;
                 endif;
              endif;
      /end-free
     c                   endsl
     c                   if        error = *on
     c                   exsr      zm0105
     c                   endif
     *
     *  Save subfile records in array for reference for delete and rolls
     *
      /free
                        hlsitm2(reccnt) = w1sitm2;
                        hlsdisp(reccnt) = w1sdisp;
                        hlsqty1(reccnt) = w1sqty1;
                        hlsum1(reccnt) = w1sum1;
                        hlsqty2(reccnt) = w1sqty2;
                        hlsum2(reccnt) = w1sum2;
                        hlsqty3(reccnt) = w1sqty3;
                        hlsum3(reccnt) = w1sum3;
                        hlsitpe(reccnt) = w1sitpe;
                        hlaryrec(reccnt) = w1aryrec;

      /end-free
     C                   write     detail1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  sflchg - read subfile looking for changes and responding
     *           appropriately
     *
     c     sflchg        begsr
      /free
        if recno>0;
           readc detail1;
           dow not %eof;

              // if item change has removed a quantity remove from array
              if w1sum2 = ' ';
                 aesqty2(w1aryrec) = 0;
              endif;

              if w1sum3 = ' ';
                 aesqty3(w1aryrec) = 0;
              endif;

             // mark array record as deleted
              if w1sitm2 = ' ';
                 aeDelcd(w1aryrec) = 'D';
                 aesQty1(w1aryrec) = 0;
                 aesQty2(w1aryrec) = 0;
                 aesQty3(w1aryrec) = 0;
                 redspl =*on; //redisplay to show without item        n sf
              endif;

             //check for item change.  This is not allowed
              if w1sitm2 <> aesitm2(w1aryrec) and w1sitm2<>' ';
                 *in40 = *on;  //highlight as error
                 errmsg = err(10);
                 error = *on;
                 update detail1;
              else;
                 *in40 = *off;
              endif;

             //check for no quantity entered on subfile line
             if aesitm2(w1aryrec)<>' ' and aesQty1(w1aryrec)=0
               and aesQty2(w1aryrec)=0 and aesQty3(w1aryrec)=0
650cA          and w1cQty1=0 and w1cQty2=0 and w1cQty3=0
               and redspl <> *on and error <> *on;
                 *in40 = *on;  //highlight as error
                 errmsg = err(3);
                 error = *on;
                 update detail1;
             else;
                 *in40 = *off;
             endif;

             if aeRptp(w1aryrec) <> w1rptp;
                aeRptp(w1aryrec) = w1rptp;
                update detail1;
             endif;

              readc detail1;
           enddo;
           // if delete occured then rebuild subfile for display
           // otherwise errors are resolved above
           if redspl = *on;
              exsr sflclr;
              exsr zzfil1;
           endif;
        endif;
      /end-free
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     c*                  eval      sflerr = '0'
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     *    Clear subfile hold array
     *
      /free
          clrItm = 1;
          dow clrItm<7;
             hlsitm2(clrItm) = ' ';
             hlsdisp(clrItm) = ' ';
             hlsqty1(clrItm) = 0;
             hlsum1(clrItm) = ' ';
             hlsqty2(clrItm) = 0;
             hlsum2(clrItm) = ' ';
             hlsqty3(clrItm) = 0;
             hlsum3(clrItm) = ' ';
             clrItm +=1;
          enddo;
      /end-free
     C                   exsr      zsclr
     c                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
      /free
          write cmdrec;
          moreln = ' ';
          fndItm=0;
         // make sure record number good for subfile
          if recno>0 and recno<7;
            // make sure subfile record(s) exist
             if hlsitm2(recno)=' ';
                moreln = '      ';
             else;
               // get array element for last entry in subfile
                fndItm = hlaryrec(recno) + 1;
                dow fndItm<=%Elem(aryRPD) and (aeDelcd(fndItm)='D'
                      or aeDelcd(fndItm)='G');
               // look for any good record after last subfile record
                   if aeDelcd(fndItm) = 'G';
                      // if records exist
                      moreln = 'More..';
                      leave;
                   endif;
                   fndItm = fndItm+1;
                enddo;
                if moreln <> 'More..';
                 // we must be at the bottom of the active array
                 // determine whether to show blank or bottom based on
                 // whether one screen or more have displayed
                   if hlaryrec(recno)<7  //array element of last sf rec
                       or hlaryrec(1)<7;
                      moreln = 'Bottom';
                      filptr = 1;
                   else;
                      moreln = 'Bottom';
                   endif;
                endif;
             endif;
          else;
            // if subfile is empty show nothing on status roll
             moreln = ' ';
          endif;
          write morrec;
         // write subfile to display
          if recno > 0;
             *in81 = *on;
          endif;
         // once a good record is written to subfile protect control
         // portion of screen from changing so all array elements
         // will be consistent
          if *in11<>*on and *in16<>*on and *in18<>*on
               and recno>0;
       //    *in70 = *on;
             *in71 = *off;
             if not FirstAction;
                *in15 = *on;
             endif;
          endif;
          write head1;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  sflerrs - Ensure no subfile errors exist for all array data
     *
     c     sflerrs       begsr
      /free
        sflerr = '0';
        filPtr =savfrst;
        nxtItm = 1;
        dow nxtItm<=%Elem(aryRPD) and (aeDelcd(nxtItm)='D'
                    or aeDelcd(nxtItm)='G');

           aeRqty1(nxtItm) = w1Rqty1;
           if error = *off;
              errmsg = ' ';
              if aesItm2(nxtItm)<>' ';
                 wrkitm = aesItm2(nxtItm);
                 wrkqty1 = aesQty1(nxtItm);
                 wrkqty2 = aesQty2(nxtItm);
                 wrkqty3 = aesQty3(nxtItm);
       // if it is decided to enforce a zero decimal relationship between
       // output qty and parent qty you can un-remark zzverqty
       //        exsr zzverqty;
                 if error = *on;
                    errmsg = err(13);
                    error = *off;
                    sflerr = '1';
                    leave;
                 endif;
              endif;
           endif;

           select;

           // if any error records remain after subfile set error and sflptr
           when aeDelcd(nxtItm)='G' and (aerptp(nxtItm)='2'
                  or w1rptp='2') and aesdisp(nxtItm) = ' '
                  and sflerr <> '1';
           filptr = nxtItm;
           sflerr = '1';
           errmsg = err(9);
           leave;

           endsl;

           nxtItm +=1;
        enddo;

        if error = *off and sflerr='1';
           // only rebuild subfile if errors were found
           exsr sflclr;
           exsr zzfil1;
           error = *on;
           exsr zm0105;
        endif;

      /end-free
     c                   endsr
     *----------------------------------------------------------------
     *  sflFree  If the max of 6 records have been added to the subfile
     *  move elements 2-6 up to 1-5 so record 6 is available for the
     *  latest component record
     *
      /free
        begsr sflFree;

           // need to free up line for addition
           if recno = 6;
              // get to element of 2nd subfile record
              // from previous subfile pass array.  Field aryrec on subfile
              // record contains the main array element that this record
              // belongs.  Therefore we will loop starting with that array
              // element and go for 5 records.  This will free up record 6
              // for the addition
              bldItm = hlaryrec(2);
              exsr sflclr;
              dow bldItm <=%Elem(aryRPD) and recno<5;
                 if aedelcd(bldItm) = 'G';
                     w1sitm2 = aesItm2(bldItm);
                     w1sdisp = aesdisp(bldItm);
                     w1sqty1 = aesqty1(bldItm);
                     w1sum1 = aesum1(bldItm);
                     w1sqty2 = aesqty2(bldItm);
                     w1sum2 = aesum2(bldItm);
                     w1sqty3 = aesqty3(bldItm);
                     w1sum3 = aesum3(blditm);
                     w1sitpe = aesitpe(blditm);
                     w1aryrec = aearyrec(blditm);
                     exsr sfladd;
                  endif;
                  bldItm +=1;
              enddo;
           endif;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  toggleType - Toggle Repack Type between On-Demand Work Order
     *
     c     toggleType    begsr
      /free

        // this routine toggles the repack type between 1 and 2
        //  and rebuilds/re-display subfile
           fndItm = 1;
           // loop through entire array flipping any good or deleted records
           dow fndItm<=%Elem(aryRPD) and (aeDelcd(fndItm) = 'G'
                                  or aeDelcd(fndItm)='D');

              select;  //save pointer to first record on screen
              when aesitm2(fndItm) = hlsitm2(1);
              filPtr = fnditm;
              endsl;

              if aerptp(fndItm) = '2';
                 aerptp(fndItm) = '1';
                 aesdisp(fndItm) = ' ';
                 aedisp(fndItm) = ' ';
                 w1disp = ' ';
                 *in71 = *on;  // protect subfile slot entry
              else;
                 aerptp(fndItm) = '2';
                 // setup screen where cursor will position and highlight
                 // for output slot since we are coming from Work Order
                 // to On-Demand
                 *in70 = *off; //allow entry slot up high control
                 *in71 = *on;  //protect slot initially on subfile until control slot entered
                 *in16 = *on;
              endif;

              fndItm +=1;
           enddo;

           nxtscr = '01 ';

           exsr sflclr;
           exsr zzfil1;
           exsr zzchk1;

      /end-free
     c                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = 0
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = 0
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = ' '
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = ' '
     C                   eval      $msgf = ' '
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = ' '
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = ' '
     C                   eval      $msgf = ' '
     C                   endsr

     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     *  Screen error indicators.

     C                   if        $itwhdpe = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $itmiteme = '1'
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   endif

     C                   if        $ifodrslote = '1'
     C                   eval      *in46 = *on
     C                   endif

     C                   if        $itum1e = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $itum2e = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $itumq2e = '1'
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   endif

     C                   if        $itflg1e = '1'
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   endif

     C                   if        $itum3e = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $itumq3e = '1'
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PT13020  # of catch weights entered must = Quantity picked.
     *
     C     zm20          begsr
     C                   eval      #msgid = 'PT13020'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13019  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
     C                   eval      #msgid = 'PT13019'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13021  Warning: Entered catch weight not within +/- range.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PT13021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = ' '
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = ' '
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = ' '
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Check values on screen 1 before update
     *
     *----------------------------------------------------------------
     C     zzchk1        begsr

     c                   eval      errmsg = ' '
     C                   eval      error = *off

     *  convert quantities from character to numeric
      /free
        if w1cqty1a<>' ' and %Check(' 0123456789.':w1cqty1a)=0;
           w1cqty1 = %dec(w1cqty1a:3:0) ;
        else;
           w1cqty1 = 0;
        endif;

        if w1cqty2a<>' ' and %Check(' 0123456789.':w1cqty2a)=0;
           w1cqty2 = %dec(w1cqty2a:3:0) ;
        else;
           w1cqty2 = 0;
        endif;

        if w1cqty3a<>' ' and %Check(' 0123456789.':w1cqty3a)=0;
           w1cqty3 = %dec(w1cqty3a:3:0) ;
        else;
           w1cqty3 = 0;
        endif;
      /end-free

     *  read subfile for any changes
     c                   exsr      sflchg
     c                   if        error = *on
     c                   exsr      zm0105
     c                   endif

     *  Verify Slot for Output definition first
     c                   if        w1citm2<>' ' and
     c                               error = *off
     c                   eval      FirstAction = *off
     c                   eval      wkdisp = w1disp
     c                   exsr      fill$item
     C                   eval      $dricommand = '*ITEM'
     C                   if        $pcmd = '*ADD'
     C                   eval      $drisubcmd  = '%VERIFYADD'
     C                   else
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  If slot error indicator on from driitem flip to 35 for top control
     c                   if        error = *on
     c                   eval      *in35 = *on
     c                   eval      *in15 = *on
     c                   endif

     c                   if        error = *off
     c                   exsr      zzuompar
     c                   endif
     c                   endif
      /free
                    if error <> *on and w1disp<>' ';
                       chain ($pwhse:IT112RpWdp:w1disp) slot2;
MRTaA                  if client = Merit
GRCaA                     or client = Greco;
MRTaA                     hldrsrv = slrsrv;
MRTaA                     slrsrv = ' ';
MRTaA                  endif;
                       if not %found;
                          eval error = *on;
                          eval *in26 = *on;
                          eval *in16 = *on;
                          eval errmsg = 'Slot not valid';
                          exsr zm0105;
                       else;
                   //  Slot found but ensure it is acceptable slot
                          if sldesg = 'BFC' or slaisl='RCV' or
                            slaisl='STG' or slaisl='OSS' or slaisl='USR'
 700a                       or slstat<>'RP' or slrsrv='V';
                             eval error = *on;
                             eval *in26 = *on;
                             eval *in16 = *on;
                             eval errmsg = 'Slot not valid';
                             exsr zm0105;
                          endif;
                       endif;
MRTaA                  if client = Merit
GRCaA                     or client = Greco;
MRTaA                     slrsrv = hldrsrv;
MRTAa                  endif;
                    endif;
      /end-free
     *
     *   verify that On-Demand Slot for parent actually has item in it
     *
     c                   if        error = *off
     c                              and w1cdisp<>' '
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = IT112RpWdp
     C                   eval      $sldispu = *on
MRTaAc*  if Merit Foods be sure to send base slot and return
MRTaAc*  virtual since they use virtual slots for case ODR slot
MRTaA /free
MRTaA        if client = Merit;
MRTaA          chain ($pwhse:IT112RpWdp:w1cdisp) vslot1;
MRTaA          if %found(vslot1);
MRTaA             $sldisp = vspdis;
MRTaA          else;
MRTaA             $sldisp  = w1cdisp;
MRTaA          endif;
MRTbA        else;
MRTbA           $sldisp = w1cdisp;
MRTaA        endif;
MRTaA /end-free
MRTaDC*                  eval      $sldisp  = w1cdisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1citm2
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYINSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
MRTaAc                   if        client = Merit and
MRTaAc                             $drireturn = 'ITMFOUND'
MRTaAc                   eval      w1cdisp = $sldisp
MRTaAc                   eval      w1disp  = $sldisp
MRTaAc                   endif

     c*  do not enforce on-demand exist rule if parent item is an
     c*  on-demand item.  The virtual probably will not exist.
      /free
                    chain ($pwhse:w1citm2) kititem;
      /end-free
     c                   if        not %found
     c                              or (%found and kirptp <> '2')
     C                   if        $drireturn = 'ITMFOUND'
      /free
                              chain ($pwhse:$slwhdp:w1cdisp) slot2;
MRTaA                         if client = Merit
GRCaA                            or client = Greco;
MRTaA                            hldrsrv = slrsrv;
MRTaA                            slrsrv = ' ';
MRTaA                         endif;
                   //  Slot found but ensure it is acceptable slot
                              if sldesg = 'BFC' or slaisl='RCV' or
                                 slaisl='STG' or slaisl='OSS'
700a                             or slstat<>'RP' or slrsrv='V'
                                 or slaisl='USR';
                                 eval error = *on;
                                 eval *in46 = *on;
                                 eval *in14 = *on;
                                 eval errmsg = 'Slot not valid';
                                 exsr zm0105;
                              else;
                                 error=*off;
                              endif;
MRTaA                         if client = Merit
GRCaA                            or client = Greco;
MRTaA                            slrsrv = hldrsrv;
MRTaA                         endif;
      /end-free
     c                   else
650bA *   see if repack item exist in parent slot before throwing error
650bAC                   exsr      clr$slot
650bAC                   eval      $slwhseu = *on
650bAC                   eval      $slwhse  = $pwhse
650bAC                   eval      $slwhdpu = *on
650bAC                   eval      $slwhdp  = IT112RpWdp
650bAC                   eval      $sldispu = *on
MRTaAc*  if Merit Foods be sure to send base slot and return
MRTaAc*  virtual since they use virtual slots for case ODR slot
MRTaA /free
MRTaA        if client = Merit;
MRTaA          chain ($pwhse:IT112RpWdp:w1cdisp) vslot1;
MRTaA          if %found(vslot1);
MRTaA             $sldisp = vspdis;
MRTaA          else;
MRTaA             $sldisp  = w1cdisp;
MRTaA          endif;
MRTaA        endif;
MRTaA /end-free
MRTaDC*                  eval      $sldisp  = w1cdisp
650bAC                   eval      $saitemu = *on
GRCaDC*                  eval      $saitem  = It112RpItm
GRCaAC                   eval      $saitem  = w1citm2
650bAC                   eval      $dricommand = '*SLOT'
650bAC                   eval      $drisubcmd  = '%VFYINSLOT'
650bAC                   eval      $drisys2upd = 'D'
650bAC                   eval      zmsflag = *off
650bAC                   exsr      zzzdricop
650bAc                   if        $drireturn <> 'ITMFOUND'
     C                   eval      error = *on
     C                   eval      *in46 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = 'Item not in slot'
     C                   exsr      zm0105
650bAC                   endif
     C                   endif
     c                   else
MRTaAc                   if        client = Merit and
MRTaAc                             $drireturn = 'ITMFOUND'
MRTaAc                   eval      w1cdisp = $sldisp
MRTaAc                   eval      w1disp  = $sldisp
MRTaAc                   endif
      /free
                    chain ($pwhse:$slwhdp:w1cdisp) slot2;
                    if not %found;
                       eval error = *on;
                       eval *in46 = *on;
                       eval *in14 = *on;
                       eval errmsg = 'Slot not valid';
                       exsr zm0105;
                    else;
MRTaA                  if client = Merit
GRCaA                     or client = Greco;
MRTaA                    hldrsrv = slrsrv;
MRTaA                    slrsrv = ' ';
MRTaA                  endif;
                   //  Slot found but ensure it is acceptable slot
                       if sldesg = 'BFC' or slaisl='RCV' or
                         slaisl='STG' or slaisl='OSS' or slaisl='USR   '
700a                     or slstat<>'RP' or slrsrv='V';
                          eval error = *on;
                          eval *in46 = *on;
                          eval *in14 = *on;
                          eval errmsg = 'Slot not valid';
                          exsr zm0105;
                       endif;
MRTaA                  if client = Merit
GRCaA                     or client = Greco;
MRTaA                    slrsrv = hldrsrv;
MRTaA                  endif;
                    endif;
      /end-free
     C                   endif
     C                   endif
     *
     *  Only allow on-demand pick slot for type 2
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1rptp='1' and w1cdisp<>' '
     c                               and w1citm2<>' '
     *
     C                   eval      error = *on
     C                   eval      *in46 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = err(2)
     c                   exsr      zm0105
     c                   else
     c                   endif
     c                   endif
     *
     *  Only allow work order type to have a repack item as parent
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1rptp='1' and w1citpe='R'
     c                               and w1citm2<>' '
     *
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = err(11)
     c                   exsr      zm0105
     c                   else
     c                   endif
     c                   endif
     *
     *  Do not allow recursive items.  The same repack item cannot be
     *  be listed on that item as a parent item
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1citm2 = It112RpItm
     *
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = err(12)
     c                   exsr      zm0105
     c                   else
     c                   endif
     c                   endif
     *
     *  Parent lot or quantities entered require specific parent item
     *  be entered
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1citm2 = ' ' and
     c                              (w1cdisp<>' ' or w1cqty1a<>' '
     c                               or w1cqty2a<>' ' or w1cqty3a<>' ')
     *
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = err(14)
     c                   exsr      zm0105
     c                   else
     c                   endif
     c                   endif
     *
     *  make sure output quantity calcs correclty with parent quantity
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1citm2<>' '
     c                   eval      wrkitm = w1citm2
     c                   eval      wrkqty1 = w1cqty1
     c                   eval      wrkqty2 = w1cqty2
     c                   eval      wrkqty3 = w1cqty3
     c*   if it is decided to enforce a zero decimal relationship between
     c*   output qty and parent qty you can un-remark zzverqty
     c*                  exsr      zzverqty
     c                   if        error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = err(13)
     c                   exsr      zm0105
     c                   endif
     c                   endif
     c                   endif
     *
     *   Verify item entered does not already exist
     *
      /free
         if error = *off and w1citm2<>' '
            and (w1cdisp<>' ' or w1cQty1a<>' ' or w1cQty2a<>' '
                     or w1cQty3a<>' ');
         nxtItm = 1;
           dow nxtItm<=%Elem(aryRPD) and (aeDelcd(nxtItm)='D'
                 or aeDelcd(nxtItm) = 'G');
             if aesitm2(nxtItm) = w1citm2;
             // If item been deleted then re-instate with updated quantities
             // and "G" good record code.
               if aedelcd(nxtItm) = 'D';
                 aedelcd(nxtItm)='G';
                 aerptp(nxtItm) = w1rptp;
                 if w1cdisp<>' ';
                    aesdisp(nxtItm)=w1cdisp;
                 endif;
                 if w1cqty1a<>' ' and %Check(' 0123456789.':w1cqty1a)=0;
                    aesqty1(nxtItm)=w1cqty1;
                 endif;
                 if w1cqty2a<>' ' and %Check(' 0123456789.':w1cqty2a)=0;
                    aesqty2(nxtItm)=w1cqty2;
                 endif;
                 if w1cqty3a<>' ' and %Check(' 0123456789.':w1cqty3a)=0;
                    aesqty3(nxtItm)=w1cqty3;
                 endif;
                 if nxtItm<7; //if less than full screen start with 1st item
                    filPtr = 1;
                 else;
                    filPtr = nxtItm; //lets start with changed/added item
                 endif;
                 exsr sflclr;
                 exsr zzfil1;
              // clear control entries so ZZUPD1 will not add second time
              //  to subfile
                 w1citm2 = ' ';
                 w1cdisp = ' ';
                 w1cqty1 = 0;
                 w1cum1 = ' ';
                 w1cqty2 = 0;
                 w1cum2 = ' ';
                 w1cqty3 = 0;
                 w1cum3 = ' ';
                 w1cqty1a = ' ';
                 w1cqty2a = ' ';
                 w1cqty3a = ' ';
                 redspl = *on;
               else;
                 if updateAlready = *on;
                     // go ahead and update line to match request
                    aedelcd(nxtItm)='G';
                    aerptp(nxtItm) = w1rptp;

                    if w1cqty1a<>' ' and %Check(' 0123456789.':w1cqty1a)=0;
                       aesqty1(nxtItm)=w1cqty1;
                    endif;
                    if w1cqty2a<>' ' and %Check(' 0123456789.':w1cqty2a)=0;
                       aesqty2(nxtItm)=w1cqty2;
                    endif;
                    if w1cqty3a<>' ' and %Check(' 0123456789.':w1cqty3a)=0;
                       aesqty3(nxtItm)=w1cqty3;
                    endif;

                    if w1cdisp<>' ';
                    aesdisp(nxtItm)=w1cdisp;
                    endif;
                    aesum1(nxtItm)=w1cum1;
                    aesum2(nxtItm)=w1cum2;
                    aesum3(nxtItm)=w1cum3;

                    filPtr = nxtItm;
                    if filPtr < 7; //display all if fewer than 1 screen
                       filPtr = 1;
                    endif;
                    exsr sflclr;
                    exsr zzfil1;
                 // clear control entries so ZZUPD1 will not add second time
                 //  to subfile
                    w1citm2 = ' ';
                    w1cdisp = ' ';
                    w1cqty1 = 0;
                    w1cum1 = ' ';
                    w1cqty2 = 0;
                    w1cum2 = ' ';
                    w1cqty3 = 0;
                    w1cum3 = ' ';
                    w1cqty1a = ' ';
                    w1cqty2a = ' ';
                    w1cqty3a = ' ';
                    redspl = *on;
                    updateAlready = *off;
                 else;
                    if error = *off;
                       if ((w1cqty1a='0' or
                              w1cqty1a='00' or w1cqty1a='000') and
                              aesQty2(nxtItm)=0 and aesQty3(nxtItm)=0
                              and w1cQty2a=' ' and w1cQty3a=' ')
                                or ((w1cqty2a='0' or
                                  w1cqty2a='00' or w1cqty2a='000') and
                                  aesQty1(nxtItm)=0 and aesQty3(nxtItm)=0
                                  and w1cQty1a=' ' and w1cQty3a=' ')
                                or ((w1cqty3a='0' or
                                  w1cqty3a='00' or w1cqty3a='000') and
                                  aesQty1(nxtItm)=0 and aesQty2(nxtItm)=0
                                  and w1cQty1a=' ' and w1cQty2a=' ');
                         eval error = *on;
                         eval *in35 = *on;
                         eval *in15 = *on;
                         eval errmsg = err(3);
                         exsr zm0105;
                      else;
                         // trip error as duplicate item entered
                         error = *on;
                         *in35 = *on;
                         *in15 = *on;
                         errmsg = err(6);
                         exsr zm0105;
                         updateAlready = *on;
                      endif;
                    endif;
                 endif;
               endif;
             endif;
             nxtitm +=1;
           enddo;
         endif;
      /end-free
     *
     *  make sure repack type is 1 for Work Order or 2 for On-Demand
     *
     c                   if        w1rptp<>'1' and w1rptp<>'2'
     c                               and (w1citm2<>' '
     c                                      or w1disp<>' ')
     c                                and error = *off
     *
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = err(1)
     c                   exsr      zm0105
     *
     C                   endif
     *
     *  make sure on-demand pick slot is only allowed with type 2
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1rptp<>'2' and w1disp<>' '
     *
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in16 = *on
     C                   eval      errmsg = err(2)
     c                   exsr      zm0105
     c                   endif
     c                   endif
     *
     *  make sure on-demand pick slot is entered for type 2
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1rptp='2' and w1disp=' '
     *
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in16 = *on
     C                   eval      errmsg = err(8)
     c                   exsr      zm0105
     c                   endif
     c                   endif
     *
     *  make sure a qty is assocaited with at least one uom on output
     *
     C                   if        error = *off
     c                   if        w1rqty1=0 and w1rqty2=0
     c                               and w1rqty3=0
     c                                and w1citm2<>' '
     *
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in18 = *on
     C                   eval      *in29 = *on
     C                   eval      *in30 = *on
     C                   eval      errmsg = err(3)
     c                   exsr      zm0105
     *
     C                   endif
     C                   endif
     *
     *  make sure a qty is assocaited with at least one uom on input
     *
     C                   if        error = *off
650cA
650cAc                   if        nxtitm < 1
650cAc                   eval      nxtitm = 1
650cAc                   endif
650cA
     c                   if        w1cqty1=0 and w1cqty2=0
     c                               and w1cqty3=0
     c                                and w1citm2<>' '
650cDc*                                and w1cdisp=' '
     c                                 and w1cqty1a=' '
     c                                 and w1cqty2a=' '
     c                                 and w1cqty3a=' '
650cAc                                 and aesitm2(nxtitm)=*loval
     *
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in17 = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      errmsg = err(3)
     c                   exsr      zm0105
     *
     C                   endif
     C                   endif
     *
     *  make sure on-demand pick slot is entered for type 2
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        w1rptp='2' and w1cdisp=' '
     c                               and w1citm2<>' '
     *
     C                   eval      error = *on
     C                   eval      *in46 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = err(8)
     c                   exsr      zm0105
     c                   else
     c                   endif
     c                   endif
     *  if no errors from top control release subfile to be keyed into
     c                   if        error = *off and recno>0
     c*                  eval      *in70 = *on
     c                   eval      *in71 = *off
     c                   else
     c                   eval      *in70 = *off
     c                   endif
     *
     *   Make sure enties are valid before adding to subfile
     *
     c                   if        w1citm2<>' ' and
     c                              error = *off

     *  Dakota verification.
     *  Verify Slot for Input item exist
     C                   if        error = *off
     c                   eval      wkdisp = w1cdisp
     C                   exsr      fill$item
     C                   eval      $dricommand = '*ITEM'
     C                   if        $pcmd = '*ADD'
     C                   eval      $drisubcmd  = '%VERIFYADD'
     C                   else
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     *  If slot error indicator on from driitem flip to 35
     c                   if        error = *on
      /free
                         if %scan('slot' : $drimessage)>1;
                            *in46 = *on;
                            *in14 = *on;
                         else;
                            *in35 = *on;
                            *in15 = *on;
                         endif;
      /end-free
     c                   endif
     c                   endif
     C                   endif
     *
     *  make at least one component item entered
     *
     c                   if        error = *off
     c                   eval      errmsg = ' '
     c                   if        recno=0 and w1citm2 = ' '
     *
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in15 = *on
     C                   eval      errmsg = err(7)
     c                   exsr      zm0105
     *
     C                   endif
     C                   endif
     *
     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZVERQTY Verify parent quantity works with output quantity
     *           at the repack item level so a quantity of 1 can be
     *           created at either the normal, bd1, or bd2 qty level
     *           and require at least one full unit with no decimals
     *           at the lowest level
     *----------------------------------------------------------------

     C     zzverqty      begsr
      /free

       // This routine will ensure that once you get to the lowest
       // quantity level defined that one unit will consume non decimal
       // units at that lowest unit.

       error = *off;

       // get item

       exsr clr$item;
       $itwhse = $pwhse;
       $ititem  = wrkitm;
       $dricommand = '*ITEM';
       $drisubcmd  = '%GETPARENT';
       $drisys2upd = 'D';
       chk4err = *on;
       zmsflag = *on;
       exsr zzzdricop;
       if drierr;
          error = *on;
          $prtn = '*PGMQ   ';
       else;
          // determine lowest level defined in item maintenance
          select;
             when $itumq3<>0;
                wopqndec = (wrkqty1 * $itumq2 * $itumq3) +
                           (wrkqty2 * $itumq3) +
                            wrkqty3;
                wopqndec = wopqndec / w1Rqty1;
                if dec > 0;
                   error = *on;
                endif;

             when $itumq2<>0;
                wopqndec = (wrkqty1 * $itumq2) +
                            wrkqty2;
                wopqndec = wopqndec / w1Rqty1;
                if dec > 0;
                   error = *on;
                endif;

             other;
                wopqndec = wrkqty1 / w1Rqty1;
                if dec > 0;
                   error = *on;
                endif;

          endsl;
       endif;
      /end-free
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     *----------------------------------------------------------------
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endcm1
     C                   endif
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Build code.
     *
     C                   select
     *
     *  Lookup Slot for On-Demand Pick Slot
     *
     C                   when      (row# = 9  and
     C                               col# >= 25)

     c                   eval      $lcmd='*GENERAL'
     C                   eval      $lwhse=$pwhse
     C                   eval      $lwhdp=IT112RpWdp
     C                   eval      $litem2=' '
     C                   eval      $ldisp=' '
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1disp = $ldisp
     *  if user selected slot from lookup move cursor to next field
     c                   eval      *in18 = *on
     c                   else
     *  else poosition cursor for slot to be keyed
     c                   eval      *in16 = *on
     C                   endif
     c                   exsr      zsclr
     *
     *  Lookup Slot for On-Demand Parent Slot
     *
     C                   when      (row# = 14 and
     C                               col# >= 20)

     c                   eval      $lcmd='*GENERAL'
     C                   eval      $lwhse=$pwhse
     C                   eval      $lwhdp=IT112RpWdp
     C                   eval      $litem2=' '
     C                   eval      $ldisp=' '
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     c                   eval      w1cdisp = $ldisp
     *  if user selected slot from lookup move cursor to next field
     c                   eval      *in17 = *on
     c                   else
     *  else poosition cursor for slot to be keyed
     c                   eval      *in14 = *on
     C                   endif
     c                   exsr      zsclr

     *  Full case item number.

     C                   when      row# = 14  and
     C                             col# >= 2 AND col#<21
     C                   eval      *in15 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = ' '
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     *  if user selected item from lookup move cursor to next field
     c                   eval      *in14 = *on
     c                   eval      *in15 = *off
     C                   eval      w1citm2 = $litem
     c                   else
     *  else poosition cursor for item to be keyed
     c                   eval      *in15 = *on
     C                   endif
     c                   exsr      zsclr
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     c                   eval      cmdtkn = *on
     C                   goto      endcm1
     C                   endif
720 A*
720 A*  Test for 10 - Virtual Slot Maintenance
720 A*
720 AC                   if        *inkj
720 Ac                   call      'SL270CL'
720 AC                   exsr      scr01i
720 Ac                   eval      cmdtkn = *on
720 AC                   goto      endcm1
720 AC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = 'EOJ'
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Test for F20 - Change Repack Type when not in *VIEW mode
     *
     C                   if        *inku
     c                   if        *in90 = *off
     c                   exsr      scr02i
     c                   eval      cmdtkn = *on
     C                   goto      endcm1
     c                   else
     c                   eval      cmdtkn = *on
     c                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1rptp = ' '
     C                   eval      w1disp = ' '
     c                   eval      w1rum1 = w2rum1
     c                   eval      w1rum2 = w2rum2
     c                   eval      w1rum3 = w2rum3
     C                   eval      w1rqty1 = 0
     C                   eval      w1rqty2 = 0
     C                   eval      w1rqty3 = 0
     c                   eval      *in70 = *off
     c                   eval      *in71 = *on
     *
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     * ZZFLG    Set UCI flag ... if client is Packers and the
     *          catchweight has a UCI label rec, turn on UCI flag
     *
     C     ZZFLG         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 3 fields with info from array aryRPD
     *
     C     zzfil1        begsr
     *
      /free
         // check to see if sfl count is zero.  If so load top control
         // fields from first element of array in user space if data
         // exist
         if (aedelcd(1) = 'G' or aedelcd(1) = 'D');
            if w1disp = ' ' and error = *off;
               w1rptp = aerptp(1);
               w1disp = aedisp(1);
               w1rqty1 = aerqty1(1);
               w1rum1 = aerum1(1);
               w1rqty2 = aerqty2(1);
               w1rum2 = aerum2(1);
               w1rqty3 = aerqty3(1);
               w1rum3 = aerum3(1);
            else;
               w1rptp = aerptp(1);
               w1disp = aedisp(1);
            endif;
         endif;

            // reload 6 entry subfile
            if w1rptp = '1';
               *in71 = *on;
            endif;

            // if error then make sure it is visiable on screen
            if sflerr = '1';
              filPtr = filPtr - 5;
              if filPtr < -1;
                 filPtr = 1;
              endif;
            endif;

            dow filptr<=%Elem(aryRPD) and reccnt<6 and
                  (aeDelcd(filPtr)='G' or aeDelcd(filPtr)='D');
               if aeDelcd(filPtr)='G';
                  if sflerr = '1';
                     w1sitm2 = aesitm2(filPtr);
                     w1sdisp = aesdisp(filptr);
                     w1sqty1 = aesqty1(filptr);
                     w1sum1 = aesum1(filptr);
                     w1sqty2 = aesqty2(filptr);
                     w1sum2 = aesum2(filptr);
                     w1sqty3 = aesqty3(filptr);
                     w1sum3 = aesum3(filptr);
                     w1sitpe = aesitpe(filptr);
                     w1aryrec = aearyrec(filptr);
                     *in40 = *on;
                     sflerr = '0';
                     exsr sfladd;
                  else;
                     if sflerr = '0';
                        w1sitm2 = aesitm2(filptr);
                        w1sdisp = aesdisp(filptr);
                        w1sqty1 = aesqty1(filptr);
                        w1sum1 = aesum1(filptr);
                        w1sqty2 = aesqty2(filptr);
                        w1sum2 = aesum2(filptr);
                        w1sqty3 = aesqty3(filptr);
                        w1sum3 = aesum3(filptr);
                        w1sitpe = aesitpe(filptr);
                        w1aryrec = aearyrec(filptr);
                        exsr sfladd;
                     endif;
                     *in40 = *off;
                  endif;
               endif;
               filptr +=1;
            enddo;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     *----------------------------------------------------------------
     C     zzinz         begsr
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *  Define full key for item file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     *----------------------------------------------------------------
     C     zzinz1        begsr
     *
     *   Delete, Create and assign User Space memory pointer to
     *     manage variabe Repack Component array
     *
      /Free
         //get pointer to user space array defined in IT112 prior to call
         RtvPtrToUsrSpc ('ARYRPD    QTEMP': ptrRPD: Qusec);
      /End-free
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = ' '
     C                   endif
     *
     c                   eval      w1disp = ' '
     c                   eval      w1rptp = ' '
     *
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw = 'N'
     C                   endif
      *
      *  protect Output quantity for Breakdown 1 if UOM empty from IT112
     c*                  if        w2rum2=' '
     c                   eval      *in96=*on
     c*                  else
     c*                  eval      *in96=*off
     c*                  endif
      *
      *  protect Output quantity for Breakdown 2 if UOM empty from IT112
     c*                  if        w2rum3=' '
     c                   eval      *in92=*on
     c*                  else
     c*                  eval      *in92=*off
     c*                  endif
      *
     c                   eval      savrptp = ' '
     c                   eval      updateAlready = *off
     c                   eval      savfrst = 1
     c                   eval      savlast = 1
     c                   eval      filPtr = 1
      *  determine number of incoming elements in array to start pointer
     c                   eval      additm = 1
     c                   dow       (aedelcd(additm) = 'D' or
     c                              aedelcd(additm) = 'G')
     c                               and additm<=%Elem(aryRPD)
     c                   eval      aerum1(additm) = w2rum1
     c                   eval      aerum2(additm) = w2rum2
     c                   eval      aerum3(additm) = w2rum3
     c                   eval      additm = additm +1
     c                   enddo
     c                   eval      additm = additm - 1
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     *----------------------------------------------------------------
     C     zzusub        begsr
     *  normally would have sub file updates to database
     *  update are performed in DRIITEM
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update using subfile records.
     *
     C     zzupd1        begsr
     *
     *  If user changed the Repack Type execute the Toggle routine
     *    which toggles repack type between 1 and 2 and redisplay
     *    with any errors
     *
     c                   if        w1rptp<>savrptp and savrptp<>' '
     c                              and w1rptp<>'2'
     c                   eval      nxtScr = '02'
     c                   eval      savrptp = w1rptp
     c                   goto      endup1
     c                   endif
     *
     *  If user is adding a detail record ...
     *    - add it to subfile and return to entry screen
     *
     C                   if        (w1citm2 <> ' ')
     c                              and (w1cqty1<>0 or w1cqty2<>0 or
     c                                     w1cqty3<>0)
     C                   eval      *in85 = *on
     *  make sure sfl will not go beyond 6 records, otherwise adjust
     c                   exsr      sflFree
     *  move fields from control record to subfile record for add
     c                   eval      w1sitm2 = w1citm2
     c                   eval      w1sdisp = w1cdisp
     c                   eval      w1sqty1 = w1cqty1
     c                   eval      w1sum1 = w1cum1
     c                   eval      w1sqty2 = w1cqty2
     c                   eval      w1sum2 = w1cum2
     c                   eval      w1sqty3 = w1cqty3
     c                   eval      w1sum3 = w1cum3
     c                   eval      w1sitpe = w1citpe
     c                   eval      w1aryrec = additm + 1
     C                   exsr      sfladd
     C                   eval      w1citm2 = ' '
     c                   eval      w1cdisp = ' '
     c                   eval      w1cqty1 = 0
     c                   eval      w1cum1 = ' '
     c                   eval      w1cqty2 = 0
     c                   eval      w1cum2 = ' '
     c                   eval      w1cqty3 = 0
     c                   eval      w1cum3 = ' '
     c                   eval      w1cqty1a = ' '
     c                   eval      w1cqty2a = ' '
     c                   eval      w1cqty3a = ' '
     C                   eval      redspl = *on
     c                   eval      *in15 = *on
     *
     *  UPDATE array for Repack component items
     *
      /Free
                        addItm +=1;
                        aedelcd(addItm) = 'G';
                        aeitem(addItm) = IT112RpItm;
                        aesitm2(addItm) = w1sitm2;
                        aesdisp(addItm) = w1sdisp;
                        aesqty1(addItm) = w1sqty1;
                        aesum1(addItm) = w1sum1;
                        aesqty2(addItm) = w1sqty2;
                        aesum2(addItm) = w1sum2;
                        aesqty3(addItm) = w1sqty3;
                        aesum3(addItm) = w1sum3;
                        aesitpe(additm) = w1sitpe;
                        aerptp(addItm) = w1rptp;
                        aedisp(addItm) = w1disp;
                        aerqty1(addItm) = w1rqty1;
                        aerum1(addItm) = w1rum1;
                        aerqty2(addItm)= w1rqty2;
                        aerum2(addItm) = w1rum2;
                        aerqty3(addItm)= w1rqty3;
                        aerum3(addItm) = w1rum3;
                        aearyrec(addItm) = additm;

      /End-free
     C                   endif
     C     endup1        endsr
     *----------------------------------------------------------------
     *  ZZUOMPAR For Repack Items, get Unit of Measure from parent
     *----------------------------------------------------------------

     C     zzuompar      begsr

      *   If Repack Item 'R', load Unit of Measure from Parent Item

     *   Get Unit of Measures.

     C                   exsr      fill$item
     C                   exsr      zzsavflds

      * Override and send parent item # to get parent uom
     C                   eval      $ititem  = w1Citm2
     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETPARENT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   if        error = *on
     C                   exsr      zzrestflds
     C                   goto      enduom
     C                   else

     *  these checks apply to the control line just above subfile
     *  make sure no quantity is entered for subfile line without
     *   parent definition for that UOM
     c                   if        w1cqty2>0 and $itum2 = ' '
     c                   eval      error= *on
     c                   eval      *in32 = *on
     C                   eval      errmsg = err(5)
     c                   endif
     c                   if        w1cqty3>0 and $itum3 = ' '
     c                   eval      error= *on
     c                   eval      *in33 = *on
     c                   eval      *in13 = *on
     C                   eval      errmsg = err(5)
     c                   endif
     c                   if        error = *on
     c                   exsr      zm0105
     c                   goto      enduom
     c                   endif

     C                   eval      w1cum1 = $itum1
     C                   eval      w1cum2 = $itum2
     C                   eval      w1cum3 = $itum3
     c                   eval      w1citpe = $ittype
     c                   endif
     C                   exsr      zzrestflds
     C     enduom        endsr
     *----------------------------------------------------------------
     *  ZZSAVFLDS   Save data structure fields
     *----------------------------------------------------------------

     C     zzsavflds     begsr
     C                   eval      #svitver#  = $itver#
     C                   eval      #svitwhse  = $itwhse
     C                   eval      #svititem  = $ititem
     C                   eval      #svitmitem = $itmitem
     C                   eval      #svitcitem = $itcitem
     C                   eval      #svittype  = $ittype
     C                   eval      #svitdesc  = $itdesc
     C                   eval      #svitstyp  = $itstyp
     C                   eval      #svitwhdp  = $itwhdp
     C                   eval      #svitdesg  = $itdesg
     C                   eval      #svitactv  = $itactv
     C                   eval      #svitupc   = $itupc
     C                   eval      #svitbld   = $itbld
     C                   eval      #svitven#  = $itven#
     C                   eval      #svitvit#  = $itvit#
     C                   eval      #svitpdsc  = $itpdsc
     C                   eval      #svitum1   = $itum1
     C                   eval      #svitflg1  = $itflg1
     C                   eval      #svitum2   = $itum2
     C                   eval      #svitumq2  = $itumq2
     C                   eval      #svitflg2  = $itflg2
     C                   eval      #svitum3   = $itum3
     C                   eval      #svitumq3  = $itumq3
     C                   eval      #svitulen  = $itulen
     C                   eval      #svituwdt  = $ituwdt
     C                   eval      #svituhgt  = $ituhgt
     C                   eval      #svitcube  = $itcube
     C                   eval      #svitswgt  = $itswgt
     C                   eval      #svitcwgt  = $itcwgt
     C                   eval      #svitreor  = $itreor
     C                   eval      #svitrepl  = $itrepl
     C                   eval      #svitrcvd  = $itrcvd
     C                   eval      #svitflgd  = $itflgd
     C                   eval      #svitflgb  = $itflgb
     C                   eval      #svitslif  = $itslif
     C                   eval      #svitnday  = $itnday
     C                   move      $idsdef       #svitsdef
     C                   move      $idtie        #svittie
     C                   move      $idhigh       #svithigh
     C                   move      $idum         #svitum
     C                   move      $idsdef       #svitsdef
     C                   eval      #svixdsc1  = $ixdsc1
     C                   eval      #svixdsc2  = $ixdsc2
     C                   eval      #svimtie   = $imtie
     C                   eval      #svimhigh  = $imhigh
     C                   eval      #svimmflg  = $immflg
     C                   eval      #svimdday  = $imdday
     C                   eval      #svimuday  = $imuday
     C                   eval      #svimmday  = $immday
     C                   eval      #svimwrnc  = $imwrnc
     C                   eval      #svimrg1c  = $imrg1c
     C                   eval      #svimrg2c  = $imrg2c
     C                   eval      #svimapck  = $imapck
     C                   eval      #svimnrpk  = $imnrpk
     C                   eval      #svimnslt  = $imnslt
     C                   eval      #svimxdck  = $imxdck
     C                   eval      #svimbnbr  = $imbnbr
     C                   eval      #svimbnam  = $imbnam
     C                   eval      #svimvnam  = $imvnam
     C                   eval      #svimbrnd  = $imbrnd
     C                   eval      #svimlot   = $imlot
     C                   eval      #svimltrk  = $imltrk
     C                   eval      #svimoday  = $imoday
     C                   eval      #svifcat   = $ifcat
     C                   eval      #svifodrslot = $ifodrslot
     C                   eval      #svifcaseovf = $ifcaseovf
     C                   eval      #svifucicde  = $ifucicde
     C                   eval      #svifrcvmth  = $ifrcvmth
     C                   eval      #svifsltmth  = $ifsltmth
     C                   eval      #svifbrdflg  = $ifbrdflg
650aAC                   eval      #svkcdisp  = $kcdisp
     C                   eval      #svkcqty1  = $kcqty1
     C                   eval      #svkcqty2  = $kcqty2
     C                   eval      #svkcqty3  = $kcqty3
650aAC                   eval      #svkidisp  = $kidisp
650aAC                   eval      #svkirptp  = $kirptp
650aAC                   eval      #svkiqty1  = $kiqty1
650aAC                   eval      #svkiqty2  = $kiqty2
650aAC                   eval      #svkiqty3  = $kiqty3
     C     endsav        endsr
     *----------------------------------------------------------------
     *  ZZRESTFLDS   Restore saved data structure fields
     *----------------------------------------------------------------

     C     zzrestflds    begsr
     C                   eval      $itver#    = #svitver#
     C                   eval      $itwhse    = #svitwhse
     C                   eval      $ititem    = #svititem
     C                   eval      $itmitem   = #svitmitem
     C                   eval      $itcitem   = #svitcitem
     C                   eval      $ittype    = #svittype
     C                   eval      $itdesc    = #svitdesc
     C                   eval      $itstyp    = #svitstyp
     C                   eval      $itwhdp    = #svitwhdp
     C                   eval      $itdesg    = #svitdesg
     C                   eval      $itactv    = #svitactv
     C                   eval      $itupc     = #svitupc
     C                   eval      $itbld     = #svitbld
     C                   eval      $itven#    = #svitven#
     C                   eval      $itvit#    = #svitvit#
     C                   eval      $itpdsc    = #svitpdsc
     C                   eval      $itum1     = #svitum1
     C                   eval      $itflg1    = #svitflg1
     C                   eval      $itum2     = #svitum2
     C                   eval      $itumq2    = #svitumq2
     C                   eval      $itflg2    = #svitflg2
     C                   eval      $itum3     = #svitum3
     C                   eval      $itumq3    = #svitumq3
     C                   eval      $itulen    = #svitulen
     C                   eval      $ituwdt    = #svituwdt
     C                   eval      $ituhgt    = #svituhgt
     C                   eval      $itcube    = #svitcube
     C                   eval      $itswgt    = #svitswgt
     C                   eval      $itcwgt    = #svitcwgt
     C                   eval      $itreor    = #svitreor
     C                   eval      $itrepl    = #svitrepl
     C                   eval      $itrcvd    = #svitrcvd
     C                   eval      $itflgd    = #svitflgd
     C                   eval      $itflgb    = #svitflgb
     C                   eval      $itslif    = #svitslif
     C                   eval      $itnday    = #svitnday
     C                   move      #svitsdef     $idsdef
     C                   move      #svittie      $idtie
     C                   move      #svithigh     $idhigh
     C                   move      #svitum       $idum
     C                   move      #svitpref     $idpref
     C                   eval      $ixdsc1    = #svixdsc1
     C                   eval      $ixdsc2    = #svixdsc2
     C                   eval      $imtie     = #svimtie
     C                   eval      $imhigh    = #svimhigh
     C                   eval      $immflg    = #svimmflg
     C                   eval      $imdday    = #svimdday
     C                   eval      $imuday    = #svimuday
     C                   eval      $immday    = #svimmday
     C                   eval      $imwrnc    = #svimwrnc
     C                   eval      $imrg1c    = #svimrg1c
     C                   eval      $imrg2c    = #svimrg2c
     C                   eval      $imapck    = #svimapck
     C                   eval      $imnrpk    = #svimnrpk
     C                   eval      $imnslt    = #svimnslt
     C                   eval      $imxdck    = #svimxdck
     C                   eval      $imbnbr    = #svimbnbr
     C                   eval      $imbnam    = #svimbnam
     C                   eval      $imvnam    = #svimvnam
     C                   eval      $imbrnd    = #svimbrnd
     C                   eval      $imlot     = #svimlot
     C                   eval      $imltrk    = #svimltrk
     C                   eval      $imoday    = #svimoday
     C                   eval      $ifcat     = #svifcat
     C                   eval      $ifodrslot = #svifodrslot
     C                   eval      $ifcaseovf = #svifcaseovf
     C                   eval      $ifucicde  = #svifucicde
     C                   eval      $ifrcvmth  = #svifrcvmth
     C                   eval      $ifsltmth  = #svifsltmth
     C                   eval      $ifbrdflg  = #svifbrdflg
650aAC                   eval      $kcdisp    = #svkcdisp
     C                   eval      $kcqty1    = #svkcqty1
     C                   eval      $kcqty2    = #svkcqty2
     C                   eval      $kcqty3    = #svkcqty3
650aAC                   eval      $kidisp    = #svkidisp
650aAC                   eval      $kirptp    = #svkirptp
650aAC                   eval      $kiqty1    = #svkiqty1
650aAC                   eval      $kiqty2    = #svkiqty2
650aAC                   eval      $kiqty3    = #svkiqty3
     C     endrest       endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $saemp#U = *on
     C                   endsr

     *----------------------------------------------------------------
     *  fill$item  Fill $item data structure fields.
     *----------------------------------------------------------------

     C     fill$item     begsr

     *  Initialize data structure

     C                   clear                   $item
     C                   clear                   $item2

     *  Move fields from record to data structure.

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = IT112RpItm
     C                   eval      $ittypeu  = *on
     C                   eval      $ittype  = 'R'

     C                   eval      $itwhdpu = *on
     C                   eval      $itwhdp = IT112RpWdp

     C                   eval      $ifodrslotu = *on
     C                   eval      $ifodrslot = wkdisp
     C                   eval      $itmitemu = *on
     C                   eval      $itmitem = w1citm2

     c                   eval      $kcdispu = *on
     c                   eval      $kidispu = *on
     c                   eval      $kirptpu = *on
     c                   eval      $kiqty1u = *on
     c                   eval      $kiqty2u = *on
     c                   eval      $kiqty3u = *on
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop    Call DRICOP
     *----------------------------------------------------------------
     *
     C     zzzdricop     begsr
     C                   eval      error = *off
      *
     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl
     *
     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif
     *
     C                   select
     *
     C                   when      %error and $dricommand <> '*SLOT'
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif
     *
     C                   when      $drireturn <> '*OK'
     c                               and $dricommand <> '*SLOT'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif
     *
     C                   endsl
     *
     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl
     *
     C                   eval      zmsflag = *off
     C     enddricop     endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
** Program Error Messages
Repack Type must be 1 or 2
On-Demand only valid for Repack Type 2
Qty required for at least one UOM
Slot only valid for Repack Type 2
Qty not valid without parent UOM
Item already defined. Press enter to update..
At least one component must be entered
On-Demand Slot must be entered for Repack Type 2
Please add On-Demand slots. Current and forward.
You can delete by clearing, but you CANNOT change
Repack items only valid with On-Demand Repacks
Recursive item not allowed
Output Qty not multiple of Parent breakdown
Parent qty or slot requires parent item
Slot not valid
