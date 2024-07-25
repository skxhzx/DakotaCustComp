      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PCMGETQTR  Get PCM TRAX Questions
     *  09 March 2018
     *  Lynn McMahon
     *
     *  Revisions:
     *
720 A*    03/09/18  LMC  7.20
     *      - Created.
     *      - Copied fom PCMGETQ - for gui
     *
730aA*    12/20/19  LMC  7.30a
     *      - Added logic for customer questions
740aA*    05/19/20  LMC  7.40a
     *      - Added logic reactive(child) questions.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fhaccpq3   if   e           k disk
     Fhaccpv1   if   e           k disk
     F*glosess   if   e           k disk
     f*haccplog1 if   e           k disk
     f*haccplog2 if   e           k disk    rename(hlrec:hl3) prefix(h3_)
     Fhaccpqt   if   e           k disk
     Fpospo     if   e           k disk
     Fpospo1    if   e           k disk    rename(purec:spurec)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCallNum    Call number
     *      pUser       User
     *      pPgm        Program
     *      pCmd        Command
     *      pWhse       Warehouse
     *      pLevel      Level  -  *ALL = Get all active recs
     *      pType       Type
     *
     *    Returned Parameters
     *      pXML        XML String
     *
     *----------------------------------------------------------------

     D*pcmgetqtr       pr                  extpgm('PCMGETQTR')
     D* pCallNum                      1p 0
     D* pUser                        10    varying
     D* pPgm                         20
     D* pCmd                          8    varying
     D* pWhse                         3  0
     D* pLevel                        4    varying
     D* pType                         3    varying
     D* pXML                      20000A   varying

     D*pcmgetq         pi
     D* pCallNum                      1p 0
     D* pUser                        10    varying
     D* pPgm                         20
     D* pCmd                          8    varying
     D* pWhse                         3  0
     D* pLevel                        4    varying
     D* pType                         3    varying
     D* pXML                      20000    varying

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

     D currStr         s          20000A   varying
     D validanswer     s           1000A   varying
     D validanswerseq  s           1000A   varying
     D gotone          s              1    inz(' ')

     D clr             s              7    varying
     D delimiter       s              1    varying
     D delimiter2      s              1    varying
     D space           s              1    inz(' ')
     d dblqte          s              1    inz('"')

     D id              s              5  0
740aAD pid             s              5  0
     D qorder          s              2  0
     D lvl             s              4    varying
     D typ             s              3    varying
     D cod             s             15    varying
     D q               s             45    varying
     D atyp            s              1    varying
     D rqd             s              1    varying
     D rng1            s             15    varying
     D rng2            s             15    varying
     D rwrn            s             30    varying
     D group           s             25    varying
740aAD pidans          s             30    varying


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

     D $code           s             15
     D morelicense     s              1
     D morequestions   s              1
     D savetype        s              3
     D today           s              1
     D laitem          s             15
     D  pCallNum       s              1p 0
     D  pCmd           s              8    varying
     D  pWhse          s              3  0
     D  pLevel         s              4    varying
     D  pType          s              3    varying
     D  pUser          s             10    varying
     D  ppgm           s             20
     D* pxml           s          20000    varying
730aAD  custcode       s             15    varying
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D CurrStampBeg    s               z
     D CurrStampEnd    s               z

     D bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

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

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D hirec3        E Ds                  Extname(HACCPQ3) prefix(ck_)
     D*horec         e ds                  extname(pirhold)
     D*hlrec1        e ds                  extname(haccplog)
740aAD hdrec         E Ds                  Extname(HACCPQc)


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
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pCallNum
     c                   parm                    pUser
     c                   parm                    ppgm
     c                   parm                    pcmd
     c                   parm                    pwhse
     c                   parm                    plevel
     c                   parm                    ptype
     c                   parm                    currstr
730aAc                   parm                    custcode

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------


      /free
         *inlr = *on;

         // Convert inputs to uppercase

         chrUser = %trim(pUser);

         pCmd     = %xlate(xlower: xupper: pCmd);
         pLevel   = %xlate(xlower: xupper: pLevel);
         pType    = %xlate(xlower: xupper: pType);

         exsr GetMatchingRecs;


       return;
      /end-free


     *----------------------------------------------------------------
     *  xmlqst    Setup xml for questions
     *----------------------------------------------------------------

      /free
       begsr xmlqst;

         // with xml need the additional fields set for all types.
         // set the fields with blanks if they don't apply for these types

         select;

           when atyp = '2';
             validanswer = 'Y,N';
             validanswerseq = ' ';

           when atyp = '3';
             exsr xmlType3;

           when atyp = '5';
             exsr xmlRange;

           when atyp = '8';
             exsr xmlRange;

           other;
             validanswer = ' ';
             validanswerseq = ' ';
         endsl;
         // Start question string with std fields

         currStr = currstr
                 + space
                 + 'questionGroup=' +dblqte + (group) + dblqte + space
                 + 'questionNumber=' +dblqte + %char(id)+dblqte + space
                 + 'questionSequence=' +dblqte+ %char(qorder)+dblqte + space
                 + 'question=' +dblqte + (q)+dblqte + space
                 + 'answerType=' +dblqte + (atyp)+dblqte + space
                 + 'answerRequired=' +dblqte + (rqd)+dblqte + space
                 + 'validAnswers=' +dblqte + %triml(validanswer)+dblqte + space
                 + 'validAnswersSequence=' +dblqte
                 + %triml(validanswerseq)+dblqte + space
