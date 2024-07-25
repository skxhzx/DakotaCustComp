500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RN910     Clean Up of RTN slots hung up (RCV, STG, USR)
     *  17 October, 2018
     *  Nancy Koelz
     *
     *  Notes
CBIa *       Screen to enter Date and Aisle - Add to menu
     *
     *  First ran 05.12.18 manually as FXRTN
     *
     *  Read Slot11 to find all RTN slots;
     *  sdte<today, stat=A, qty>0.
     *  This qty to be moved to the picking slot (slot3).
     *  Call UT812 to recalc this item.
     *  LicActive - update lic# with picking slot
     *  Report - to use and inventory slots
     *
     *  Second run 08.22.18, due to PT132 change by Tom.
     *  Read Slot11 to find all RTN slots;
     *  these hung up/no licactive from program bug.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
CBIa *    10/17/18  NLK  CBI.a
     *      - Mark's req to run date of 10.09.18 for clean up of RTN
     *      - Added DDS to allow them to enter date & aisle for clean up
     *        Was FXRTN now RN910 to automate
     *----------------------------------------------------------------
CBIaAFrn910fm   cf   e             workstn
     Fslot11    uf   e           k disk
     Fslot3     uf   e           k disk    prefix(y_) rename(slrec:slrec3)
     Flicactive1uf   e           k disk
     Fqsysprt   O    F  132        PRINTER
     *----------------------------------------------------------------
      /copy qcopysrc,p.cvtdte

CBIa D error           s              1
     D forever         s               n
     D hstk1           s              5  0
     D hstk2           s              3  0
     D hstk3           s              3  0
     D pgcnt           s              3  0
     D today           s              8  0
CBIaMD w1dtex          s              8  0 inz(20181009)
     D w1whse          s              3  0 inz(001)
     D w1aisl          s              3
     D w1stat          s              1    inz('A')
     D w1pick          s              1    inz('Y')
     D $lwhse          s             15  5
     D $litem          s             15
     D $ljobq          s              1
     D $lprg           s             10
     D $lrtn           s              8
     D $lmsg           s              4
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D UT812           pr                  extpgm('UT812')
     D   ppwhse                      15  5
     D   ppitem                      15
     D   ppjobq                       1
     D   ppprg                       10
     D   pprtn                        8
     D   ppmsg                        4
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
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

      *----------------------------------------------------------------
      /free
         // Retrieve today's date into century format

         $cvcmd = '*CURCMD ';
         cvtdte ($cvtdt);
         today = $cvd8o;
CBIa     if not %open(rn910fm);
CBIa     open rn910fm;
CBIa     endif;
CBIa     if not %open(qsysprt);
CBIa     open qsysprt;
CBIa     endif;

         // w1dte = today;
CBIa     // w1dte = now from screen;
CBIa     // w1aisl = 'RTN';

CBIa           exsr dspscr;

         // slot11 to read USR ONLY
         except header;
         setll (w1whse:w1aisl) slot11;
         dow  forever = forever;
           reade (w1whse:w1aisl) slot11;

           if not %eof(slot11)
              and slstat = 'A' and slentd < w1dte;
         // clean up this slot and transfer the qty
             hstk1 = slstk1;
             hstk2 = slstk2;
             hstk3 = slstk3;
             slstk1 = 0;
             slstk2 = 0;
             slstk3 = 0;
             slstat = 'Z';
             update slrec;
         // if USR had no qty, then let it go to 'Z' status, skip others
             if hstk1 > 0 or hstk2 > 0 or hstk3 > 0;
               exsr getpicksl;
               exsr getlicact;
               exsr zzut812;
               exsr print;
             endif;
           endif;

           if %eof(slot11);
             leave;
           endif;

         enddo;
CBIa     if %open(qsysprt);
CBIa     close qsysprt;
CBIa     endif;
CBIa     if %open(rn910fm);
CBIa     close rn910fm;
CBIa     endif;
         return;
      /end-free

CBIa *----------------------------------------------------------------
CBIa *  DSPSCR - Display screen
CBIa *----------------------------------------------------------------
CBIa  /free
CBIa   begsr dspscr;
CBIa
CBIa           exfmt screen1;
CBIa
CBIa           eval *in03 = *off;
CBIa           eval error = *off;
CBIa
CBIa   endsr;
CBIa  /end-free

     *----------------------------------------------------------------
     *  getpicksl - get Picking Slot to update qty
     *----------------------------------------------------------------

      /free
       begsr getpicksl;

             setll (w1whse:slitem:w1stat:w1pick) slot3;
             reade (w1whse:slitem:w1stat:w1pick) slot3;
             if not %eof(slot3);
               eval y_slstk1 += hstk1;
               eval y_slstk2 += hstk2;
               eval y_slstk3 += hstk3;
               update slrec3;
               else;
               y_slstk1 = 0;
               y_slstk2 = 0;
               y_slstk3 = 0;
               y_slwhdp = ' ';
               y_sldisp = ' ';
               y_slaisl = ' ';
               y_slloc = 0;
               y_slrlvl = 0;
               y_slhand = ' ';
               y_sldisp = ' ';
             endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  getlicact - get LicActive and update SLOT field
     *----------------------------------------------------------------

      /free
       begsr getlicact;

             setll (w1whse:slwhdp:sldisp:slitem) licactive1;
             reade (w1whse:slwhdp:sldisp:slitem) licactive1;
             dow not %eof(licactive1);
             if y_sldisp <> *blanks;
               lacode = 'S';
               laarea = 'Slot';
               lawhdp = y_slwhdp;
               ladisp = y_sldisp;
               laaisl = y_slaisl;
               laloc  = y_slloc;
               larlvl = y_slrlvl;
               lahand = y_slhand;
               labase = y_sldisp;
               update larec;
             else;
               delete larec;
             endif;
             reade (w1whse:slwhdp:sldisp:slitem) licactive1;
             enddo;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzut812 - call UT812 to recalc slot quantities
     *----------------------------------------------------------------

      /free
       begsr zzut812;
            $lwhse = w1whse;
            $litem = slitem;
            $ljobq = 'N';
            $lprg = 'RN910';
            UT812 ($lwhse : $litem : $ljobq : $lprg: $lrtn : $lmsg);
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  Print - Print detail report
     *----------------------------------------------------------------

      /free
       begsr Print;

             if pgcnt > 50;
               except header;
               pgcnt = 0;
             endif;

             except dtllin;
             pgcnt += 1;

       endsr;
      /end-free

     OQSYSPRT   E            Header         2  2
     O                       UDATE         Y      8
     O                                           50 'Open Tran Clean Up'
     O                                           75 'RN910'
     O          E            Header         1
     O                                            5 'Date'
     O                                           15 'Item'
     O                                           29 'Dept'
     O                                           40 'From Slot'
     O                                           50 'Qty 1'
     O                                           56 'Qty 2'
     O                                           62 'Qty 3'
     O                                           72 'To Slot'
     **
     O          E            DtlLin         1
     O                       slsdte              10 '    -  -  '
     O                       slitem              26
     O                       slwhdp              30
     O                       sldisp              43
     O                       hstk1         J     50
     O                       hstk2         J     56
     O                       hstk3         J     62
     O                       y_sldisp            77
