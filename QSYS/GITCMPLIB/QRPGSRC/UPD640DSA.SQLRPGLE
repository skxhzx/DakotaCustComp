      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD640DSA  Convert LICINFO to new single record layout
     *  09 September 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
640 A*    09/09/12  DAS  6.40
     *      - Created.
     *
640aA*    10/06/12  DAS  6.40a
     *      - Changed usebydte to mfgexp.
     *
640bA*    11/07/12  LMC  6.40b
     *      - Take out the CVTNUMB and replace it with a %dec
     *        conversion with a MONITOR around it
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lnrecOld      E ds                  extname(licinfo) prefix(sav)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  $cvnum         s             15  5
     D  $cvrtn         s              8
     D  currWhse       s              3s 0
     D  currLcns       s             15
     D  debugStr1      s           1000
     D  debugStr2      s           1000
     D  gOldFile       s             10
     D  gOldLib        s             10
     D  OldLibFile     s             25
     D  gNewFile       s             10
     D  gNewLib        s             10
     D  NewLibFile     s             25
     D  task           s              6

     *----------------------------------------------------------------
     *  File record data structures
     *----------------------------------------------------------------

     D oldrec          ds                  inz
     D  olnwhse                       3s 0
     D  olntype                       1
     D  olnlcns                      15
     D  olncode                       8
     D  olncseq                       5p 0
     D  olnvalue                     30
     D  olnaddts                       z
     D  olnadduc                       z
     D  olnaddpgm                    10
     D  olnaddemp                     5s 0
     D  olnaddusr                    10
     D  olnaddjob                    10
     D  olnaddnbr                     6
     D  olnchgts                       z
     D  olnchguc                       z
     D  olnchgpgm                    10
     D  olnchgemp                     5s 0
     D  olnchgusr                    10
     D  olnchgjob                    10
     D  olnchgnbr                     6

     D newrec          ds                  inz
     D  nlnwhse                       3s 0
     D  nlnlcns                      15
     D  nlnseq                        2s 0
     D  nlnitem                      15
     D  nlnpo                        15
     D  nlnposeq                      5p 0
     D  nlnrcvtyp                     1
     D  nlnrcvtrn#                    7p 0
     D  nlnrcvlbl#                    7p 0
     D  nlnrcvqty                     5p 0
     D  nlnentdate                    8s 0
     D  nlnenttype                    8
     D  nlnmfgdate                    8s 0