740aA            + 'reactiveParent=' +dblqte + %char(pid)+dblqte + space
740aA            + 'reactiveParentTrigger=' +dblqte + (pidans)+dblqte + space
                 + 'printable=' +dblqte + 'N' + dblqte + space ;


         // End question


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  xmlType3   Add return values to string for Question
     *              Type 3 - Values from HACCPV file
     *
     *
     *----------------------------------------------------------------

      /free
       begsr xmlType3;

         gotone = ' ';
         validanswer = ' ';
         validanswerseq = ' ';
         // get valid answers
         setll (hiwhse: hiseq#) haccpv1;
         dow forever = forever;
           reade (hiwhse: hiseq#) haccpv1;
           if %eof(haccpv1);
             leave;
           endif;
           // load validanswer
           if gotone = 'Y';
             validanswer = validanswer + ',';
             validanswerseq = validanswerseq + ',';
           endif;
           validanswer = validanswer + %trimr(hvdesc);
           validanswerseq = validanswerseq + %char(HVVSQ#);
           gotone = 'Y';
         enddo;

         // Add to string as a dropdown


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  xmlRange  Add range to question string
     *----------------------------------------------------------------

      /free
       begsr xmlRange;

         // Get record containing range

         validanswer = ' ';
         validanswerseq = ' ';
         setll (hiwhse: hiseq#) haccpv1;
         reade (hiwhse: hiseq#) haccpv1;
         if not %found(haccpv1);
         else;
           select;
             when atyp = '5';
               validanswer = %char(hvt5vl) + ',' + %char(hvt5rg);
             when atyp = '8';
               validanswer = %char(hvvalu) + ',' + %char(hvvalr);
             other;
           endsl;
         endif;

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



         for i = 1 to 2;
           i=2;
           hbtype = ptype;
           hblevl = plevel;


           // get heading for special user type selection
           chain (pwhse: plevel: ptype) haccpqt;
           if %found(haccpqt);
             //hldspecdesc = hbdesc;
           else;
             //hldspecdesc = ' ';
           endif;

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
               leave;
             endif;

             if morequestions = ' ';
               $code = ' ';
             endif;

             select;
               when morequestions = 'Y';
730aA            when hbtype = 'CS1';
730aA              $code = custcode;
730aA            when hbtype = 'CS2';
730aA              $code = custcode;
               //when hbtype = 'CAT';
                 //$code = ifcat;
               //when hbtype = 'ITM';
                 //$code = ititem;
               //when hbtype = 'DPT';
                 //$code = itwhdp;
               //when hbtype = 'VEN';
                 //$code = %trim(%editc(phven:'Z'));
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

740aA          // this is no longer needed. Will process all questions
740aA          // pCallNum will be a 0.
               // pCallNum = 0 load only parent questions.
               // pCallNum = 1 load only child questions.
               select;
                 when pCallNum = 0;
740aA              // we will not load Reactive questions until Trax
740aA              // software is ready
740aA              //if hipc = 'R';
740aA                //iter;
740aA              //endif;
740aA              // get parent for reactive
740aA              exsr GetParentInfo;
                   //if hipc = 'C';
                     //iter;
                   //endif;
                 when pCallNum = 1;
                   //if hipc = 'P';
                     //iter;
                   //endif;
                 when pCallNum = 1;
                   //if hipc = ' ';
                     //iter;
                   //endif;
               endsl;

               group = %trimr(hbdesc);
               id = hiseq#;
               q = %trimr(hiqstn);
               atyp = %trimr(hiatyp);
               qorder = HIPGSQ;
               rqd = %trimr(hireqd);
740aA          pid = hdpseq#;
740aA          pidans = %trimr(hdvalu);

               exsr xmlqst;

             enddo;
           enddo;
         endfor;


       endsr;
      /end-free

740aA*----------------------------------------------------------------
740aA*  GetParentInfo     Get Parent Info for Reactive questions
740aA*----------------------------------------------------------------

740aA /free
740aA  begsr GetParentInfo;
740aA      exec sql select * into :hdrec
740aA               from haccpqc
740aA               where hdwhse = :pwhse
740aA                 and hdseq# = :hiseq#
740aA                 fetch first row only;
740aA      If sqlstt <> sqlSuccess;
740aA        hdpseq# = 0;
740aA        hdvalu = ' ';
740aA      endif;
740aA  endsr;
740aA /end-free
     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
       endsr;
      /end-free

