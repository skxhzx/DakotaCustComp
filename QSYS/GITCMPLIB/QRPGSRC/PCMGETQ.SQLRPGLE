      /copy *libl/qcopysrc,hspecs
710aAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PCMQGET    Get PCM questions
     *  20 September 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    09/20/14  DAS  6.50
     *      - Created.
700aA*    08/01/15  LMC  7.00a
     *      - Additional logic needed to get all data
700bA*    08/19/15  LMC  7.00b
     *      - Changed zuper po to 9 positions
700cA*    02/03/16  LMC  7.00c
     *      - Logic for *POEXCPC - change exception questions
700dA*    02/10/16  LMC  7.00d
     *      - Logic for RCVL - license level PCM
710aA*    08/24/17  LMC  7.10a
     *      - Logic new frequency types - 5 & 6 for user controlled.
720aA*    05/30/18  LMC  7.20a
     *      - We now will call this program 6 times instead or 3.
     *        this should allow us to handle 60 questions.
720b *    08/22/18  LMC  7.20b
     *      - Recompile only - Databases changes.
720c *    10/25/18  LMC  7.20c
     *      - Do not ask frequency type 1 questions on non stock items
720d *    01/07/199 LMC  7.20d
     *      - gui doesn't use session HPSID - so if session is blank
     *        assume the haccplog record does not exist.
730aA*    03/12/19  LMC  7.30a
     *      - Added first record only. We are getting duplicates from
     *        the super po process. This is a temporary fix, until I
     *        can correct the loading program. This fix can stay it
     *        will not hurt anything.
730bA*    04/22/19  LMC  7.30b
     *      - Added first record only. We are getting duplicates from
     *        the super po process. This is a temporary fix, until I
     *        can correct the loading program. This fix can stay it
     *        will not hurt anything.  RCVH was missed
730cA*    06/27/19  LMC  7.30c
     *      - Fix: dec data error on PHVEN.
740aA*    04/15/20  LMC  7.40a
     *      - Enh: Added a PO verification process
740bA*    05/18/20  LMC  7.40b
     *      - Added logic to build class for parent/child questions.
     *      - Added logic to build style for parent/child questions.
     *      - If hidden question was sent, we loaded HNDCHLD in the
     *        answer, if that is the answer, need to send back blank
     *        for a request to change the answer.
740cA*    06/05/20  LMC  7.40C
     *      - Enh: Added a PO Follow-up process
750aA*    03/30/21  LMC  7.50a
     *      - Enh: Added PCM Exclusions.
750bA*    04/23/21  LMC  7.50b
     *      - Enh: Moved *RANDOM & *RANDOMC logic before some po logic
750cA*    12/15/21  LMC  7.50c
     *      - Enh: Check length of plicense on rcvv or rcvf. If the
     *             date was less than noon, it was failing on the
     *             subst to get the time.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   MRC limits a return variable to 2000 characters. To protect
     *   against needing more than 2000 characters, we will call this
     *   multiple times. The pCallNum field will identify the call
     *   number.
     *
     *   There is not a good way to know where we left off from a
     *   previous call, therefore we will rebuild the string from
     *   the beginning each time and return the 2000 characters that
     *   corresponds to the call number.
     *
     *----------------------------------------------------------------
710aA*----------------------------------------------------------------
710aA*  Binding Directories
710aA*----------------------------------------------------------------

710aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fhaccpq3   if   e           k disk
     Fhaccpv1   if   e           k disk
     Fglosess   if   e           k disk
     fhaccplog1 if   e           k disk
     fhaccplog2 if   e           k disk    rename(hlrec:hl3) prefix(h3_)
     Fhaccpqt   if   e           k disk
     Fpospo     if   e           k disk
     Fpospo1    if   e           k disk    rename(purec:spurec)
750aAFitemcls   if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCallNum    Call number
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pCmd        Command
     *      pPage       Page  -  0 = All pages
     *      pWhse       Warehouse
     *      pLevel      Level  -  *ALL = Get all active recs
     *      pType       Type
     *      pItem       Item
     *      pLicense    License
     *      pPO         PO Number
     *      pPOSeq      PO Seq#
700bM*      pSuperPO    Super PO
     *
     *    Returned Parameters
     *      pJSON       JSON String
     *
     *----------------------------------------------------------------

     D pcmgetq         pr                  extpgm('PCMGETQ')
     D  pCallNum                      1p 0
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pCmd                          8    varying
     D  pPage                         5  0
     D  pWhse                         3  0
     D  pLevel                        4    varying
     D  pType                         3    varying
     D  pItem                        15    varying
     D  pLicense                     15    varying
     D  pPO                           9    varying
     D  pPOSeq                        5  0
700bDD* pSuperPO                      4    varying
700bMD  pSuperPO                      9    varying
     D  pJSON                      2000    varying

     D pcmgetq         pi
     D  pCallNum                      1p 0
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pCmd                          8    varying
     D  pPage                         5  0
     D  pWhse                         3  0
     D  pLevel                        4    varying
     D  pType                         3    varying
     D  pItem                        15    varying
     D  pLicense                     15    varying
     D  pPO                           9    varying
     D  pPOSeq                        5  0
700bDD* pSuperPO                      4    varying
700bMD  pSuperPO                      9    varying
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D*forever         s               n
     D full            s               n

     D debug1          s           1000    varying
     D debug2          s           1000    varying
     D debug3          s           1000    varying
     D debug4          s           1000    varying
     D debug5          s           1000    varying
     D debug6          s           1000    varying
720aAD debug7          s           1000    varying
720aAD debug8          s           1000    varying
720aAD debug9          s           1000    varying
720aAD debug10         s           1000    varying
720aAD debug11         s           1000    varying
720aAD debug12         s           1000    varying

720aDD*currStr         s           6000    varying
720aMD currStr         s          12000    varying
     D errStr          s             50    varying
720aDD*largeStr        s           6000    varying
720aDD*prvStr          s           6000    varying
720aMD largeStr        s          12000    varying
720aMD prvStr          s          12000    varying

     D clr             s              7    varying
     D delimiter       s              1    varying
     D delimiter2      s              1    varying
     D*dsc             s            500    varying
     D*opt             s             40    varying
     D*txt             s             50    varying
     D*val             s            400    varying