640aDD**nlnusebydte                   8s 0
640aMD  nlnmfgexp                     8s 0
     D  nlnfifodate                   8s 0
     D  nlnexpdate                    8s 0
     D  nlndateflag                   1
     D  nlnmfgflag                    1
     D  nlnmfgdays                    3p 0
     D  nlnusrdays                    3p 0
     D  nlndstdays                    3p 0
     D  nlnmfgcode                   15
     D  nlnttllbs                     9p 2
     D  nlnavglbs                     9p 2
     D  nlnlot                       30
     D  nlnlotpti2                    2
     D  nlnlotpti4                    4
     D  nlnhrvcert                   20
     D  nlnhrvdate                    8s 0
     D  nlnhrvloc                    20
     D  nlnbrand                     10
     D  nlnaddts                       z
     D  nlnadduc                       z
     D  nlnaddpgm                    10
     D  nlnaddemp                     5s 0
     D  nlnaddusr                    10
     D  nlnaddjob                    10
     D  nlnaddnbr                     6
     D  nlnchgts                       z
     D  nlnchguc                       z
     D  nlnchgpgm                    10
     D  nlnchgemp                     5s 0
     D  nlnchgusr                    10
     D  nlnchgjob                    10
     D  nlnchgnbr                     6

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pOldFile       s             10
     D  pOldLib        s             10
     D  pNewFile       s             10
     D  pNewLib        s             10

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D CvtNumB         pr                  extpgm('CVTNUMB')
     D   cvcmd                        8    const
     D   cvstr                       30    const
     D   cvnum                       15  5
     D   cvdec                        1  0 const
     D   cvrtn                        8

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pOldFile     Old LICINFO file name (default: LICINFO)
     *      pOldLib      Old LICINFO library   (default: *LIBL)
     *      pNewFile     New LICINFO file name (default: N.LICINFO)
     *      pNewLib      New LICINFO library   (default: *LIBL)
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pOldFile
     c                   parm                    pOldLib
     c                   parm                    pNewFile
     c                   parm                    pNewLib

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Verify parameters have been sent in

        gOldFile = 'LICINFO';
        gOldLib  = '*LIBL';
        gNewFile = 'N.LICINFO';
        gNewLib  = '*LIBL';

        if %parms >=1 and pOldFile <> ' ';
          gOldFile = pOldFile;
        endif;

        if %parms >=2 and pOldLib <> ' ';
          gOldLib = pOldLib;
        endif;

        if %parms >=3 and pNewFile <> ' ';
          gNewFile = pNewFile;
        endif;

        if %parms >=4 and pNewLib <> ' ';
          gNewLib = pNewLib;
        endif;

        // Initialize variables

        if gOldLib = '*LIBL';
          oldLibFile = dq + %trim(gOldFile) + dq;
        else;
          oldLibFile = %trim(gOldLib) + '/' + dq + %trim(gOldFile) + dq;
        endif;

        if gNewLib = '*LIBL';
          newLibFile = dq + %trim(gNewFile) + dq;
        else;
          newLibFile = %trim(gNewLib) + '/' + dq + %trim(gNewFile) + dq;
        endif;

        // Read through old file

        sqlstmt = 'select '
                +   'lnwhse, lntype, lnlcns, lncode, lncseq, lnvalue, '
                +   'lnaddts, lnadduc, lnaddpgm, lnaddemp, lnaddusr, '
                +   'lnaddjob, lnaddnbr, '
                +   'lnchgts, lnchguc, lnchgpgm, lnchgemp, lnchgusr, '
                +   'lnchgjob, lnchgnbr '
                + 'from ' + %trimr(oldLibFile) + ' '
                + 'order by lnwhse, lnlcns, lncode, lncseq ';

        exec sql prepare sel from :SqlStmt;
        exec sql declare csr cursor for sel;
        exec sql open csr;

        currWhse = 0;

        dow forever = forever;

          exec sql fetch next from csr
                   into :oldrec;
               //  into
               //   :olnwhse,:olntype,:olnlcns,:olncode,:olncseq,:olnvalue,
               //   :olnaddts,:olnadduc,:olnaddpgm,:olnaddemp,:olnaddusr,
               //   :olnaddjob,:olnaddnbr,
               //   :olnchgts,:olnchguc,:olnchgpgm,:olnchgemp,:olnchgusr,
               //   :olnchgjob,:olnchgnbr;

          if sqlstt <> sqlSuccess;
            if currWhse <> 0;
              exsr WrtNewRec;
            endif;
            leave;
          endif;

          if currWhse <> olnwhse or currlcns <> olnlcns;
            if currWhse <> 0;
              exsr WrtNewRec;
              currWhse = 0;
            endif;
          endif;

          exsr fillRec;

        enddo;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  FillRec    Fill new LICINFO fields with old field
     *----------------------------------------------------------------

     C     FillRec       begsr

      /free

        $cvnum = 0;
        $cvrtn = ' ';

        // Initialize some fields with info from first rec read for license.

        if currWhse = 0;
            clear newrec;
            currWhse = olnwhse;
            currLcns = olnlcns;
            nlnwhse = olnwhse;
            nlnlcns = olnlcns;
            nlnseq = 1;
            nlnaddts  = olnaddts;
            nlnadduc  = olnadduc;
            nlnaddpgm = olnaddpgm;
            nlnaddemp = olnaddemp;
            nlnaddusr = olnaddusr;
            nlnaddjob = olnaddjob;
            nlnaddnbr = olnaddnbr;
            // Set Change fields to Add fields.
            nlnchgts  = olnaddts;
            nlnchguc  = olnadduc;
            nlnchgpgm = olnaddpgm;
            nlnchgemp = olnaddemp;
            nlnchgusr = olnaddusr;
            nlnchgjob = olnaddjob;
            nlnchgnbr = olnaddnbr;
        endif;

        // Move record value into corresponding new record field.

        select;

          when olncode = '*AVGWGT';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 2: $cvrtn);
640bD       //nlnavglbs = $cvnum;
640bA       monitor;
640bA         eval nlnavglbs = %dec(olnvalue:9:2);
640bA       on-error;
640bA         eval nlnavglbs = 0;
640bA       endmon;

          when olncode = '*DATEIN';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnentdate = $cvnum;
640bA       monitor;
640bA         eval nlnentdate = %dec(olnvalue:8:0);
640bA       on-error;
640bA         eval nlnentdate = 0;
640bA       endmon;

          when olncode = '*DATETYP';
            nlnenttype = olnvalue;

          when olncode = '*DTESET1';
            nlndateflag = %subst(olnvalue: 7: 1);
            nlnmfgflag  = %subst(olnvalue: 15: 1);

          when olncode = '*DTESET2';
