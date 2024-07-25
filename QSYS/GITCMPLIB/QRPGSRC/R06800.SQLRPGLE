      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR06800      GUI Truck Map - retrieve SW/SP from ordh
     *  07 July 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    07/07/15  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pRtid       Route Id
     *      pPlid       Pallet Id
     *      pTruk       Truck
     *      pComp       Compartment
     *      pTrn#       Transaction#
     *      pStop1      First Stop
     *      pStop2      Last Stop
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fworklbl5  if   e           k disk
     Flabel33   if   e           k disk
     Ftruckh    if   e           k disk
     Fordh      if   e           k disk
     Foptionz   if   e           k disk
     frtecsum   if   e           k disk
     fdocmtrx2  if   e           k disk
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
CBIaA /COPY QCOPYSRC,ID#CHENEY

CBIaA*----------------------------------------------------------------
CBIaA*  Redefinition data struction for OHMISC field.
CBIaA*
CBIaAD                 ds
CBIaAD  dsmisc                 1     20
CBIaAD  dssdte                 1      8
CBIaAD  dsspcl                 9     11
CBIaAD  dsrpck                12     12
CBIaAD  dxdoor                13     14
CBIaAD  dsmeat                15     15
CBIaAD  dscode                16     16
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D psession        s             40
     D pWhse           s              3p 0
     D prtid           s              5
     D pplid           s              7p 0
     D ptruk           s             10
     D pcomp           s              1
     D ptrn#           s              7p 0
     D pstop1          s              2s 0
     D pstop2          s              2s 0
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10


     D SPSW            s              2
     D pos             s              5U 0
     D kyzone          s              6
     D kycode          s              8
     D $ptmpl          s             10
     D dkdoor          s              3
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = Descending by stop then location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPSTOP  -  Prevent *SP flag (Y=Yes, N=No).
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opstop                61     61
     D  opdend               117    117
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSession
     c                   parm                    pWhse
     c                   parm                    prtid
     c                   parm                    pplid
     c                   parm                    ptruk
     c                   parm                    pcomp
     c                   parm                    ptrn#
     c                   parm                    pstop1
     c                   parm                    pstop2
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        kyzone = *blanks;

        if pstop1 = pstop2
         or pstop1 > 0 and pstop2 = 0;

          // First, try and find order header using WORKLBL file.
          chain (pwhse: prtid: pplid) worklbl5;
          if %found(worklbl5);
            chain (lwwhse: lword) ordh;
            if %found(ordh);
              kyzone = lwszon;
              exsr zzcsp1;
            endif;
          else;
            // If it couldn't be found, then try using LABEL33 file.
            chain (pwhse: prtid: ptrn#: pstop1) label33;
            if %found(label33);
              kyzone = psszon;
            else;
            endif;
          endif;
        endif;

        if pstop1 > 0;
          // Get dock door if assigned
          dkdoor = ' ';
          chain (pwhse: prtid: pcomp) rtecsum;
          if %found(rtecsum);
            Select;
              // assigned by dept
              when rcdrdp <> ' ';
                chain (pwhse: prtid: rcdrdp) docmtrx2;
              // assigned single door
              when rcdrdp = ' ';
                chain (pwhse: prtid) docmtrx2;
            endsl;
            if %found(docmtrx2);
              dkdoor = %char(dmdoor);
            endif;
          endif;
        endif;

         pOutStr = '{'
                +  '"DOOR":"'  + %trimr(dkdoor) + '",'
                +  '"SPSW":"'  + %trimr(SpSw) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free


     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCSP1   Check for single pallet stops.
     *
     C     zzcsp1        begsr
     *
     *   Found header record. Now check for *SP.
     *
      /free
        pos = %scan ('*SP' : ohmisc);
        if pos > 0;
CBIaA     if client = cheney;
CBIaA       dsmisc = ohmisc;
CBIaA       spsw   = dscode;
CBIaA     else;
            spsw = 'SP';
CBIaA     endif;
        else;
          spsw =  ' ';
        endif;
      /end-free
     *
     *    Get truck information.
     *
      /free
        chain (pwhse: ptruk) truckh;
        if %found(truckh) and thtype = 'T';
          $ptmpl = thztmp;
        else;
          $ptmpl = pstruk;
        endif;
      /end-free
     *
     *   Clear *SP flag if the ignore flag is on.
     *
      /free
        kycode = '*PICK';
        chain (kycode: pwhse: $ptmpl: kyzone) optionz;
        if %found(optionz) and opstop = 'Y';
          spsw = *blank;
        endif;
      /end-free
     C                   endsr
