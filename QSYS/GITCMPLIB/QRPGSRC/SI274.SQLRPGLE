     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *   Compile Options: OPTIONS(*CVTDT)
     *
     *----------------------------------------------------------------
     *
     *  SI274   Clear all Slot fields for initial slot load.
     *  01 June 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/01/05  MLB  5.00
     *      - Created.
500aA*    08/08/05  MLB  5.00a
     *      - Enh: Added client custom code support to program.
500bA*    11/29/05  MLB  5.00b
     *      - Enh: Revised program to delete all records from
     *        SLOTDGT.
     *      - Enh: Revised program to delete all records from
     *        SLOT.
600aA*    04/16/09  DAS  6.00a
     *      - Enh: Revised to not delete special slots
     *        RCV/STG/OSS.
600bA*    05/18/09  DAS  6.00a
     *      - Enh: Revised to delete OSS slots.
     *
530 A*    03/25/10  MLB  5.30
     *      - Enh: Revised to delete rcds from SLOTDGTA.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Ellenbee-Leggett
     *
ELL A*    05/02/07  MLB  ELL
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
GSC1A*    12/27/05  MLB  GSC1
     *      - Revised program to not delete records from SLOTDGT
     *        file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    09/21/09  MLB  HAL
     *      - Revised program to delete RCVxxxxxxx, STGxxxxxx rcds
     *        from SLOT, VSLOT files.  Per Steve H. request.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery Co.
     *
SGC A*    05/02/07  MLB  SGC
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI, LLC.
     *
CDI A*    10/13/09  MLB  CDI
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Indianhead Foodservice
     *
IFD A*    02/04/08  MLB  IFD
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SoFo Foods
     *
SOF A*    03/09/09  MLB  SOF
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVL A*    04/17/09  MLB  SVL
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/01/09  MLB  DRY
     *      - Revised program to not delete records from SLOTDGT
     *        file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Mattingly Foods
     *
MAT A*    01/25/10  MLB  MAT
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods Company
     *
FFC A*    03/25/10  MLB  FFC
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCP A*    03/31/10  MLB  CCP
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added CCP to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    04/01/10  MLB  CSP
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added CSP to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    03/08/11  MLB  CPC
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added CPC to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Nicholas & Co.
     *
NCH A*    05/17/11  MLB  NCH
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added NCH to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Avalon Foodservice
     *
AVL A*    10/13/11  MLB  AVL
     *      - Revised program to only delete records from SLOTDGT,
     *        SLOTDGTA that are found in table AVASLOT.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICB A*    02/01/12  MLB  ICB
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Agar Supply Co.
     *
ASC A*    03/26/12  MLB  ASC
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Grave's Menu Maker
     *
GMM A*    03/26/12  MLB  GMM
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    04/06/12  MLB  HMW
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    12/21/12  MLB  HKW
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Stern Produce
     *
SPI A*    12/07/12  MLB  SPI
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added SPI to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Reinhart Foodservice
     *
RFS A*    01/04/13  MLB  RFS
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added RFS to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*    02/15/13  MLB  GLP
     *      - Revised program to not delete records from SLOTDGT
     *        and SLOTDGTA files. Added GLP to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Williams Foods
     *
WIF A*    04/30/14  MLB  WIF
     *      - Revised program to not delete records from SLOTDGT
     *        and SLOTDGTA files. Added WIF to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHL A*    07/17/14  MLB  KHL
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFC A*    09/04/14  MLB  PFC
     *      - Revised program to not delete records from SLOTDGT
     *        and SLOTDGTA files. Added PFC to GSC1 mod.
     *
     *----------------------------------------------------------------
     *
CWD A*    04/23/13  MLB  CWD
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added CWD to GSC1 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    01/11/17  MLB  CBI
     *      - Revised program to not delete records from SLOTDGT
     *        file. Added CBI to GSC1 mod.
     *
     *----------------------------------------------------------------

500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*----------------------------------------------------------------
500aA
DRY AD/copy qcopysrc,id#dairyla
GSC AD/copy qcopysrc,id#gsc
ELL AD/copy qcopysrc,id#ellenbe
SGC AD/copy qcopysrc,id#sgc
CDI AD/copy qcopysrc,id#cdi
IFD AD/copy qcopysrc,id#ifd
SOF AD/copy qcopysrc,id#sofo
SVL AD/copy qcopysrc,id#saval
MAT AD/copy qcopysrc,id#matt
FFC AD/copy qcopysrc,id#fischer
CCP AD/copy qcopysrc,id#capitol
CSP AD/copy qcopysrc,id#coastal
CPC AD/copy qcopysrc,id#cpc
NCH AD/copy qcopysrc,id#nichola
AVL AD/copy qcopysrc,id#avalon
ICB AD/copy qcopysrc,id#icb
ASC AD/copy qcopysrc,id#agar
GMM AD/copy qcopysrc,id#gmm
HMW AD/copy qcopysrc,id#hmwagne
HKW AD/copy qcopysrc,id#hkw
SPI AD/copy qcopysrc,id#spi
HAL AD/copy qcopysrc,id#halsey
RFS AD/copy qcopysrc,id#rfs
CWD AD/copy qcopysrc,id#cashwa
GLP AD/copy qcopysrc,id#glp
WIF AD/copy qcopysrc,id#wif
KHL AD/copy qcopysrc,id#khl
PFC AD/copy qcopysrc,id#pfc
CBI AD/copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

     D/copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D curdate         s              8  0
     D curtime         s              6  0
     D currstamp       s               z
     D currdts         s             26a

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *      $PWHSE  Warehouse
     *
     *    Returned Parameters
     *
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C*    *entry        plist
     C*                  parm                    $pwhse           15 5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
