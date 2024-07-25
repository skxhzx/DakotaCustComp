      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY003  Generate New Slots
     *  09 September 2016
     *  Rod Roller
     *
700  *  09/09/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fimpfstuf3 uf a e           k disk    extmbr('NEWSLOTS')

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     d loc             s              3s 0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        exsr AisleC;     // Dry
        exsr AisleD;     // Dry
        exsr AisleE;     // Dry
        exsr AisleF;     // Dry
        exsr AisleG;     // Dry
        exsr AisleH;     // Dry PIR
        exsr AisleJ;     // Mezz
        exsr AisleN;     // Ref
        exsr AisleP;     // Frz
        exsr AisleQ;     // Frz
        exsr AisleR;     // Frz
        exsr AisleS;     // Frz
        exsr AisleT;     // Frz PIR
        exsr AisleU;     // Frz PIR

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   endsr
     *
     *  ------ Aisle C ----------------------------------
      /free
        begsr AisleC;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 20 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 164;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '20-' + %char(loc) + '-1';
            write sirec;
            sidisp = '20-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '20-' + %char(loc) + '-3';
            write sirec;
            sidisp = '20-' + %char(loc) + '-4';
            write sirec;
            sidisp = '20-' + %char(loc) + '-5';
            write sirec;
          enddo;

          // Aisle 21 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 151;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '21-' + %char(loc) + '-1';
            write sirec;
            sidisp = '21-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '21-' + %char(loc) + '-3';
            write sirec;
            sidisp = '21-' + %char(loc) + '-4';
            write sirec;
            sidisp = '21-' + %char(loc) + '-5';
            write sirec;
          enddo;

        endsr; // AisleC
      /end-free
     *  ------ Aisle D ----------------------------------
      /free
        begsr AisleD;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 22 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 180;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '22-' + %char(loc) + '-1';
            write sirec;
            sidisp = '22-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '22-' + %char(loc) + '-3';
            write sirec;
            sidisp = '22-' + %char(loc) + '-4';
            write sirec;
            sidisp = '22-' + %char(loc) + '-5';
            write sirec;
          enddo;

          // Aisle 23 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 164;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '23-' + %char(loc) + '-1';
            write sirec;
            sidisp = '23-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '23-' + %char(loc) + '-3';
            write sirec;
            sidisp = '23-' + %char(loc) + '-4';
            write sirec;
            sidisp = '23-' + %char(loc) + '-5';
            write sirec;
          enddo;

          // Aisle 24 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 116;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '24-' + %char(loc) + '-1';
            write sirec;
            sidisp = '24-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '24-' + %char(loc) + '-3';
            write sirec;
            sidisp = '24-' + %char(loc) + '-4';
            write sirec;
            sidisp = '24-' + %char(loc) + '-5';
            write sirec;
          enddo;

        endsr; // AisleD
      /end-free
     *  ------ Aisle E ----------------------------------
      /free
        begsr AisleE;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 25 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 164;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '25-' + %char(loc) + '-1';
            write sirec;
            sidisp = '25-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '25-' + %char(loc) + '-3';
            write sirec;
            sidisp = '25-' + %char(loc) + '-4';
            write sirec;
            sidisp = '25-' + %char(loc) + '-5';
            write sirec;
          enddo;

        endsr; // AisleE
      /end-free
     *  ------ Aisle F ----------------------------------
      /free
        begsr AisleF;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 28 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 152;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '28-' + %char(loc) + '-1';
            write sirec;
            sidisp = '28-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '28-' + %char(loc) + '-3';
            write sirec;
            sidisp = '28-' + %char(loc) + '-4';
            write sirec;
            sidisp = '28-' + %char(loc) + '-5';
            write sirec;
          enddo;

          // Aisle 29 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 152;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '29-' + %char(loc) + '-1';
            write sirec;
            sidisp = '29-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '29-' + %char(loc) + '-3';
            write sirec;
            sidisp = '29-' + %char(loc) + '-4';
            write sirec;
            sidisp = '29-' + %char(loc) + '-5';
            write sirec;
          enddo;

          // Aisle 30 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 152;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '30-' + %char(loc) + '-1';
            write sirec;
            sidisp = '30-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '30-' + %char(loc) + '-3';
            write sirec;
            sidisp = '30-' + %char(loc) + '-4';
            write sirec;
            sidisp = '30-' + %char(loc) + '-5';
            write sirec;
          enddo;

        endsr; // AisleF
      /end-free
     *  ------ Aisle G ----------------------------------
      /free
        begsr AisleG;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 31 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 152;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '31-' + %char(loc) + '-1';
            write sirec;
            sidisp = '31-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '31-' + %char(loc) + '-3';
            write sirec;
            sidisp = '31-' + %char(loc) + '-4';
            write sirec;
            sidisp = '31-' + %char(loc) + '-5';
            write sirec;
          enddo;

          // Aisle 32 - 2 pick, 3 overflow
          loc = 100;
          dow loc < 128;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '32-' + %char(loc) + '-1';
            write sirec;
            sidisp = '32-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '32-' + %char(loc) + '-3';
            write sirec;
            sidisp = '32-' + %char(loc) + '-4';
            write sirec;
            sidisp = '32-' + %char(loc) + '-5';
            write sirec;
          enddo;

        endsr; // AisleG
      /end-free
     *  ------ Aisle H ----------------------------------
      /free
        begsr AisleH;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = 'P';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 26 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 212;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'N';
            sidisp = '26-' + %char(loc) + '-1';
            write sirec;
            sidisp = '26-' + %char(loc) + '-2';
            write sirec;
            sidisp = '26-' + %char(loc) + '-3';
            write sirec;
            sidisp = '26-' + %char(loc) + '-4';
            write sirec;
            sidisp = '26-' + %char(loc) + '-5';
            write sirec;
            sidisp = '26-' + %char(loc) + '-6';
            write sirec;
            sidisp = '26-' + %char(loc) + '-7';
            write sirec;
          enddo;

        endsr; // AisleH
      /end-free
     *  ------ Aisle J ----------------------------------
      /free
        begsr AisleJ;

          siwhse = 1;
          siwhdp = 'DRY';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 100;
          dow loc < 106;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 110;
          dow loc < 116;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 120;
          dow loc < 126;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 130;
          dow loc < 136;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 140;
          dow loc < 146;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 150;
          dow loc < 156;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 160;
          dow loc < 166;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

          // Aisle 45 - 2 pick, 1 overflow
          loc = 170;
          dow loc < 176;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '45-' + %char(loc) + '-1';
            write sirec;
            sidisp = '45-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '45-' + %char(loc) + '-3';
            write sirec;
          enddo;

        endsr; // AisleJ
      /end-free
     *  ------ Aisle N ----------------------------------
      /free
        begsr AisleN;

          siwhse = 1;
          siwhdp = 'REF';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 51 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 132;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '51-' + %char(loc) + '-1';
            write sirec;
            sidisp = '51-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '51-' + %char(loc) + '-3';
            write sirec;
            sidisp = '51-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 52 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 132;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '52-' + %char(loc) + '-1';
            write sirec;
            sidisp = '52-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '52-' + %char(loc) + '-3';
            write sirec;
            sidisp = '52-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 53 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 148;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '53-' + %char(loc) + '-1';
            write sirec;
            sidisp = '53-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '53-' + %char(loc) + '-3';
            write sirec;
            sidisp = '53-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 54 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 148;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '54-' + %char(loc) + '-1';
            write sirec;
            sidisp = '54-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '54-' + %char(loc) + '-3';
            write sirec;
            sidisp = '54-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 55 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 118;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '55-' + %char(loc) + '-1';
            write sirec;
            sidisp = '55-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '55-' + %char(loc) + '-3';
            write sirec;
            sidisp = '55-' + %char(loc) + '-4';
            write sirec;
          enddo;

        endsr; // AisleN
      /end-free
     *  ------ Aisle P ----------------------------------
      /free
        begsr AisleP;

          siwhse = 1;
          siwhdp = 'FRZ';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 61 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 136;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '61-' + %char(loc) + '-1';
            write sirec;
            sidisp = '61-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '61-' + %char(loc) + '-3';
            write sirec;
            sidisp = '61-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 62 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 136;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '62-' + %char(loc) + '-1';
            write sirec;
            sidisp = '62-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '62-' + %char(loc) + '-3';
            write sirec;
            sidisp = '62-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 63 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 136;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '63-' + %char(loc) + '-1';
            write sirec;
            sidisp = '63-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '63-' + %char(loc) + '-3';
            write sirec;
            sidisp = '63-' + %char(loc) + '-4';
            write sirec;
          enddo;

        endsr; // AisleP
      /end-free
     *  ------ Aisle Q ----------------------------------
      /free
        begsr AisleQ;

          siwhse = 1;
          siwhdp = 'FRZ';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 64 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 136;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '64-' + %char(loc) + '-1';
            write sirec;
            sidisp = '64-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '64-' + %char(loc) + '-3';
            write sirec;
            sidisp = '64-' + %char(loc) + '-4';
            write sirec;
          enddo;

        endsr; // AisleQ
      /end-free
     *  ------ Aisle R ----------------------------------
      /free
        begsr AisleR;

          siwhse = 1;
          siwhdp = 'FRZ';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 67 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 132;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '67-' + %char(loc) + '-1';
            write sirec;
            sidisp = '67-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '67-' + %char(loc) + '-3';
            write sirec;
            sidisp = '67-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 68 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 152;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '68-' + %char(loc) + '-1';
            write sirec;
            sidisp = '68-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '68-' + %char(loc) + '-3';
            write sirec;
            sidisp = '68-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 69 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 156;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '69-' + %char(loc) + '-1';
            write sirec;
            sidisp = '69-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '69-' + %char(loc) + '-3';
            write sirec;
            sidisp = '69-' + %char(loc) + '-4';
            write sirec;
          enddo;

        endsr; // AisleR
      /end-free
     *  ------ Aisle S ----------------------------------
      /free
        begsr AisleS;

          siwhse = 1;
          siwhdp = 'FRZ';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = ' ';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 70 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 156;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '70-' + %char(loc) + '-1';
            write sirec;
            sidisp = '70-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '70-' + %char(loc) + '-3';
            write sirec;
            sidisp = '70-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 71 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 160;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '71-' + %char(loc) + '-1';
            write sirec;
            sidisp = '71-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '71-' + %char(loc) + '-3';
            write sirec;
            sidisp = '71-' + %char(loc) + '-4';
            write sirec;
          enddo;

          // Aisle 72 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 160;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'Y';
            sidisp = '72-' + %char(loc) + '-1';
            write sirec;
            sidisp = '72-' + %char(loc) + '-2';
            write sirec;
            sipick = 'N';
            sirsrv = 'N';
            sidisp = '72-' + %char(loc) + '-3';
            write sirec;
            sidisp = '72-' + %char(loc) + '-4';
            write sirec;
          enddo;

        endsr; // AisleS
      /end-free
     *  ------ Aisle T ----------------------------------
      /free
        begsr AisleT;

          siwhse = 1;
          siwhdp = 'FRZ';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = 'P';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 65 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 168;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'N';
            sidisp = '65-' + %char(loc) + '-1';
            write sirec;
            sidisp = '65-' + %char(loc) + '-2';
            write sirec;
            sidisp = '65-' + %char(loc) + '-3';
            write sirec;
            sidisp = '65-' + %char(loc) + '-4';
            write sirec;
            sidisp = '65-' + %char(loc) + '-5';
            write sirec;
            sidisp = '65-' + %char(loc) + '-6';
            write sirec;
            sidisp = '65-' + %char(loc) + '-7';
            write sirec;
          enddo;

        endsr; // AisleT
      /end-free
     *  ------ Aisle U ----------------------------------
      /free
        begsr AisleU;

          siwhse = 1;
          siwhdp = 'FRZ';
          sififo = 0;
          siitem = *blank;
          siqty1 = 0;
          siqty2 = 0;
          siqty3 = 0;
          sipseq = 0;
          sistyp = 'P';
          siprty = 0;
          sidgt = 0;
          sidgtp = *blank;

          // Aisle 66 - 2 pick, 2 overflow
          loc = 100;
          dow loc < 168;
            loc = loc + 1;
            sipick = 'Y';
            sirsrv = 'N';
            sidisp = '66-' + %char(loc) + '-1';
            write sirec;
            sidisp = '66-' + %char(loc) + '-2';
            write sirec;
            sidisp = '66-' + %char(loc) + '-3';
            write sirec;
            sidisp = '66-' + %char(loc) + '-4';
            write sirec;
            sidisp = '66-' + %char(loc) + '-5';
            write sirec;
            sidisp = '66-' + %char(loc) + '-6';
            write sirec;
            sidisp = '66-' + %char(loc) + '-7';
            write sirec;
          enddo;

        endsr; // AisleU
      /end-free
