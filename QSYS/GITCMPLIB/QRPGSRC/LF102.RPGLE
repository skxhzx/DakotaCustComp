     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LF102     Create 'PLBL40' label format
     *  Dave Sommerville
     *
     *  Revisions
     *
414 A*    04/11/00  DAS  4.14
     *      - Created.
     *
500 A*    04/27/06  DAS  5.00
     *      - Coverted to ILE
     *      - Added more formats.
     *
510 A*    10/07/06  DAS  5.10
     *      - Added more formats.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     FLblfmth   uf a e           k disk
     FLblfmtd   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *    Single Label
     *
     D lbl2            s             58    dim(13)
     *
     *    Description
     *
     D dsc             s             30    dim(1) ctdata perrcd(1)
     *
     *    Label Definitions
     *
     D begblk          s             58    dim(14) ctdata perrcd(1)
     D begrpl          s             58    dim(14) ctdata perrcd(1)
     D bulk            s             58    dim(14) ctdata perrcd(1)
     D cachwt          s             58    dim(14) ctdata perrcd(1)
     D cmbb            s             58    dim(14) ctdata perrcd(1)
     D cmba            s             58    dim(14) ctdata perrcd(1)
     D discrp          s             58    dim(14) ctdata perrcd(1)
     D pick            s             58    dim(14) ctdata perrcd(1)
     D zonsum          s             58    dim(14) ctdata perrcd(1)
     D repl1           s             58    dim(14) ctdata perrcd(1)
     D repl2           s             58    dim(14) ctdata perrcd(1)
     D sethd           s             58    dim(14) ctdata perrcd(1)
     D setsum          s             58    dim(14) ctdata perrcd(1)
     D umb             s             58    dim(14) ctdata perrcd(1)
     D uma             s             58    dim(14) ctdata perrcd(1)
     D zonhed          s             58    dim(14) ctdata perrcd(1)
     D xdkb            s             58    dim(14) ctdata perrcd(1)