740bAD class           s             75    varying
740bAD style           s             25    varying
     D id              s              5  0
     D lvl             s              4    varying
     D typ             s              3    varying
     D cod             s             15    varying
     D q               s             45    varying
     D atyp            s              1    varying
     D alen            s              3    varying
     D adec            s              1    varying
     D tbl             s             10    varying
     D rqd             s              1    varying
700aAD pans            s             30    varying
     D rng1            s             15    varying
     D rng2            s             15    varying
700aAD rwrn            s             30    varying


     D startPos        s              5p 0
     D endPos          s              5p 0
     D outLen          s              5p 0
     D maxLen          s              5p 0
     D len             s              5p 0
     D remainLen       s              5p 0

     D chrUser         s             10

     D addFlag         s              1p 0
     D chgFlag         s              1p 0
     D dltFlag         s              1p 0
     D viewFlag        s              1p 0
     D pgm             s             20

740aAD pexpdate        s              8  0
740aAD pexptime        s              6  0
750cAD pexptimea       s              6
     D $code           s             15
     D morelicense     s              1
     D morequestions   s              1
     D savelicense     s                   like(plicense)
     D savetype        s              3
     D today           s              1
700dAD laitem          s             15
740aAD pohdrexpdtts    s               z
750aAD excludeqstn     s              1
750cAd plicenseLength  s             15  0
710aA*----------------------------------------------------------------
710aA*  Time variables
710aA*----------------------------------------------------------------
710aA
710aAD CurrStamploc    s               z
710aAD CurrStampsys    s               z
710aAD CurrStampuc     s               z
710aAD CurrStampBeg    s               z
710aAD CurrStampEnd    s               z
710aA
710aAD bfcoffset       s              3  0 inz(0)
710aA*----------------------------------------------------------------
710aA* Function prototypes.
710aA*----------------------------------------------------------------
710aA
710aA /copy qcopysrc,p.bfcdteti

740aA*----------------------------------------------------------------
740aA*  Sub-procedure prototypes
740aA*----------------------------------------------------------------

740aAd CreateTS        pr              z
740aAd  date                          8p 0 const
740aAd  time                          6p 0 const

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

700dA*----------------------------------------------------------------
700dA*  pirhold structures
700dA*----------------------------------------------------------------
700dA /copy qcopysrc,C#PIRHLLCN

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D hirec3        E Ds                  Extname(HACCPQ3) prefix(ck_)
     D phrec         e ds                  extname(pohdr)
700dDD*larec         e ds                  extname(licactive)
700dAD horec         e ds                  extname(pirhold)
     D itrec         e ds                  extname(piritem)
     D ifrec         e ds                  extname(itemfld)
     D hprec         e ds                  extname(haccps)
     D hlrec1        e ds                  extname(haccplog)
740bAD hdrec         e ds                  extname(haccpqc)
740bAD hirec1        E Ds                  Extname(HACCPQ1) prefix(pq_)
740aAD phhrec        e ds                  extname(pohhdr)
750aAD herec         e ds                  extname(haccpe)


     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D authmenu        pr                  extpgm('AUTHMENU')
     D  pMenuId                      20    const
     D  pUser                        10    const
     D  pViewFLag                     1p 0
     D  pAddFlag                      1p 0
     D  pChgFlag                      1p 0
     D  pDltFlag                      1p 0
     D  pPgm                         20

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  {
     *   "recs":
     *          [
     *           {
     *            "whs":
     *            "id":
740bA*            "class":
740bA*            "style":
     *            "lvl":
     *            "typ":
     *            "cod":
     *            "q":
     *            "atyp":
     *            "tbl":
     *            "rqd":
     *            "pans":
     *            "len":
     *            "dec":
     *            "rng1":
     *            "rng2":
xxxx *            "rwrn":
     *           }
     *          ]
     *  }

      /free
         *inlr = *on;

         // Convert inputs to uppercase

         chrUser = %trim(pUser);

         pCmd     = %xlate(xlower: xupper: pCmd);
         pLevel   = %xlate(xlower: xupper: pLevel);
         pType    = %xlate(xlower: xupper: pType);
         pItem    = %xlate(xlower: xupper: pItem);
         pLicense = %xlate(xlower: xupper: pLicense);
         pPO      = %xlate(xlower: xupper: pPO);
         pSuperPO = %xlate(xlower: xupper: pSuperPO);

         // Initialize max lengths

         outLen = %size(pJSON) - 2;
         maxLen = %size(largeStr) - 2;

         // If call size greater than max length, get out

         if (pCallNum * outLen) > maxLen;
           pJSON = '';
           return;
         endif;

         // Initialize overflow string

         errStr = '{"opt":"OVRFLOW"}';

         // If warehouse not passed in, use session warehouse.

         if pWhse = 0;
           chain (pSessId) glosess;
           if %found(glosess);
             pWhse = gswhse;
           endif;
         endif;

         // Build large string

         largeStr = '{"recs":[';
         delimiter = '';

         // Add the options to the string.
         // This is the order they will appear on the screen.

         select;
           when pCmd = '*ALL';
             exsr GetAllRecs;
           other;
             exsr GetMatchingRecs;
         endsl;

         if not full;
           exsr Append;
           largeStr += ']}';
         endif;

         // Extract section for call number

         startPos = ((pCallNum - 1) * outLen) + 1;
         endPos = pCallNum * outLen;
         if endPos > %len(largeStr);
           endPos = %len(largeStr);
         endif;
         len = endPos - startPos + 1;

         if len > 0;
           pJSON = %subst(largeStr: startPos: len);
         else;
           pJSON = '';
         endif;


         len = %len(largeStr);
         select;
           when len > 11000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: 1000);
             debug7 = %subst(largeStr: 6001: 1000);
             debug8 = %subst(largeStr: 7001: 1000);
             debug9 = %subst(largeStr: 8001: 1000);
             debug10= %subst(largeStr: 9001: 1000);
             debug11= %subst(largeStr: 10001:1000);
             debug12= %subst(largeStr: 11001: len-11000);
           when len > 10000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: 1000);
             debug7 = %subst(largeStr: 6001: 1000);
             debug8 = %subst(largeStr: 7001: 1000);
             debug9 = %subst(largeStr: 8001: 1000);
             debug10= %subst(largeStr: 9001: 1000);
             debug11= %subst(largeStr: 10001: len-10000);
           when len > 9000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: 1000);
             debug7 = %subst(largeStr: 6001: 1000);
             debug8 = %subst(largeStr: 7001: 1000);
             debug9 = %subst(largeStr: 8001: 1000);
             debug10= %subst(largeStr: 9001: len-9000);
           when len > 8000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: 1000);
             debug7 = %subst(largeStr: 6001: 1000);
             debug8 = %subst(largeStr: 7001: 1000);
             debug9 = %subst(largeStr: 8001: len-8000);
           when len > 7000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: 1000);
             debug7 = %subst(largeStr: 6001: 1000);
             debug8 = %subst(largeStr: 7001: len-7000);
           when len > 6000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: 1000);
             debug7 = %subst(largeStr: 6001: len-6000);
           when len > 5000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: 1000);
             debug6 = %subst(largeStr: 5001: len-5000);
           when len > 4000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: 1000);
             debug5 = %subst(largeStr: 4001: len-4000);
           when len > 3000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: 1000);
             debug4 = %subst(largeStr: 3001: len-3000);
           when len > 2000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: 1000);
             debug3 = %subst(largeStr: 2001: len-2000);
           when len > 1000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: len-1000);
           when len > 0;
             debug1 = %subst(largeStr: 1: len);
         endsl;

       return;
      /end-free

     *----------------------------------------------------------------
     *  Append    Append to large string
     *----------------------------------------------------------------

      /free
       begsr Append;

         remainLen = maxLen - %len(largeStr) - 2;

         // If everything fits, append previous string

         if (%len(prvStr)+%len(currStr)) <= remainLen;
           largeStr += prvStr;
           prvStr = currStr;
           currStr = '';
           leavesr;
         endif;

         // Otherwise we have overflow condition.
         // We should at least be able to append the error string,
         // but try to include the previous string as well.
         // End result should be screen with the last field row
         // showing an Overflow message.

         full = *on;

         if (%len(prvStr)+%len(errStr)) > remainLen;
           largeStr += errStr;
         else;
           largeStr += prvStr + errStr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetPgm    Get program to call
     *----------------------------------------------------------------

      /free
       begsr GetPgm;

         viewFlag = 0;
         addFlag = 0;
         chgFlag = 0;
         dltFlag = 0;
         pgm = ' ';

         authmenu(hitabl :
                  chrUser :
                  viewFlag :
                  addFlag :
                  chgFlag :
                  dltFlag :
                  pgm);

         if viewflag = 0;
           pgm = 'NA';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonQ1    Question type 1 - Text, no validataion
     *----------------------------------------------------------------

      /free
       begsr JsonQ1;

         // Set the max length and decimal postions
         // For character strings, we want the dec field to be blank.

         select;
           when atyp = '1';
             alen = '30';
             adec = '';
           when atyp = '2';
             alen = '1';
             adec = '';
           when atyp = '3';
             alen = '30';
             adec = '';
           when atyp = '4';
             alen = '20';
             adec = '';
           when atyp = '5';
             alen = '9';
             adec = '2';
           when atyp = '6';
             alen = '9';
             adec = '2';
           when atyp = '7';
             alen = '6';
             adec = '';
           when atyp = '8';
             alen = '15';
             adec = '';
           when atyp = '9';
             alen = '30';
             adec = '';
         endsl;

         // Start question string with std fields

         currStr = delimiter
                 + '{"whs":"' + %char(pWhse) + '",'
                 +  '"id":"' + %char(id) + '",'