500aA
500aA* Get client id.
500aA
500aAC                   call      'GETCLIENT'
500aAC                   parm                    client           10
500aA

     *  Get current date and time.

     C                   time                    curtime
     C                   time                    currstamp
     C                   move      currstamp     currdts
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o

     *  Delete virtual slots.

500bDC*/EXEC SQL
500bDC*+   delete from slot
500bDC*+   where slwhse = 001     and slrsrv = 'V'
500bDC*/END-EXEC
500bDC*                  if        sqlstt <> '00000'
500bDC*                  endif

     C/EXEC SQL
     C+   delete from vslot
     C+   where vswhse = 001
600aAC+         and vsaisl<>'RCV'
600aAC+         and vsaisl<>'STG'
HAL AC+         OR vswhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Clear remaining physical slots.
500bA
500bA*  Delete all remaining slots.
500bAC/EXEC SQL
500bAC+   delete from slot
500bAC+   where slwhse = 001
600aAC+         and slaisl<>'RCV'
600aAC+         and slaisl<>'STG'
HAL AC+         OR slwhse = 001
500bAC/END-EXEC
500bAC                   if        sqlstt <> '00000'
500bAC                   endif
500bA

500bDC*/EXEC SQL
500bDC*+   update slot
500bDC*+   set slitem=' ',
500bDC*+       slstk1=0, slstk2=0, slstk3=0,
500bDC*+       slalc1=0, slalc2=0, slalc3=0,
500bDC*+       slpck1=0, slpck2=0, slpck3=0,
500bDC*+       slrcv1=0, slrcv2=0, slrcv3=0,
500bDC*+       sltfr1=0, sltfr2=0, sltfr3=0,
500bDC*+       slentd=0, slexpd=0, slprty=0
500bDC*+   where slwhse = 001
500bDC*/END-EXEC
500bDC*                  if        sqlstt <> '00000'
500bDC*                  endif
500bDC*                  endif
500bA
500bA*  Delete all Slot Check Digits.
GSC AC                   if        client <> GSC
ELL AC                             and client <> Ellenbe
SGC AC                             and client <> SGC
CDI AC                             and client <> CDI
IFD AC                             and client <> IFD
SOF AC                             and client <> SoFoFoods
SVL AC                             and client <> SavalFoods
DRY AC                             and client <> Dairyland
MAT AC                             and client <> Mattfoods
FFC AC                             and client <> FischerFoods
CCP AC                             and client <> CapitolCity
CSP AC                             and client <> CoastalSunbelt
CPC AC                             and client <> CPC
NCH AC                             and client <> Nicholas
ICB AC                             and client <> ICB
ASC AC                             and client <> Agar
GMM AC                             and client <> Menumaker
HMW AC                             and client <> HMWagner
HKW AC                             and client <> Hearnkirkwood
SPI AC                             and client <> Sternproduce
RFS AC                             and client <> RFS
CWD AC                             and client <> Cashwa
GLP AC                             and client <> Greenleaf
WIF AC                             and client <> Williamsfoods
KHL AC                             and client <> Kohlwholesale
PFC AC                             and client <> Prestofoods
CBI AC                             and client <> Cheney
AVL AC
AVL AC                   if        client = Avalon
AVL A*  Only clear check digits for entries in AVASLOT table.
AVL AC/EXEC SQL
AVL AC+   delete from slotdgt scd
AVL AC+   where exists
AVL AC+     (select scd.scdwhs, scd.scdwhd, ava.avawhs, ava.avaprfx
AVL AC+      from avaslot ava
AVL AC+   where scd.scdwhs = 001 and scd.scdwhs = ava.avawhs
AVL AC+     and scd.scdwhd = ava.avaprfx)
AVL AC/END-EXEC
AVL AC                   if        sqlstt <> '00000'
AVL AC                   endif
AVL AC/EXEC SQL
AVL AC+   delete from slotdgta sca
AVL AC+   where exists
AVL AC+     (select sca.scdwhsa, sca.scdwhda, ava.avawhs, ava.avaprfx
AVL AC+      from avaslot ava
AVL AC+   where sca.scdwhsa = 001 and sca.scdwhsa = ava.avawhs
AVL AC+     and sca.scdwhda = ava.avaprfx)
AVL AC/END-EXEC
AVL AC                   if        sqlstt <> '00000'
AVL AC                   endif
AVL A
AVL AC                   else
AVL A*  Clear slot check digits for all other clients.
AVL AC
500bAC/EXEC SQL
500bAC+   delete from slotdgt
500bAC+   where scdwhs = 001
500bAC/END-EXEC
500bAC                   if        sqlstt <> '00000'
500bAC                   endif
530 AC/EXEC SQL
530 AC+   delete from slotdgta
530 AC+   where scdwhsa = 001
530 AC/END-EXEC
530 AC                   if        sqlstt <> '00000'
530 AC                   endif
GSC A
AVL AC                   endif
AVL AC
GSC AC                   endif
500bA

     *  Clear item quantity file.

     C/EXEC SQL
     C+   update itemqty
     C+   set iqstk1=0, iqstk2=0, iqstk3=0,
     C+       iqalc1=0, iqalc2=0, iqalc3=0,
     C+       iqhld1=0, iqhld2=0, iqhld3=0,
     C+       iqtri1=0, iqtri2=0, iqtri3=0,
     C+       iqtro1=0, iqtro2=0, iqtro3=0
     C+   where iqwhse = 001
     C/END-EXEC
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on
     C                   return