500 AD aislchg         s             58    dim(14) ctdata perrcd(1)
500 AD begtote         s             58    dim(14) ctdata perrcd(1)
500 AD blktran         s             58    dim(14) ctdata perrcd(1)
500 AD brkdowns        s             58    dim(14) ctdata perrcd(1)
500 AD bulkrepk        s             58    dim(14) ctdata perrcd(1)
500 AD clamtag         s             58    dim(14) ctdata perrcd(1)
500 AD endtote         s             58    dim(14) ctdata perrcd(1)
500 AD repack          s             58    dim(14) ctdata perrcd(1)
500 AD sethedal        s             58    dim(14) ctdata perrcd(1)
500 AD sethedcl        s             58    dim(14) ctdata perrcd(1)
500 AD sethedhb        s             58    dim(14) ctdata perrcd(1)
500 AD sethedsf        s             58    dim(14) ctdata perrcd(1)
500 AD totecnt         s             58    dim(14) ctdata perrcd(1)
500 AD wlbulkal        s             58    dim(14) ctdata perrcd(1)
500 AD wlpickal        s             58    dim(14) ctdata perrcd(1)
510 AD pirpick         s             58    dim(14) ctdata perrcd(1)
510 AD pirmerge        s             58    dim(14) ctdata perrcd(1)
510 AD pirmerg2        s             58    dim(14) ctdata perrcd(1)
     *
     *    Variables
     *
     D forevr          s              1
     D kyset           s                   like(lfhset)
     D x               s              3  0
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      forevr = *on
     *
     *  Define key
     *
     *    Define key for LBLFMTH file.
     *
     C     keylfh        klist
     C                   kfld                    kyset
     C                   eval      kyset = 'PLBL40'
     *
     *  Delete existing definition
     *
     *    Header
     *
     C     keylfh        setll     lblfmth
     C                   dow       forevr = forevr
     C     keylfh        reade     lblfmth                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    lfhrec
     C                   enddo
     *
     *    Detail
     *
     C     keylfh        setll     lblfmtd
     C                   dow       forevr = forevr
     C     keylfh        reade     lblfmtd                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    lfdrec
     C                   enddo
     *
     *  Create PLBL40 definition
     *
     *    Header
     *
     C                   eval      lfhset = kyset
     C                   eval      lfhdsc = dsc(1)
     C                   eval      lfhslg = *blanks
     C                   movel     'TEXT'        lfhslg
     C                   eval      lfhlbw = 58
     C                   eval      lfhlbh = 12
     C                   write     lfhrec
     *
     *    Detail
     *
     C                   eval      lfdset = kyset
     *
     C                   eval      lfdfmt = 'BEGBLK  '
     C                   movea     begblk(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'BEGRPL  '
     C                   movea     begrpl(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'BULK    '
     C                   movea     bulk(2)       lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'CACHWT  '
     C                   movea     cachwt(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'CMBB    '
     C                   movea     cmbb(2)       lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'CMBA    '
     C                   movea     cmba(2)       lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'DISCRP  '
     C                   movea     discrp(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'PICK    '
     C                   movea     pick(2)       lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'ZONPKUP '
     C                   movea     zonsum(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'REPL1   '
     C                   movea     repl1(2)      lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'REPL2   '
     C                   movea     repl2(2)      lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'SETHED  '
     C                   movea     sethd(2)      lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'SETSUM  '
     C                   movea     setsum(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'UMA     '
     C                   movea     uma(2)        lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'UMB     '
     C                   movea     umb(2)        lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'ZONHED  '
     C                   movea     zonhed(2)     lbl2
     C                   exsr      writit
     *
     C                   eval      lfdfmt = 'XDKB    '
     C                   movea     xdkb(2)       lbl2
     C                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'AISLCHG'
500 AC                   movea     aislchg(2)    lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'BEGTOTE'
500 AC                   movea     begtote(2)    lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'BLKTRAN'
500 AC                   movea     blktran(2)    lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'BRKDOWNS'
500 AC                   movea     brkdowns(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'BULKREPK'
500 AC                   movea     bulkrepk(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'CLAMTAG'
500 AC                   movea     clamtag(2)    lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'ENDTOTE'
500 AC                   movea     endtote(2)    lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'REPACK'
500 AC                   movea     repack(2)     lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'SETHEDAL'
500 AC                   movea     sethedal(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'SETHEDCL'
500 AC                   movea     sethedcl(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'SETHEDHB'
500 AC                   movea     sethedhb(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'SETHEDSF'
500 AC                   movea     sethedsf(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'TOTECNT'
500 AC                   movea     totecnt(2)    lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'WLBULKAL'
500 AC                   movea     wlbulkal(2)   lbl2
500 AC                   exsr      writit
     *
500 AC                   eval      lfdfmt = 'WLPICKAL'
500 AC                   movea     wlpickal(2)   lbl2
500 AC                   exsr      writit
     *
510 AC                   eval      lfdfmt = 'PIRPICK'
510 AC                   movea     pirpick(2)    lbl2
510 AC                   exsr      writit
     *
510 AC                   eval      lfdfmt = 'PIRMERGE'
510 AC                   movea     pirmerge(2)   lbl2
510 AC                   exsr      writit
     *
510 AC                   eval      lfdfmt = 'PIRMERG2'
510 AC                   movea     pirmerg2(2)   lbl2
510 AC                   exsr      writit
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  WRITIT  Write label
     *
     C     writit        begsr
     C     1             do        13            x
     C                   eval      lfdseq = x
     C                   movel     lbl2(x)       lfdstr
     C                   write     lfdrec
     C                   enddo
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**   DSC - Description                                                 s label #
PLBL40 table formats
**   BEGBLK
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
BEGBLK
                                                         .
                                                         .
*********************************************************.
                       Bulk Picks                        .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   BEGRPL                                              .
02- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
BEGRPL                                              .
                                                         .
                                                         .
*********************************************************.
                        Letdowns                         .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   BULK                                                .
03- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
BULK                                                .
<11-------->          <12->   <13->         Tran# <10--->.
        (BULK)      <14--->           <82-----> <82----->.
         <15----------->              <82-----> <82----->.
<16-------------------------->        <82-----> <82----->.
                                      <82-----> <82----->.
<17-----------> Order <18--->         <82-----> <82----->.
      Customer <19------>             <82-----> <82----->.
          <20->    <21------>         <82-----> <82----->.
<22-------------------------------->  <82-----> <82----->.
<23-------------------------------->  <82-----> <82----->.
<24---------------->  <1> <25--> Rte: <43->   Pal#<26--->.
                                                         .
**   CACHWT                                              .
04- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
CACHWT                                              .
-------------- Catch Weights -------------- Tran# <10--->.
Item <17-----------> <16---------------------> <15------>.
 Item               Weight                               .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   CMBB                                                .
05- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
CMBB                                                .
<11-------->                                Tran# <10--->.
Item <17-----------> <16---------------------> <15------>.
                                                         .
                                                         .
                                                      *  .
                                                       * .
                 COMBINED LABLE IS NEXT          ********.
                                                       * .
                                                      *  .
                                                         .
                                                         .
                                                         .
**   CMBA                                                .
06- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
CMBA                                                .
<11-------->                                Tran# <10--->.
Item <17-----------> <16---------------------> <15------>.
                                                         .
                                                         .
  *                                                      .
 *                                                       .
********         COMBINED LABLE IS BEFORE                .
 *                                                       .
  *                                                      .
                                                         .
                                                         .
                                                         .
**   DISCRP                                              .
07- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
DISCRP                                              .
-------------- Discrepancies -------------- Tran# <10--->.
                                                         .
 Slot         Item           Qty Picked                  .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   PICK                                                .
09- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
PICK                                                .
<11-------->  <32-><33><12->  <13->         Tran# <10--->.
        <34--->   <45>                <82-----> <82----->.
        <15----------->               <82-----> <82----->.
<16-------------------------->        <82-----> <82----->.
                                      <82-----> <82----->.
<17-----------> Order <18--->         <82-----> <82----->.
      Customer <19------>             <82-----> <82----->.
          <20->    <21------>         <82-----> <82----->.
<22-------------------------------->  <82-----> <82----->.
<23-------------------------------->  <82-----> <82----->.
<24--------------> <1> <25--> Rte: <43-> Pal#<26---><105>.
                                                         .
**   ZONPKH (Lines 1,2), ZONPKD (Line 3)                 .
10- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
ZONPKUP                                             .
------------------ Zone Pickup: <41--> ---- Tran# <40--->.
 Stop Pieces Item                                    Pal#.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
 <36> <37->  <38---------------------------------><39--->.
                                                         .
**   REPL1                                               .
11- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
REPL1                                               .
                                            Tran# <10--->.
                                                         .
                                                         .
From: <11-------->              To: <42-------->         .
                                                         .
Qty: <32-><33><12->  <13->    Tie/High: <14--->          .
                                                         .
Item: <17------------> <15----------->                   .
<16-------------------------->                           .
                                                         .
                                                         .
                                                         .
**   REPL2                                               .
12- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
REPL2                                               .
                                            Tran# <10--->.
                                                         .
                                                         .
From: <11-------->              To: <42-------->         .
                                                         .
Qty: <32-><33><12->  <13->    Qty: <51--> <52->          .
                                                         .
Item: <53------------>          Item: <54------------>   .
<55-------------------------->  <56--------------------->.
                                                         .
                                                         .
                                                         .
**   SETHD                                               .
13- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
SETHED                                              .
                                            Tran# <10--->.
                                                         .
   Warehouse  : <2>                                      .
   Route      : <43->                                    .
   Compartment: <3>                                      .
   Zone       : <35-->                                   .
   Type       : <44->                                    .
                                                         .
    Pallet    Stops    Pieces     Cube     Weight        .
    <27--->   <28>     <29->   <30--->    <31--->        .
    <27--->   <28>     <29->   <30--->    <31--->        .
                                                         .
**   SETSUH (Lines 1,2), SETSUD/SETSUT (Line 3), SETSUL (Line 4)
14- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
SETSUM
--------------------- Set Summary --------- Tran# <40--->.
 Stop Pieces   Cube   Weight Customer                    .
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
 <46> <47-> <48---> <49----> <50------------------------>.
                                                         .
**   UMB                                                 .
15- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
UMB                                                 .
<11-------->                                Tran# <10--->.
Item <17-----------> <16---------------------> <15------>.
                                                         .
                                                         .
                                                      *  .
                                                       * .
             UNIT OF MEASURE CHANGE IS NEXT      ********.
                                                       * .
                                                      *  .
                                                         .
                                                         .
                                                         .
**   UMA                                                 .
16- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
UMA                                                 .
<11-------->                                Tran# <10--->.
Item <17-----------> <16---------------------> <15------>.
                                                         .
                                                         .
  *                                                      .
 *                                                       .
********     UNIT OF MEASURE CHANGE IS BEFORE            .
 *                                                       .
  *                                                      .
                                                         .
                                                         .
                                                         .
**   ZONHED                                              .
17- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
ZONHED                                              .
*********************************************************.
*********************************************************.
                                                         .
   Warehouse  : <2>                                      .
   Route      : <43->                                    .
   Compartment: <3>                                      .
   Zone       : <35-->                                   .
                                                         .
                                                         .
*********************************************************.
*********************************************************.
                                                         .
**   XDKB                                                .
18- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
XDKB                                                .
                                                         .
                                                         .
                                                         .
                                                      *  .
                                                       * .
                CROSSDOCK LABELS ARE NEXT        ********.
                                                       * .
                                                      *  .
                                                         .
                                                         .
                                                         .
                                                         .
**   AISLECHG
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
AISLECHG
                                                         .
                                                         .
*********************************************************.
                   Aisle Change                          .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   BEGTOTE
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
BEGTOTE
*********************************************************.
                   Begin Tote                            .
*********************************************************.
  Tran#     10: <10XXX>                                  .
  Stop       0: <0>                                      .
  Cust#     19: <19XXXXXX>                               .
  Cust Name 22: <22XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX> .
  Order#    18: <18XXX>                                  .
  Pallet#   26: <26XXX>   4: <4>                         .
  Route     42: <43XX>                                   .
  SZone      6: <6XXX>                                   .
  x of y     7: <7XXXXX>                                 .
**   BLKTRAN
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
BLKTRAN
                                                         .
                                                         .
*********************************************************.
                   Bulk Pick Transaction                 .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   BRKDOWNS
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
BRKDOWNS
                                                         .
                                                         .
*********************************************************.
                 Breakdown Replenishments                .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   BULKREPK
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
BULKREPK
                                                         .
                                                         .
*********************************************************.
                Bulk Repack Label for Harbor             .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   CLAMTAG
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
CLAMTAG
                                                         .
                                                         .
*********************************************************.
                Clam Tag                                 .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   ENDTOTE
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
ENDTOTE
*********************************************************.
                   End Tote                              .
*********************************************************.
  Tran#     10: <10XXX>                                  .
  Stop       0: <0>                                      .
  Cust#     19: <19XXXXXX>                               .
  Cust Name 22: <22XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX> .
  Order#    18: <18XXX>                                  .
  Pallet#   26: <26XXX>   4: <4>                         .
  Route     42: <43XX>                                   .
  SZone      6: <6XXX>                                   .
  x of y     7: <7XXXXX>                                 .
**   REPACK
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
REPACK
                                                         .
                                                         .
*********************************************************.
                Repack Label for Harbor                  .
*********************************************************.
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
                                                         .
**   SETHDAL                                             .
13- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
SETHEDAL                                            .
                                            Tran# <10--->.
                                                         .
   Warehouse  : <2>                                      .
   Route      : <43->                                    .
   Compartment: <3>                                      .
   Zone       : <35-->                                   .
   Type       : <44->                                    .
                                                         .
    Pallet    Stops    Pieces     Cube     Weight        .
    <27--->   <28>     <29->   <30--->    <31--->        .
    <27--->   <28>     <29->   <30--->    <31--->        .
                                                         .
**   SETHDCL                                             .
13- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
SETHEDCL                                            .
                                            Tran# <10--->.
                                                         .
   Warehouse  : <2>                                      .
   Route      : <43->                                    .
   Compartment: <3>                                      .
   Zone       : <35-->                                   .
   Type       : <44->                                    .
                                                         .
    Pallet    Stops    Pieces     Cube     Weight        .
    <27--->   <28>     <29->   <30--->    <31--->        .
    <27--->   <28>     <29->   <30--->    <31--->        .
                                                         .
**   SETHDHB                                             .
13- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
SETHEDHB                                            .
                                            Tran# <10--->.
                                                         .
   Warehouse  : <2>                                      .
   Route      : <43->                                    .
   Compartment: <3>                                      .
   Zone       : <35-->                                   .
   Type       : <44->                                    .
                                                         .
    Pallet    Stops    Pieces     Cube     Weight        .
    <27--->   <28>     <29->   <30--->    <31--->        .
    <27--->   <28>     <29->   <30--->    <31--->        .
                                                         .
**   SETHDSF                                             .
13- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
SETHEDSF                                            .
                                            Tran# <10--->.
                                                         .
   Warehouse  : <2>                                      .
   Route      : <43->                                    .
   Compartment: <3>                                      .
   Zone       : <35-->                                   .
   Type       : <44->                                    .
                                                         .
    Pallet    Stops    Pieces     Cube     Weight        .
    <27--->   <28>     <29->   <30--->    <31--->        .
    <27--->   <28>     <29->   <30--->    <31--->        .
                                                         .
**   TOTECNT
01- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + -.
TOTECNT
*********************************************************.
                   Tote Count                            .
*********************************************************.
  Tran#     10: <10XXX>                                  .
  Stop       0: <0>                                      .
  Cust#     19: <19XXXXXX>                               .
  Cust Name 22: <22XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX> .
  Order#    18: <18XXX>                                  .
  Pallet#   26: <26XXX>   4: <4>                         .
  Route     42: <43XX>                                   .
  SZone      6: <6XXX>                                   .
  x of y     7: <7XXXXX>                                 .
**   WLBULKAL                                            .
03- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
WLBULKAL                                            .
<11-------->          <12->   <13->         Tran# <10--->.
        (BULK)      <14--->           <82-----> <82----->.
         <15----------->              <82-----> <82----->.
<16-------------------------->        <82-----> <82----->.
                                      <82-----> <82----->.
<17-----------> Order <18--->         <82-----> <82----->.
      Customer <19------>             <82-----> <82----->.
          <20->    <21------>         <82-----> <82----->.
<22-------------------------------->  <82-----> <82----->.
<23-------------------------------->  <82-----> <82----->.
<24---------------->  <1> <25--> Rte: <43->   Pal#<26--->.
                                                         .
**   WLPICKAL                                            .
09- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
WLPICKAL                                            .
<11-------->  <32-><33><12->  <13->         Tran# <10--->.
        <34--->   <45>                <82-----> <82----->.
        <15----------->               <82-----> <82----->.
<16-------------------------->        <82-----> <82----->.
                                      <82-----> <82----->.
<17-----------> Order <18--->         <82-----> <82----->.
      Customer <19------>             <82-----> <82----->.
          <20->    <21------>         <82-----> <82----->.
<22-------------------------------->  <82-----> <82----->.
<23-------------------------------->  <82-----> <82----->.
<24---------------->  <1> <25--> Rte: <43->   Pal#<26--->.
                                                         .
**   PIRPICK                                             .
09- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
PIRPICK                                                  .
<11-------->  <32-><33><12->  <13->         Tran# <10--->.
        <34--->   <45>                <82-----> <82----->.
        <15----------->               <82-----> <82----->.
<16-------------------------->        <82-----> <82----->.
PIR Seq# <154> Lbl# <57--->           <82-----> <82----->.
<17-----------> Order <18--->         <82-----> <82----->.
      Customer <19------>             <82-----> <82----->.
          <20->    <21------>         <82-----> <82----->.
<22-------------------------------->  <82-----> <82----->.
<23-------------------------------->  <82-----> <82----->.
<24--------------> <1> <25--> Rte: <43-> Pal#<26---><105>.
                                                         .
**   PIRMERGE                                            .
09- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
PIRMERGE                                                 .
                                            Tran# <10--->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
PIR Seq# <155>                        <82-----> <82----->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
Lbl# <156-->                          <82-----> <82----->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
                              Rte: <43-> Pal#<26---><105>.
                                                         .
**   PIRMERG2                                            .
09- + -- 1 -- + -- 2 -- + -- 3 -- + -- 4 -- + -- 5 -- + --
PIRMERG2                                                 .
                                            Tran# <10--->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
PIR Seq# <155>                        <82-----> <82----->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
Lbl# <156-->                          <82-----> <82----->.
                                      <82-----> <82----->.
                                      <82-----> <82----->.
                              Rte: <43-> Pal#<26---><105>.
                                                         .