740bA            +  '"class":"' + %trimr(class) + '",'
740bA            +  '"style":"' + %trimr(style) + '",'
                 +  '"lvl":"' + lvl + '",'
                 +  '"typ":"' + typ + '",'
                 +  '"cod":"' + cod + '",'
                 +  '"q":"' + q + '",'
                 +  '"atyp":"' + atyp + '",'
                 +  '"len":"' + alen + '",'
                 +  '"dec":"' + adec + '",'
700aA            +  '"rqd":"' + rqd + '",'
700aA            +  '"pans":"' + pans + '"';

         // Add extra fields for some question types

         select;

           when atyp = '3';
             exsr JsonType3;

           when atyp = '4';
             exsr JsonType4;

           when atyp = '5';
             exsr JsonRange;

           when atyp = '8';
             exsr JsonRange;

         endsl;

         // End question

         currStr += '}';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonType3   Add return values to string for Question
     *              Type 3 - Values from HACCPV file
     *
     *  An MRC Option program has been created to display the values
     *  from the HACCPV file. A record for HV900 has been created
     *  in the global menu item file that points to the MRC program.
     *
     *----------------------------------------------------------------

      /free
       begsr JsonType3;

         // We will use an MRC program to generate the dropdown list

         hitabl = 'HV900';
         exsr GetPgm;

         // Add to string as a dropdown

         currStr +=  ',"tbltyp":"D"'
                 +   ',"tbl":"' + %trimr(hitabl) + '"'
                 +   ',"pgm":"' + %trimr(pgm) + 's'
                 +                '?slnk=1'
                 +                '&HVWHSE=' + %char(pWhse)
                 +                '&HVSEQ%23=' + %char(id)
                 +          '"';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonType4   Add return values to string for Question
     *              Type 4 - Table validation
     *
     *  The HITABL code must be defined in the global menu item file,
     *  pointing to an MRC Option program.
     *
     *  The default is that the Option program does not need any
     *  parameters passed in and it will create a dropdown.
     *  Exceptions to this will need to be hard code, similar to
     *  what is done in routine JsonType3.
     *
     *  If a table is expected to have a very large number of records
     *  it should be defined as a lookup instead of a dropdown.
     *
     *  The MRC program (BFCDAKOTA.M15800) has not been programmed
     *  to handle this yet.
     *
     *----------------------------------------------------------------

      /free
       begsr JsonType4;

         // Get the corresponding MRC program for the validation pgm

         exsr GetPgm;

         // Add to string

         select;
           //when hitabl = 'IT900';
           //  currStr +=  ',"tbltyp":"L"'
           //          +   ',"tbl":"' + %trimr(hitabl) + '"'
           //          +   ',"pgm":"' + %trimr(pgm) + 's"';
           other;
             currStr +=  ',"tbltyp":"D"'
                     +   ',"tbl":"' + %trimr(hitabl) + '"'
                     +   ',"pgm":"' + %trimr(pgm) + 's"';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonRange  Add range to question string
     *----------------------------------------------------------------

      /free
       begsr JsonRange;

         // Get record containing range

         setll (hiwhse: hiseq#) haccpv1;
         reade (hiwhse: hiseq#) haccpv1;
         if not %found(haccpv1);
            rng1 = '0';
            rng2 = '0';
700aA       rwrn = ' ';
         else;
           select;
             when atyp = '5';
               rng1 = %char(hvt5vl);
               rng2 = %char(hvt5rg);
700aA          rwrn = %trim(hvwarn);
             when atyp = '8';
               rng1 = %char(hvvalu);
               rng2 = %char(hvvalr);
700aA          rwrn = %trim(hvwarn);
             other;
               rng1 = '0';
               rng2 = '0';
700aA          rwrn = ' ';
           endsl;
         endif;

         // Add range to question string

         currStr += ','
                 +  '"rng1":"' + rng1 + '",'
700aA            +  '"rng2":"' + rng2 + '",'
700aA            +  '"rwrn":"' + rwrn + '"';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetAllRecs   Get all active records
     *----------------------------------------------------------------

      /free
       begsr GetAllRecs;

         if full;
           leavesr;
         endif;

         delimiter = '';

         setll (pWhse) haccpq3;

         dow forever = forever;
           reade (pWhse) haccpq3;
           if %eof(haccpq3);
             leave;
           endif;

750aA      exsr zzexclude;
750aA      if excludeqstn = 'Y';
750aA        iter;
750aA      endif;

           id = hiseq#;
           lvl = %trimr(hilevl);
           typ = %trimr(hitype);
           cod = %trimr(hicode);
           q = %trimr(hiqstn);
           atyp = %trimr(hiatyp);
           tbl = %trimr(hitabl);
           rqd = %trimr(hireqd);
700aA      pans = ' ';
740bA      // I only need to build class if child questions exist
740bA      class = ' ';
740bA      style = ' ';
740bA      exec sql select * into :hdrec
740bA               from haccpqc
740bA               where hdwhse = :pwhse
740bA                 and hdpseq# = :hiseq#
740bA                 fetch first row only;
740bA      If sqlstt = sqlSuccess;
740bA        // I found a child question for this parent build
740bA        // parent class
740aA        select;
740bA          when hiatyp = '2';
740bA            class = 'PQ2' + %char(id);
740bA          when hiatyp = '3';
740bA            class = 'PQ3' + %char(id);
740bA          other;
740bA            class = 'PQ' + %char(id);
740bA        endsl;
740bA      endif;
740bA
740bA      // is this a child?
740bA      exec sql select * into :hdrec
740bA               from haccpqc
740bA               where hdwhse = :pwhse
740bA                 and hdseq# = :hiseq#
740bA                 fetch first row only;
740bA      If sqlstt = sqlSuccess;
740bA        // I'm a child
             // is my parent a yes or no question?
740bA        exec sql select * into :hirec1
740bA                 from haccpq
740bA                 where hiwhse = :hdwhse
740bA                   and hiseq# = :hdpseq#;
740bA        // if I am a anwer type 2 Y/N and the hdvalu is N, then we
740bA        // don't want to none display on initial load
740bA        //if pq_hiatyp = '2' and hdvalu = 'N';
740bA        //else;
740bA          style = 'display: none;';
740bA        //endif;
740bA        if class <> ' ';
740bA          class = %trimr(class) + ' '
740bA                                + 'CQ' + %char(hdpseq#)
740bA                                + hdvalu;
740bA        else;
740bA          class = 'CQ' + %char(hdpseq#) + hdvalu;
740bA        endif;

740bA        // now I want to add a way to know the parent question
740bA        class = %trimr(class) + ' '
740bA              + 'PH' + %char(hdpseq#);
740bA      endif;
740bA

700aA          // load previous logged answers to screen fields
700cD          //if pcmd = '*PORCVCH' and today = 'Y';
700cM          if pcmd = '*PORCVCH' and today = 'Y' or
700cA             pcmd = '*POEXCPC' and today = 'Y';
700aA            select;
700aA              when atyp = '2';
700aA                if hldata = 'Yes';
700aA                  pans = 'Y';
700aA                else;
700aA                  pans = 'N';
700aA                endif;
700aA              //when atyp = '3';
700aA                //chain (hlwhse: hlseq#: hlvsq#) haccpv1;
700aA                //if %found(haccpv1);
700aA                  //pans = %trim(hvdesc);
700aA                //endif;
700aA              other;
740bA                if hldata = 'HDNCHLD';
740bA                  pans = ' ';
740bA                else;
700aA                  pans = %trim(hldata);
740bA                endif;
700aA            endsl;
700aA          endif;

           exsr JsonQ1;
           exsr Append;

         enddo;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetMatchingRecs   Get matching active records
     *----------------------------------------------------------------

      /free
       begsr GetMatchingRecs;

         if full;
           leavesr;
         endif;

         delimiter = '';

         // need to use logic from HA410 to determine if the questions will
         // be loaded.
         // this is the new code

         // need the vendor number
         exec sql select * into :phrec
                  from pohdr
                  where phwhse = :pwhse
                    and phpo   = :ppo;

         // we will be replacing *POHDR & *PODTL With *PORCV
700aA    // we will be replacing *POHDRCH & *PODTLCH With *PORCVCH
         // we need to make two passes on *PORCV - RCVH & RCVI
         for i = 1 to 2;
700aA      if pcmd = '*PORCV'
700aA         or pcmd = '*PORCVCH';
             select;
               when i = 1;
                 plevel = 'RCVH';
               other;
                 plevel = 'RCVI';
             endsl;
           endif;
700dA      select;
700dA        when plevel = 'RCVL';
700dA          i=2;
740aA        when plevel = 'RCVV';
740aA          i=2;
740cA        when plevel = 'RCVF';
740cA          i=2;
700dA        when %subst(plevel:1:3) <> 'RCV';
700dA          i=2;
700dA      endsl;
700aA      // Any level other tha RCV* levels get I set to 2.
700dD      //if %subst(plevel:1:3) <> 'RCV';
700aD      //if plevel = 'REXI';
700dD        //i=2;
700dD      //endif;
           hbtype = ptype;
           hblevl = plevel;
700aA      // Get License if *PORCVCH and no license passed in.
700aA      if pcmd = '*PORCVCH' and plevel = 'RCVL';
             if plicense = ' ';
               setll (pwhse: ppo: pposeq) haccplog2;
               morelicense = 'Y';
             endif;
             if morelicense = 'Y';
               h3_hllcns = ' ';
               dou savelicense <> h3_hllcns or
                   morelicense = ' ';
                 reade (pwhse: ppo: pposeq) haccplog2;
                 if %eof(haccplog2);
                   morelicense = ' ';
                 else;
                   plicense = h3_hllcns;
                 endif;
               enddo;
               savelicense = h3_hllcns;
             endif;
           endif;

           // Get Item Number if license is passed in on RCVL
           // Load item if item passed in on RCVI
           laitem = *blanks;
           if plevel = 'RCVI';
             laitem = pItem;
           endif;
           if plevel = 'REXI';
             laitem = pItem;
           endif;
740cM    if plevel = 'RCVV'
740cA       or plevel = 'RCVF';
750cA      plicenseLength = %Len(%Trim(Plicense));
750cA      if plicenseLength <> 14;
750cA        pexpdate = %dec(%subst(Plicense:1:8):8:0);
750cA        pexptimea= '0' +  %subst(Plicense:9:5);
750cA        pexptime = %dec(%subst(Pexptimea:1:6):6:0);
750cA      else;
740aA        pexpdate = %dec(%subst(Plicense:1:8):8:0);
740aA        pexptime = %dec(%subst(Plicense:9:6):6:0);
750cA      endif;
740aA      plicense = ' ';
740aA    endif;
           if plevel = 'RCVL';
700dA        exec sql select * into :horec
700dA                 from pirhold
700dA                 where hokey = :plicense
700dA                   and hotype = 'POLCNS';
700dA        If sqlstt = sqlSuccess;
700dA          pirhllcnds = hodata;
700dA          laitem = h1item;
700dA        else;
700dA          laitem = ' ';
700dA        endif;
700dD        //exec sql select * into :larec
700dD                 //from licactive
700dD                 //where lawhse = :pwhse
700dD                   //and lalcns = :plicense;
           endif;

           if laitem <> ' ';
             // Get item description to display.
             exec sql select * into :itrec
                      from piritem
                      where itwhse = :pwhse
                        and ititem = :laitem;
             ifcat = ' ';
             exec sql select * into :ifrec
                      from itemfld
                      where ifwhse = :pwhse
                        and ifitem = :laitem;
           endif;
           // get heading for special user type selection
           select;
             when plevel = 'RCVH';
             when plevel = 'RCVI';
             when plevel = 'REXI';
             when plevel = 'RCVL';
             other;
               chain (pwhse: plevel: ptype) haccpqt;
               if %found(haccpqt);
                 //hldspecdesc = hbdesc;
               else;
                 //hldspecdesc = ' ';
               endif;
           endsl;

           // get session id
           exec sql select * into :hprec
                    from haccps
                    where hpuser = :#user
                      and hpjob = :#job
                      and hpjobn = :#jobn;
720dA      if sqlstt <> sqlSuccess;
720dA        hpsid = *loval;
720dA      endif;
           // this came from zzfil1
           select;
             when morequestions = 'Y';
             when ptype = ' ';
               setll (pwhse: hblevl) haccpqt;
             when ptype <> ' ';
               setll (pwhse: hblevl: hbtype) haccpqt;
           endsl;

           dow forever = forever;
             select;
               when morequestions = 'Y';
               when ptype = ' ';
                 reade (pwhse: hblevl) haccpqt;
               when ptype <> ' ';
                 reade (pwhse: hblevl: hbtype) haccpqt;
             endsl;

             if %eof(haccpqt);
               //moretypes = ' ';
               leave;
             endif;

             if morequestions = ' ';
               $code = ' ';
             endif;

             select;
               when morequestions = 'Y';
               when hbtype = 'CAT';
                 $code = ifcat;
               when hbtype = 'ITM';
                 $code = ititem;
               when hbtype = 'DPT';
                 $code = itwhdp;
               when hbtype = 'VEN';
730cA            if phpo <> ' ';
                   $code = %trim(%editc(phven:'Z'));
730cA            endif;
             endsl;

             if morequestions = ' ';
               hilevl = hblevl;
               hitype = hbtype;
               setll (pwhse: hilevl: hitype: $code) haccpq3;
             endif;

             // read question file for question type
             dou %eof(haccpq3);
               reade (pwhse: hilevl: hitype: $code) haccpq3;
               if %eof(haccpq3);
                 morequestions = ' ';
                 leave;
               endif;

750aA          exsr zzexclude;
750aA          if excludeqstn = 'Y';
750aA            iter;
750aA          endif;

               select;

                 // *POHDR check to see if header questions have been
                 // answered already for this po today don't ask again
                 when pcmd = '*PORCV  ';
                   exsr zzchklog;
                   if today = 'Y';
                     savetype = hitype;
                     iter;
                   endif;

740aA            // *POVFY check to see if RCVV questions have been
740aA            // answered already for this po since the export date
740cM            when pcmd = '*POVFY  '
740cA              or pcmd = '*POFU   ';
740aA              exsr zzchklog;
740aA              if today = 'Y';
740aA                savetype = hitype;
740aA                iter;
740aA              endif;

700aA            // if *PORCVCH check to see if header question have been
                 // answered for this po today, allow change to answers
700aA            when pcmd = '*PORCVCH';
                   exsr zzchklog;
                   if today = ' ';
                     savetype = hitype;
                     iter;
                   endif;

                 // this has been replaced with *PORCV
                 // *PODTL check to see if detail questions have been
                 // answered already for this po today don't ask again
                 //when pcmd = '*PODTL  ' and plevel = 'RCVI';
                 when pcmd = '*PORCV  ' and plevel = 'RCVI';
                   //plcns = ' ';
                   exsr zzchklog;
                   if today = 'Y';
                     savetype = hitype;
                     iter;
                   endif;

                 // *PODTL check to see if detail questions have been
                 // answered already for this po today don't ask again
                 when pcmd = '*PODTL  ' and plevel = 'REXI';
                   //plcns = ' ';
                   exsr zzchklog;
                   if today = 'Y';
                     savetype = hitype;
                     iter;
                   endif;


700aA            // if *PORCVCH check to see if detail question have been
                 // answered for this po today, allow change to answers
700aA            when pcmd = '*PORCVCH' and plevel = 'RCVI';
                   //plcns = ' ';
                   exsr zzchklog;
                   if today = ' ';
                     savetype = hitype;
                     iter;
                   endif;

700aA            // if *PORCVCH check to see if detail question have been
                 // answered for this po today, allow change to answers
700cD            //when pcmd = '*PORCVCH' and plevel = 'REXI';
700cM            when pcmd = '*POEXCPC' and plevel = 'REXI';
                   //plcns = ' ';
                   exsr zzchklog;
                   if today = ' ';
                     savetype = hitype;
                     iter;
                   endif;


                 // *PODTL check to see if detail questions have been
                 // answered already for this po today don't ask again
                 when pcmd = '*PODTL  ' and plevel = 'RCVL';
                   exsr zzchklog;
                   if today = 'Y';
                     savetype = hitype;
                     iter;
                   endif;

700aA            // if *PORCVCH check to see if detail question have been
                 // answered for this po today, allow change to answers
700aA            when pcmd = '*PORCVCH' and plevel = 'RCVL';
                   exsr zzchklog;
                   if today = ' ';
                     savetype = hitype;
                     iter;
                   endif;

                 // if *RANDOMC check to see if random question have been
                 // answered for this user type today, allow chg to  answers
                 when pcmd = '*RANDOMC';
                   exsr zzchklog;
                   if today = ' ';
                     savetype = hitype;
                     iter;
                   endif;
710aA            // if *RANDOM  check to see if random question have
710aA            // been answered for frequency types 5 or 6
710aA            when pcmd = '*RANDOM';
710aA              exsr zzchklog;
710aA              if today = 'Y';
710aA                savetype = hitype;
710aA                iter;
710aA              endif;
               endsl;

         // this is the end of the new code

         //setll (pWhse: pLevel) haccpq3;

         //dow forever = forever;
           //reade (pWhse: pLevel) haccpq3;
           //if %eof(haccpq3);
             //leave;
           //endif;

               id = hiseq#;
               lvl = %trimr(hilevl);
               typ = %trimr(hitype);
               cod = %trimr(hicode);
               q = %trimr(hiqstn);
               atyp = %trimr(hiatyp);
               tbl = %trimr(hitabl);
               rqd = %trimr(hireqd);
700aA          pans = ' ';
740bA      // is this a parent?
740bA      class = ' ';
740bA      style = ' ';
740bA      exec sql select * into :hdrec
740bA               from haccpqc
740bA               where hdwhse = :pwhse
740bA                 and hdpseq# = :hiseq#
740bA                 fetch first row only;
740bA      If sqlstt = sqlSuccess;
740bA        // I'm a parent
740bA        // parent class
740aA        select;
740bA          when hiatyp = '2';
740bA            class = 'PQ2' + %char(id);
740bA          when hiatyp = '3';
740bA            class = 'PQ3' + %char(id);
740bA          other;
740bA            class = 'PQ' + %char(id);
740bA        endsl;
740bA      endif;
740bA
740bA      // is this a child?
740bA      exec sql select * into :hdrec
740bA               from haccpqc
740bA               where hdwhse = :pwhse
740bA                 and hdseq# = :hiseq#
740bA                 fetch first row only;
740bA      If sqlstt = sqlSuccess;
             // is my parent a yes or no question?
740bA        exec sql select * into :hirec1
740bA                 from haccpq
740bA                 where hiwhse = :hdwhse
740bA                   and hiseq# = :hdpseq#;
740bA        style = 'display: none;';
740bA        // I'm a child
740bA        // parent class
740bA        if class <> ' ';
740bA          class = %trimr(class) + ' '
740bA                                + 'CQ' + %char(hdpseq#)
740bA                                + hdvalu;
740bA        else;
740bA          class = 'CQ' + %char(hdpseq#) + hdvalu;
740bA        endif;
740bA        // now I want to add a way to know the parent question
740bA        class = %trimr(class) + ' '
740bA              + 'PH' + %char(hdpseq#);
740bA      endif;
740bA

700aA          // load previous logged answers to screen fields
700cD          //if pcmd = '*PORCVCH' and today = 'Y';
700cM          if pcmd = '*PORCVCH' and today = 'Y' or
750bA             pcmd = '*RANDOMC' and today = 'Y' or
700cA             pcmd = '*POEXCPC' and today = 'Y';
700aA            select;
700aA              when atyp = '2';
700aA                if hldata = 'Yes';
700aA                  pans = 'Y';
700aA                else;
700aA                  pans = 'N';
700aA                endif;
700aA              //when atyp = '3';
700aA                //chain (hlwhse: hlseq#: hlvsq#) haccpv1;
700aA                //if %found(haccpv1);
700aA                  //pans = %trim(hvdesc);
700aA                //endif;
700aA              other;
740bA                if hldata = 'HDNCHLD';
740bA                  pans = ' ';
740bA                else;
700aA                  pans = %trim(hldata);
740bA                endif;
700aA            endsl;
700aA          endif;

               exsr JsonQ1;
               exsr Append;

710aA        if hifreq = '6' and today = ' ';
710aA          leave;
710aA        endif;
             enddo;
           enddo;
         endfor;
         //enddo;


       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKLOG   Check for po receipt already done today
     *
     *----------------------------------------------------------------
      /free
       begsr zzchklog;
         today = ' ';
         select;
720cA    // freq 1 and non stock do not get asked
720cA      when hifreq = '1' and %subst(itdesg:5:1) = '*';
720cA        today = 'Y';
         // don't check on everytime question hifreq = 4  unless *PODTLCH
         // or *POEXCPC
700cD    //when hifreq = '4' and pcmd = '*PORCVCH';
700cM    when hifreq = '4' and pcmd = '*PORCVCH' or
700cA         hifreq = '4' and pcmd = '*POEXCPC';
700aA      setgt  (pwhse: ppo: pposeq: plicense: hiseq#) haccplog1;
700aA      readpe (pwhse: ppo: pposeq: plicense: hiseq#) haccplog1;
700aD      //setgt  (pwhse: ppo: pposeq: pitem: hiseq#) haccplog1;
700aD      //readpe (pwhse: ppo: pposeq: pitem: hiseq#) haccplog1;
           if not %eof(haccplog1);
             if hlexpts = *loval;
               today = 'Y';
             endif;
           endif;

         when hifreq = '4';

710aA    when hifreq = '5' or hifreq = '6';
710aA      exsr zzgettime;
710aA      exec sql select * into :hlrec1
710aA               from haccplog
710aA               where hlwhse = :pwhse
710aA               and hlseq# = :hiseq#
710aA               and hlobsolete <> 'Y'
710aA             order by hladdts desc
710aA             fetch first row only;
710aA      if sqlstt = sqlSuccess;
710aA        if  %date(hladdts) = %date(currstampsys);
710aA          today = 'Y';
710aA        endif;
710aA      endif;

750bA    // this was moved up
750bM    when pcmd = '*RANDOMC';
750bM      exec sql select * into :hlrec1
750bM               from haccplog
750bM               where hlwhse = :pwhse
750bM                 and hlseq# = :hiseq#
750bM                  //and hlsid = :hpsid
750bM                and hlexpts = '0001-01-01-00.00.00.000000'
750bM             and hlobsolete <> 'Y';
750bM      if sqlstt = sqlSuccess;
750bM          today = 'Y';
750bM      endif;
750bM    when pcmd = '*RANDOM' and hifreq = '5'
750bM     or  pcmd = '*RANDOM' and hifreq = '6';
750bM      exec sql select * into :hlrec1
750bM               from haccplog
750bM               where hlwhse = :pwhse
750bM                 and hlseq# = :hiseq#
750bM                and hlexpts = '0001-01-01-00.00.00.000000'
750bM             and hlobsolete <> 'Y';
750bM      if sqlstt = sqlSuccess;
750bM          today = 'Y';
750bM      endif;
700aA    // once per po check - super po check for gui from po list
700aA    when plevel = 'RCVI' and hifreq = '2' and hitype = 'CAT'
700aA           and psuperpo = ppo or
700aA         plevel = 'RCVI' and hifreq = '2' and hitype = 'DPT'
700aA           and psuperpo = ppo or
700aA         plevel = 'RCVI' and hifreq = '2' and hitype = 'ALL'
700aA           and psuperpo = ppo;
700aA      exec sql select * into :hlrec1
700aA               from haccplog
700aA               where hlwhse = :pwhse
700aA               and hlspo   = :ppo
700aA               and hlseq# = :hiseq#
700aA               and hlexpts = '0001-01-01-00.00.00.000000'
700aA               and hlobsolete <> 'Y'
700aA               fetch first row only;
700aA      if sqlstt = sqlSuccess;
700aA          today = 'Y';
700aA      endif;
         // once per po check
         when plevel = 'RCVI' and hifreq = '2' and hitype = 'CAT' or
              plevel = 'RCVI' and hifreq = '2' and hitype = 'DPT' or
              plevel = 'RCVI' and hifreq = '2' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM               and hlobsolete <> 'Y'
730aA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
740aA    // once per po verification check
740cM    when plevel = 'RCVV'
740cA      or plevel = 'RCVF';
740aA      exec sql select * into :phhrec
740aA             from pohhdr
740aA             where phhwhs = :pwhse
740aA               and phhpo  = :ppo
740aA               and phhedt = :pexpdate
740aA               and phheti = :pexptime;
740aA      if sqlstt = sqlSuccess;
740aA        pohdrexpdtts = CreateTS(phhedt: phheti);
740aA        exec sql select * into :hlrec1
740aA               from haccplog
740aA               where hlwhse = :pwhse
740aA               and hlpo   = :ppo
740aA               and hlseq# = :hiseq#
740aA               and hladdts > :pohdrexpdtts
740aA               and hlobsolete <> 'Y'
740aA             fetch first row only;
740aA        if sqlstt = sqlSuccess;
740aA          today = 'Y';
740aA        endif;
740aA      endif;

         // once per po check - exceptions
         when plevel = 'REXI' and hifreq = '2' and hitype = 'CAT' or
              plevel = 'REXI' and hifreq = '2' and hitype = 'DPT' or
              plevel = 'REXI' and hifreq = '2' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM               and hlobsolete <> 'Y'
730aA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

720dA    // once per po session check  - but no hpsid field populated
720dA    when plevel = 'RCVI' and hifreq = '3' and hitype = 'CAT'
720dA                         and hpsid = *loval or
720dA         plevel = 'RCVI' and hifreq = '3' and hitype = 'DPT'
720da                         and hpsid = *loval or
720dA         plevel = 'RCVI' and hifreq = '3' and hitype = 'ALL'
720dA                         and hpsid = *loval;

         // once per po session check
         when plevel = 'RCVI' and hifreq = '3' and hitype = 'CAT' or
              plevel = 'RCVI' and hifreq = '3' and hitype = 'DPT' or
              plevel = 'RCVI' and hifreq = '3' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                     and hlsid = :hpsid
                    and hlexpts = '0001-01-01-00.00.00.000000'
                    and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         // once per po session check exceptions
         when plevel = 'REXI' and hifreq = '3' and hitype = 'CAT' or
              plevel = 'REXI' and hifreq = '3' and hitype = 'DPT' or
              plevel = 'REXI' and hifreq = '3' and hitype = 'ALL';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                    and hlpo   = :ppo
                    and hlseq# = :hiseq#
                     and hlsid = :hpsid
                    and hlexpts = '0001-01-01-00.00.00.000000'
                    and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

720dA    // once per po session check  - but no hpsid field populated
720dA    when plevel = 'RCVI' and hifreq = '3' and hitype = 'ITM'
720dA                         and hpsid = *loval;

         when plevel = 'RCVI' and hifreq = '3' and hitype = 'ITM';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                     and hlposeq = :pposeq
                     and hllcns  = :plicense
                      and hlseq# = :hiseq#
                       and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         when plevel = 'REXI' and hifreq = '3' and hitype = 'ITM';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                     and hlposeq = :pposeq
                     and hllcns  = :plicense
                      and hlseq# = :hiseq#
                       and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

         // once per po
         when plevel = 'RCVH';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                      and hlseq# = :hiseq#
                     and hlexpts = '0001-01-01-00.00.00.000000'
730bM             and hlobsolete <> 'Y'
730bA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         // once per item per po
700bD    //when psuperpo = '*NO ' or
700bM    when psuperpo = ' ' or
720cD         //plevel = 'RCVI' and hifreq = '1' or
720cM         plevel = 'RCVI' and hifreq = '1' and %subst(itdesg:1:1) <> '*' or
              plevel = 'RCVI' and hifreq = '2' and hitype = 'ITM' or
              plevel = 'RCVL' or
720cD         //plevel = 'REXI' and hifreq = '1' or
720cM         plevel = 'RCVI' and hifreq = '1' and %subst(itdesg:1:1) <> '*' or
              plevel = 'REXI' and hifreq = '2' and hitype = 'ITM';
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                        and hlpo = :ppo
                     and hlposeq = :pposeq
                     and hllcns  = :plicense
                      and hlseq# = :hiseq#
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;

         other;
           // this will do super po check for the existence
           exec sql select * into :hlrec1
                    from haccplog
                    where hlwhse = :pwhse
                       and hlspo = :ppo
                     and hlposeq = :pposeq
                      and hllcns = :plicense
                      and hlseq# = :hiseq#
                     and hlexpts = '0001-01-01-00.00.00.000000'
730aM             and hlobsolete <> 'Y'
730aA             fetch first row only;
           if sqlstt = sqlSuccess or
              sqlstt = '21000';
               today = 'Y';
             // Now check to see if all po's linked to super po exist
             // in HACCPLOG need to ask questions for any po's linked
             // to super po after receipt has started.
             // Need to ask questons if new po was added.
             setll (pwhse: ppo) pospo;
             dow not %eof(pospo);
               reade (pwhse: ppo) pospo;
               if %eof(pospo);
                 leave;
               endif;
               exec sql select * into :hlrec1
                        from haccplog
                        where hlwhse = :pwhse
                            and hlpo = :pupo
                           and hlspo = :ppo
                         and hlposeq = :pposeq
                          and hllcns = :plicense
                          and hlseq# = :hiseq#
                         and hlexpts = '0001-01-01-00.00.00.000000'
730aM                 and hlobsolete <> 'Y'
730aA             fetch first row only;
               // already asked for this po.
               if sqlstt = sqlSuccess or
                 sqlstt = '21000';
               else;
               // needs to be asked for at least one po added.
                 today = 'N';
               endif;
             enddo;
           endif;
         endsl;
       endsr;
      /end-free

750aA*----------------------------------------------------------------
750aA*
750aA*  ZZEXCLUDE See if the question is excluded
750aA*
750aA*----------------------------------------------------------------
750aA /free
750aA  begsr zzexclude;
750aA    // do we have an exclusion for this question
750aA    // lets check for exclusion
750aA    ExcludeQstn = ' ';
750aA    exec sql select * into :herec
750aA         from HACCPe
750aA         where hewhse = :hiwhse
750aA           and helevl = :hilevl
750aA           and hetype = :hitype
750aA           and hecode = :hicode
750aA           and heseq# = :hiseq#
750aA         fetch first row only;
750aA    if sqlstt = sqlSuccess;
750aA      // we have to check the exclusion
750aA      // is there an exclusion for this question by vendor
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'V'
750aA             and hevend = :phven;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Dept
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'D'
750aA             and hedept = :itwhdp;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Item
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'I'
750aA             and heitem = :ititem;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Category
750aA      exec sql select * into :herec
750aA           from HACCPe
750aA           where hewhse = :hiwhse
750aA             and helevl = :hilevl
750aA             and hetype = :hitype
750aA             and hecode = :hicode
750aA             and heseq# = :hiseq#
750aA             and heetype = 'C'
750aA             and hecat  = :ifcat;
750aA      if sqlstt = sqlSuccess;
750aA        ExcludeQstn = 'Y';
750aA      endif;
750aA      // is there an exclusion for this question by Class
750aA      //  need to read all the classes assigned to item
750aA      setll (itwhse: ititem) itemcls;
750aA      dow forever = forever;
750aA        reade (itwhse: ititem) itemcls;
750aA        if %eof(itemcls);
750aA          leave;
750aA        endif;
750aA        exec sql select * into :herec
750aA             from HACCPe
750aA             where hewhse = :hiwhse
750aA               and helevl = :hilevl
750aA               and hetype = :hitype
750aA               and hecode = :hicode
750aA               and heseq# = :hiseq#
750aA               and heetype = 'L'
750aA               and heclass= :iclcde;
750aA        if sqlstt = sqlSuccess;
750aA          ExcludeQstn = 'Y';
750aA          leave;
750aA        endif;
750aA      enddo;
750aA    endif;
750aA  endsr;
750aA /end-free

710aA*----------------------------------------------------------------
710aA*
710aA*  ZZGETTIME Get Timestamp information.
710aA*
710aA*----------------------------------------------------------------
710aA /free
710aA  begsr zzgettime;
710aA    getmicrotime(currstampuc:currstampsys);
710aA  endsr;
710aA /end-free

740aA*----------------------------------------------------------------
740aA*  CreateTS   Create timestamp from Date/Time
740aA*----------------------------------------------------------------

740aAp CreateTS        b
740aAd CreateTS        pi              z
740aAd  date                          8p 0 const
740aAd  time                          6p 0 const

740aA*  Local Variables

740aAD stamp           s               z
740aAD temp26          s             26

740aAD                 ds
740aAD  yyyymmdd               1      8s 0
740aAD    yyyy                 1      4
740aAD    mm                   5      6
740aAD    dd                   7      8

740aAD                 ds
740aAD  hhmiss                 1      6s 0
740aAD    hh                   1      2
740aAD    mi                   3      4
740aAD    ss                   5      6


740aA /free

740aA   clear stamp;

740aA   if date = 0;
740aA     return stamp;
740aA   endif;

740aA   yyyymmdd = date;
740aA   hhmiss = time;
740aA   temp26 = yyyy + '-' + mm + '-' + dd + '-'
740aA          + hh + '.' + mi + '.' + ss + '.000000';

740aA   monitor;
740aA     stamp = %timestamp(temp26);
740aA   on-error;
740aA     clear stamp;
740aA   endmon;

740aA   return stamp;

740aA /end-free

740aAp CreateTS        e