640bD       //cvtnumb ('*STR2NUM': %subst(olnvalue:7:3): $cvnum: 0: $cvrtn);
640bD       //nlnmfgdays = $cvnum;
640bA       monitor;
640bA         eval nlnmfgdays = %dec(%subst(olnvalue:7:3):3:0);
640bA       on-error;
640bA         eval nlnmfgdays = 0;
640bA       endmon;
640bD       //cvtnumb ('*STR2NUM': %subst(olnvalue:17:3): $cvnum: 0: $cvrtn);
640bD       //nlnusrdays = $cvnum;
640bA       monitor;
640bA         eval nlnusrdays = %dec(%subst(olnvalue:17:3):3:0);
640bA       on-error;
640bA         eval nlnusrdays = 0;
640bA       endmon;
640bD       //cvtnumb ('*STR2NUM': %subst(olnvalue:27:3): $cvnum: 0: $cvrtn);
640bD       //nlndstdays = $cvnum;
640bA       monitor;
640bA         eval nlndstdays = %dec(%subst(olnvalue:27:3):3:0);
640bA       on-error;
640bA         eval nlndstdays = 0;
640bA       endmon;

          when olncode = '*EXPDTE';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnexpdate = $cvnum;
640bA       monitor;
640bA         eval nlnexpdate = %dec(olnvalue:8:0);
640bA       on-error;
640bA         eval nlnexpdate = 0;
640bA       endmon;

          when olncode = '*FIFODTE';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnfifodate = $cvnum;
640bA       monitor;
640bA         eval nlnfifodate = %dec(olnvalue:8:0);
640bA       on-error;
640bA         eval nlnfifodate = 0;
640bA       endmon;

          when olncode = '*HRVCERT';
            nlnhrvcert = olnvalue;

          when olncode = '*HRVDATE';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnhrvdate = $cvnum;
640bA       monitor;
640bA         eval nlnhrvdate = %dec(olnvalue:8:0);
640bA       on-error;
640bA         eval nlnhrvdate = 0;
640bA       endmon;

          when olncode = '*HRVLOC';
            nlnhrvloc = olnvalue;

          when olncode = '*ITEM';
            nlnitem = olnvalue;

          when olncode = '*LOT';
            nlnlot = olnvalue;

          when olncode = '*MFGDTE';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnmfgdate = $cvnum;
640bA       monitor;
640bA         eval nlnmfgdate = %dec(olnvalue:8:0);
640bA       on-error;
640bA         eval nlnmfgdate = 0;
640bA       endmon;

          when olncode = '*PO';
            nlnpo = olnvalue;

          when olncode = '*POSEQ';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnposeq = $cvnum;
640bA       monitor;
640bA         eval nlnposeq   = %dec(olnvalue:5:0);
640bA       on-error;
640bA         eval nlnposeq = 0;
640bA       endmon;

          when olncode = '*RCVJOB';
            // not used

          when olncode = '*RCVLBL#';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnrcvlbl# = $cvnum;
640bA       monitor;
640bA         eval nlnrcvlbl# = %dec(olnvalue:7:0);
640bA       on-error;
640bA         eval nlnrcvlbl# =  0;
640bA       endmon;

          when olncode = '*RCVLQTY';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnrcvqty = $cvnum;
640bA       monitor;
640bA         eval nlnrcvqty  = %dec(olnvalue:5:0);
640bA       on-error;
640bA         eval nlnrcvqty  =  0;
640bA       endmon;

          when olncode = '*RCVTRN#';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 0: $cvrtn);
640bD       //nlnrcvtrn# = $cvnum;
640bA       monitor;
640bA         eval nlnrcvtrn# = %dec(olnvalue:7:0);
640bA       on-error;
640bA         eval nlnrcvtrn# =  0;
640bA       endmon;
            exec sql select pttask into :task
                     from pirtran where pttrn# = :nlnrcvtrn#;
            if sqlstt = sqlsuccess and task = 'PUTRTN';
              nlnrcvtyp = '2';
            else;
              nlnrcvtyp = '1';
            endif;

          when olncode = '*RCVTS';
            // not used

          when olncode = '*TTLWGT';
