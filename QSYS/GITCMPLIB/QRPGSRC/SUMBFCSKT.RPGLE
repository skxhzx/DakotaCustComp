      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SUMBFCSKT  SelectPrime summary of BFCSKTLOG OR400 entries
     *  19 July 2021
     *  Dave Sommerville
     *
     *  Revisions
     *
750 A*  07/19/21  DAS 7.50
     *   - Created
     *
     *----------------------------------------------------------------

     Fbfcsktlog4ip   e           k disk
     Fbfcsktsum o    e           k disk

     d pos             s             10i 0
     d pos2            s             10i 0
     d i               s             10i 0

      /free

         if slgip = 'OR400';
           if slgtyp = 'Beg';
             slgbufbeg = slgbuf;
             wherefrom = '';
             nxtscr = '';
             input = '';
             fflags = '';
             bflags = '';
             slot = '';
             trn# = '';
             lbl# = '';
             pos = %scan('whereFrom': slgbuf);
             if pos > 0;
               pos += 12;
               pos2 = %scan('"': slgbuf: pos);
               wherefrom = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('w1trn': slgbuf);
             if pos > 0;
               pos += 8;
               pos2 = %scan('"': slgbuf: pos);
               trn# = %subst(slgbuf: pos: pos2-pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('mtrn': slgbuf);
             if pos > 0;
               pos += 7;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('slvfyval': slgbuf);
             if pos > 0;
               pos += 11;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('w6cnt1e': slgbuf);
             if pos > 0;
               pos += 10;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('w7cwgt': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               input = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('f1f24flags': slgbuf);
             if pos > 0;
               pos += 13;
               for i = 1 to 24;
                 if %subst(slgbuf: pos+i-1: 1) = '1';
                   fflags = %trimr(fflags) + 'F' + %char(i);
                 endif;
               endfor;
             endif;
             pos = %scan('btnflags': slgbuf);
             if pos > 0;
               pos += 11;
               for i = 1 to 10;
                 if %subst(slgbuf: pos+i-1: 1) = '1';
                   bflags = %trimr(bflags) + 'B' + %char(i);
                 endif;
               endfor;
             endif;
           endif;
           if slgtyp = 'End';
             slgbufend = slgbuf;
             pos = %scan('nxtscr': slgbuf);
             if pos > 0;
               pos += 7;
               nxtscr = %subst(slgbuf: pos: 3);
             endif;
             pos = %scan('spoken': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               spoken = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('Slot:': slgbuf);
             if pos > 0;
               pos += 6;
               pos2 = %scan('"': slgbuf: pos);
               slot = %subst(slgbuf: pos: pos2-pos);
             endif;
             pos = %scan('errmsg': slgbuf);
             if pos > 0;
               pos += 9;
               pos2 = %scan('"': slgbuf: pos);
               errmsg = %subst(slgbuf: pos: pos2-pos);
             endif;
             write slgsumrec;
           endif;
         endif;

