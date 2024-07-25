      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKLIVE    Check if department is live
     *  01 April 2005
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*   04/01/05  DAS  5.00
     *     - Created.
640 A*   01/13/11  RH   6.40
     *     - Enh: Add whse to parms
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*   12/15/10  RH   DRYa
     *     - Changed program to report *LIVE for DRY dept.
     *       and *NOTLIVE for all others.
DRYbA*   02/14/11  RH   DRYb
     *     - Changed program to report *LIVE for all dept, will start
     *       receive in all dept, with RF Stuffit count in DRY.
DRYcA*   02/02/13  HNK  DRYc
     *     - Changed program to report *LIVE for all dept for warehouse 90.
DRYdA*   02/19/13  RH   DRYd
     *     - Changed program to report *LIVE for all depts for whse
     *       095 - SF
DRYeA*   03/26/13  MLB  DRYe
     *     - Changed program to report *LIVE for all depts for whse
     *       040 - Queensgate
DRYfA*   07/08/13  MLB  DRYf
     *     - Changed program to report *LIVE for all depts for whse
     *       098 - Las Vegas.
DRYgA*   07/26/13  MLB  DRYg
     *     - Changed program to report *LIVE for all depts for whse
     *       096 - Portland.
DRYhA*   07/31/13  MLB  DRYh
     *     - Changed program to report *LIVE for all depts for whse
     *       094 - Seattle.
DRYiA*   08/20/13  MLB  DRYi
     *     - Changed program to report *LIVE for all depts for whse
     *       061 - Miami.
DRYjA*   06/10/14  MLB  DRYj
     *     - Changed program to report *LIVE for all depts for Qzina
     *       whse's: 011 - NJ, 065 - Miami, 070 - Chicago, 091 - SF
     *       and 092 - LA.
DRYkA*   02/23/16  MLB  DRYk
     *     - Changed program to report *LIVE for all depts for Qzina
     *       whse's: 030 - Toronto, 035 - Edmonton and 39 - Vancouver.
DRYlA*   03/29/19  MLB  DRYl
     *     - Changed program to report *LIVE for all depts for Texas
     *       whse's: 080 - Houston, 081 - San Antonio and 82 - Dallas.
DRYmA*   12/02/19  MLB  DRYm
     *     - Changed program to report *LIVE for all depts for
     *       whse: 050 -  Swedesboro NJ.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
     *
JOR1A*   06/21/05  MLB  JOR1
     *     - Changed program to report *LIVE for ALL dept's.
     *       Removed limitation for just DRY dept.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle
     *
FIN A*   06/11/08  RBD  FIN
     *     - Changed program to report *LIVE for DRY dept
     *       and *NOTLIVE for all others.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFCaA*   08/10/10  MLB  GFCa
     *     - Changed program to report *LIVE for REF dept
     *       and *NOTLIVE for all others.
     *
GFCb *   08/19/10  GJA  GFCb
     *     - Department changed from REF to CLR
GFCc *   09/12/10  GJA  GFCc
     *     - Revised program so that no departments are Live
     *       at this time. Per Gary S.
GFCd *   02/18/11  GJA  GFCd
     *     - Changed program to report *LIVE for FRZ dept
GFCe *   06/03/11  GJA  GFCe
     *     - Changed program to report *LIVE for DRY dept
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOF A*   01/03/17  MLB  SOF
     *     - Changed program to report *LIVE for CLR, FRZ depts.
     *       and *NOTLIVE for all others.
SOFaA*   01/16/17  RH   SOFa
     *     - Changed program to report *LIVE for CLR only depts.
SOFbA*   03/02/17  RH   SOFb
     *     - Changed program to report *LIVE for FRZ along with CLR
SOFcA*   04/18/18  RH   SOFc
     *     - Changed program to report *LIVE for All dept, DRY, CLR
     *       FRZ.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FarmBoy
     *
FBY A*   10/13/15  RDR  FBY
     *     - Changed program to report *LIVE for DRY dept (3)
     *       and *NOTLIVE for all others.
FBYbA*   04/03/17  RH   FBYb
     *     - Changed program to report *LIVE for dept except FRZ (1)
FBYc *   01/31/18  RTR  FBYc
     *     - Changed program to report *LIVE for all depts
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's
     *
KFS A*   03/01/19  RH   KFS
     *     - Changed program to report *NOTLIVE for dept CHK
     *       No chicken processed on Dakota.
KFSbA*   02/19/22  RH   KFSb
     *     - Removed change to report *NOTLIVE for dept CHK
     *       Chicken will now be processed on Dakota.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Menu Maker
     *
GMM A*   10/03/19  MLB  GMM
     *     - Changed program to report *LIVE for ALL dept's.
     *       Needed as part of Retalix interfaces.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#jordano
FIN A /copy qcopysrc,id#finkle
DRYaA /copy qcopysrc,id#dairyla
GFCaA /copy qcopysrc,id#glazier
SOF A /copy qcopysrc,id#sofo
GMM A /copy qcopysrc,id#gmm
FBYaA /copy qcopysrc,id#fby
KFSaA /copy qcopysrc,id#kfs

     *----------------------------------------------------------------
     *  Input parameters
     *
     *      $pwhdp     -  Department
     *
     *  Output parameters
     *
     *      $prtn      -  *LIVE     - Department is live
     *                    *NOTLIVE  - Department is not live
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
640 AC                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     * Default to Live.

     C                   eval      $prtn = '*LIVE'

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10

     * See if department is live or not.

     C                   select

     C                   when      client = jordanos