640bD       //cvtnumb ('*STR2NUM': olnvalue: $cvnum: 2: $cvrtn);
640bD       //nlnttllbs = $cvnum;
640bA       monitor;
640bA         eval nlnttllbs  = %dec(olnvalue:9:2);
640bA       on-error;
640bA         eval nlnttllbs  =  0;
640bA       endmon;

        endsl;

      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  WrtNewRec   Write record to new LICINFO file
     *----------------------------------------------------------------

     C     WrtNewRec     begsr

      /free

        sqlstmt = 'insert into ' + %trimr(newLibFile) + ' '
                + '('
                +   'lnwhse,'
                +   'lnlcns,'
                +   'lnseq,'
                +   'lnitem,'
                +   'lnpo,'
                +   'lnposeq,'
                +   'lnrcvtyp,'
                +   'lnrcvtrn#,'
                +   'lnrcvlbl#,'
                +   'lnrcvqty,'
                +   'lnentdate,'
                +   'lnenttype,'
                +   'lnmfgdate,'
640aD         //+   'lnusebydte,'
640aM           +   'lnmfgexp,'
                +   'lnfifodate,'
                +   'lnexpdate,'
                +   'lndateflag,'
                +   'lnmfgflag,'
                +   'lnmfgdays,'
                +   'lnusrdays,'
                +   'lndstdays,'
                +   'lnmfgcode,'
                +   'lnttllbs,'
                +   'lnavglbs,'
                +   'lnlot,'
                +   'lnlotpti2,'
                +   'lnlotpti4,'
                +   'lnhrvcert,'
                +   'lnhrvdate,'
                +   'lnhrvloc,'
                +   'lnbrand,'
                +   'lnaddts,'
                +   'lnadduc,'
                +   'lnaddpgm,'
                +   'lnaddemp,'
                +   'lnaddusr,'
                +   'lnaddjob,'
                +   'lnaddnbr,'
                +   'lnchgts,'
                +   'lnchguc,'
                +   'lnchgpgm,'
                +   'lnchgemp,'
                +   'lnchgusr,'
                +   'lnchgjob,'
                +   'lnchgnbr'
                + ') '
                + 'values ('
                +   %char(nlnwhse) + ','
                +   sq + %trimr(nlnlcns) + sq + ','
                +   %char(nlnseq) + ','
                +   sq + %trimr(nlnitem) + sq + ','
                +   sq + %trimr(nlnpo) + sq + ','
                +   %char(nlnposeq) + ','
                +   sq + %trimr(nlnrcvtyp) + sq + ','
                +   %char(nlnrcvtrn#) + ','
                +   %char(nlnrcvlbl#) + ','
                +   %char(nlnrcvqty) + ','
                +   %char(nlnentdate) + ','
                +   sq + %trimr(nlnenttype) + sq + ','
                +   %char(nlnmfgdate) + ','
640aD         //+   %char(nlnusebydte) + ','
640aM           +   %char(nlnmfgexp) + ','
                +   %char(nlnfifodate) + ','
                +   %char(nlnexpdate) + ','
                +   sq + %trimr(nlndateflag) + sq + ','
                +   sq + %trimr(nlnmfgflag)  + sq + ','
                +   %char(nlnmfgdays) + ','
                +   %char(nlnusrdays) + ','
                +   %char(nlndstdays) + ','
                +   sq + %trimr(nlnmfgcode) + sq + ','
                +   %char(nlnttllbs) + ','
                +   %char(nlnavglbs) + ','
                +   sq + %trimr(nlnlot) + sq + ','
                +   sq + %trimr(nlnlotpti2) + sq + ','
                +   sq + %trimr(nlnlotpti4) + sq + ','
                +   sq + %trimr(nlnhrvcert) + sq + ','
                +   %char(nlnhrvdate) + ','
                +   sq + %trimr(nlnhrvloc) + sq + ','
                +   sq + %trimr(nlnbrand) + sq + ','
                +   sq + %char(nlnaddts) + sq + ','
                +   sq + %char(nlnadduc) + sq + ','
                +   sq + %trimr(nlnaddpgm) + sq + ','
                +   %char(nlnaddemp) + ','
                +   sq + %trimr(nlnaddusr) + sq + ','
                +   sq + %trimr(nlnaddjob) + sq + ','
                +   sq + %trimr(nlnaddnbr) + sq + ','
                +   sq + %char(nlnchgts) + sq + ','
                +   sq + %char(nlnchguc) + sq + ','
                +   sq + %trimr(nlnchgpgm) + sq + ','
                +   %char(nlnchgemp) + ','
                +   sq + %trimr(nlnchgusr) + sq + ','
                +   sq + %trimr(nlnchgjob) + sq + ','
                +   sq + %trimr(nlnchgnbr) + sq
                + ')';

        debugStr1 = %subst(sqlstmt:1:1000);
        debugStr2 = %subst(sqlstmt:1001);

        exec sql execute immediate :sqlstmt;
        if sqlstt <> sqlSuccess;
          sqlstt = sqlstt;
        endif;

      /end-free
     C                   endsr