JOR1DC*                  if        $pwhdp <> 'DRY'
JOR1DC*                  eval      $prtn = '*NOTLIVE'
JOR1DC*                  endif

FIN AC                   when      client = finkle
FIN AC                   if        $pwhdp = 'DRY'
FIN AC                   eval      $prtn = '*LIVE   '
FIN AC                   else
FIN AC                   eval      $prtn = '*NOTLIVE'
FIN AC                   endif

GFCaAC                   when      client = glazier
GFCbDC*****              if        $pwhdp = 'REF'
GFCbAC                   if        $pwhdp = 'CLR'
GFCdAC                             or $pwhdp = 'FRZ'
GFCeAC                             or $pwhdp = 'DRY'
GFCcDC                   eval      $prtn = '*LIVE   '
GFCcMC*                  eval      $prtn = '*NOTLIVE'
GFCaAC                   else
GFCaAC                   eval      $prtn = '*NOTLIVE'
GFCaAC                   endif

FBY AC                   when      client = farmboy
FBYbDC**                 if        $pwhdp = '3'
FBYcDC**                 if        $pwhdp <> '1'
FBY AC                   eval      $prtn = '*LIVE   '
FBYcDC**                 else
FBYcDC**                 eval      $prtn = '*NOTLIVE'
FBYcDC**                 endif

KFS AC                   when      client = kellys
KFSaAC                   if        $pwhdp = 'CHK'
KFSbDC**                 eval      $prtn = '*NOTLIVE'
KFSbMC                   eval      $prtn = '*LIVE   '
KFSaAC                   endif

DRYaAC                   when      client = dairyland
DRYbAC                   select
DRYbAC                   when      $pwhse = 1
DRYbAC                   eval      $prtn = '*LIVE   '
DRYaAC                   when      $pwhse = 55
DRYbAC                   eval      $prtn = '*LIVE   '
DRYcAC                   when      $pwhse = 90
DRYcAC                   eval      $prtn = '*LIVE   '
DRYdAC                   when      $pwhse = 95
DRYdAC                   eval      $prtn = '*LIVE   '
DRYeAC                   when      $pwhse = 40
DRYeAC                   eval      $prtn = '*LIVE   '
DRYfAC                   when      $pwhse = 98
DRYfAC                   eval      $prtn = '*LIVE   '
DRYgAC                   when      $pwhse = 96
DRYgAC                   eval      $prtn = '*LIVE   '
DRYhAC                   when      $pwhse = 94
DRYhAC                   eval      $prtn = '*LIVE   '
DRYiAC                   when      $pwhse = 61
DRYiAC                   eval      $prtn = '*LIVE   '
DRYjAC                   when      $pwhse = 11
DRYjAC                   eval      $prtn = '*LIVE   '
DRYkAC                   when      $pwhse = 30
DRYkAC                   eval      $prtn = '*LIVE   '
DRYkAC                   when      $pwhse = 35
DRYkAC                   eval      $prtn = '*LIVE   '
DRYkAC                   when      $pwhse = 39
DRYkAC                   eval      $prtn = '*LIVE   '
DRYmAC                   when      $pwhse = 50
DRYmAC                   eval      $prtn = '*LIVE   '
DRYjAC                   when      $pwhse = 65
DRYjAC                   eval      $prtn = '*LIVE   '
DRYjAC                   when      $pwhse = 70
DRYjAC                   eval      $prtn = '*LIVE   '
DRYlAC                   when      $pwhse = 80
DRYlAC                   eval      $prtn = '*LIVE   '
DRYlAC                   when      $pwhse = 81
DRYlAC                   eval      $prtn = '*LIVE   '
DRYlAC                   when      $pwhse = 82
DRYlAC                   eval      $prtn = '*LIVE   '
DRYjAC                   when      $pwhse = 91
DRYjAC                   eval      $prtn = '*LIVE   '
DRYjAC                   when      $pwhse = 92
DRYjAC                   eval      $prtn = '*LIVE   '
DRYbA
DRYbDC*                  if        $pwhdp = 'DRY'
DRYbDC*                  eval      $prtn = '*LIVE   '
DRYbDC*                  else
DRYbDC*                  eval      $prtn = '*NOTLIVE'
DRYbDC*                  endif
DRYbAC                   other
DRYbAC                   eval      $prtn = '*NOTLIVE'
DRYbAC                   endsl
DRYbA
GMM AC                   when      client = MenuMaker
GMM AC                   eval      $prtn = '*LIVE   '
GMM A
SOF AC                   when      client = sofofoods
SOF A
SOF AC                   eval      $prtn = '*LIVE   '
SOF AC                   if        $pwhse = 71
SOFcAC**  Do not execute code below, all departments live.
SOF AC**                 if           $pwhdp = 'CLR'
SOFbAC**                           or $pwhdp = 'FRZ'
SOF AC                   eval      $prtn = '*LIVE   '
SOF AC**                 else
SOF AC**                 eval      $prtn = '*NOTLIVE'
SOF AC**                 endif
SOF AC                   endif
     C                   endsl

     C                   return
