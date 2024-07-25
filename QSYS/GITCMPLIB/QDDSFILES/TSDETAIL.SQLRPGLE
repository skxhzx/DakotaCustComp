      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSDETAIL  SQL View for PS313WF Detail Data
     *  10 September 2018
     *  Kenneth Elder
     *
     *  Revisions
     *
720 A*    09/10/18  KDE  7.20
     *      - Created.
     *
740 A*    08/26/20  KDE  7.40
     *      - Change cube values from 5.2 to 7.2
     *
750 A*    05/05/21  KDE  7.50
     *      - Add two fields to hold Super Route children
     *        routes
     *
750aA*    05/27/21  KDE  7.50a
     *      - Add additional field to hold two more child routes
     *        for super route.  Will create additional lines after that
     *
760aA*    09/15/22  KDE  7.60a
     *      - Substring for PSld to hold two more child routes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Dealing with numeric fields
     *
     *   - The SQL 'zoned' function is used to create numeric fields.
     *   - To ensure that the characters are not blank, the 'translate'
     *     function is also used to convert blanks into zeros.
     *   - If the field contains any other non-numeric characters,
     *     the field will end up with invalid data.
     *   - Example code for a zero decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opdata,1,7,''0'','' '')'
     *       + ',7,0)'
     *   - Example code for a 2 decimal field:
     *       + 'zoned('
     *       +   'translate(substr(opdata,16,3,''0'','' '')'
     *       +   '||''.''||'
     *       +   'translate(substr(opdata,19,2,''0'','' '')'
     *       + ',5,2)'
     *
     *----------------------------------------------------------------

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

     D  code           s              8
     D  debugStr1      s           1000
     D  debugStr2      s           1000
     D  file           s             10
     D  dsplyMsg       s             52
     D  pfLibFile      s             21
     D  view           s             10
     D  viewLibFile    s             21
     d  sqlStmtLarge   s           8192

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pPFLib         s             10
     D  pViewLib       s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pPFLib       Library where PF is located
     *      pViewLib     Library where View is to be created
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pPFLib
     c                   parm                    pViewLib

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Verify parameters have been sent in

        if %parms < 2
          or pPFLib = ''
          or pViewLib = '';
            dsplyMsg = 'Error: Missing Parm - '
                     + 'CALL OPSGENPICK (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Initialize variables

        file = 'PS313WF';
        view = 'TSDETAIL';
        pfLibFile = %trim(pPFLib) + '/' + file;
        viewLibFile = %trim(pViewLib) + '/' + view;

        // First, delete existing view

        sqlstmtLarge = 'drop view ' + %trimr(viewLibFile);

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess and sqlstt <> sqlUndefObject;
          dsplyMsg = 'Drop Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Create file

        sqlstmtLarge = 'create view ' + %trimr(viewLibFile) + ' '
                + '('
                +   'pswwhse,'
                +   'pswrtid,'
                +   'pswrecf,'
                +   'pswrow,'
                +   'pswspin1,'
                +   'pswpick1,'
                +   'pswcube1,'
                +   'pswstp11,'
                +   'pswstp21,'
                +   'pswdoor1,'
                +   'pswspcs1,'
                +   'pswrtpa1,'
                +   'pswwgt1,'
                +   'pswsscc1,'
                +   'pswpal#1,'
                +   'pswpcmp1,'
                +   'pswplid1,'
                +   'pswbgc1,'
                +   'pswspin2,'
                +   'pswpick2,'
                +   'pswcube2,'
                +   'pswstp12,'
                +   'pswstp22,'
                +   'pswdoor2,'
                +   'pswspcs2,'
                +   'pswrtpa2,'
                +   'pswwgt2,'
                +   'pswsscc2,'
                +   'pswpal#2,'
                +   'pswpcmp2,'
                +   'pswplid2,'
                +   'pswbgc2,'
                +   'pswspin3,'
                +   'pswpick3,'
                +   'pswcube3,'
                +   'pswstp13,'
                +   'pswstp23,'
                +   'pswdoor3,'
                +   'pswspcs3,'
                +   'pswrtpa3,'
                +   'pswwgt3,'
                +   'pswsscc3,'
                +   'pswpal#3,'
                +   'pswpcmp3,'
                +   'pswplid3,'
                +   'pswbgc3,'
                +   'pswspin4,'
                +   'pswpick4,'
                +   'pswcube4,'
                +   'pswstp14,'
                +   'pswstp24,'
                +   'pswdoor4,'
                +   'pswspcs4,'
                +   'pswrtpa4,'
                +   'pswwgt4,'
                +   'pswsscc4,'
                +   'pswpal#4,'
                +   'pswpcmp4,'
                +   'pswplid4,'
                +   'pswbgc4,'
                +   'pswspin5,'
                +   'pswpick5,'
                +   'pswcube5,'
                +   'pswstp15,'
                +   'pswstp25,'
                +   'pswdoor5,'
                +   'pswspcs5,'
                +   'pswrtpa5,'
                +   'pswwgt5,'
                +   'pswsscc5,'
                +   'pswpal#5,'
                +   'pswpcmp5,'
                +   'pswplid5,'
                +   'pswbgc5,'
                +   'pswspin6,'
                +   'pswpick6,'
                +   'pswcube6,'
                +   'pswstp16,'
                +   'pswstp26,'
                +   'pswdoor6,'
                +   'pswspcs6,'
                +   'pswrtpa6,'
                +   'pswwgt6,'
                +   'pswsscc6,'
                +   'pswpal#6,'
                +   'pswpcmp6,'
                +   'pswplid6,'
                +   'pswbgc6,'
                +   'pswspin7,'
                +   'pswpick7,'
                +   'pswcube7,'
                +   'pswstp17,'
                +   'pswstp27,'
                +   'pswdoor7,'
                +   'pswspcs7,'
                +   'pswrtpa7,'
                +   'pswwgt7,'
                +   'pswsscc7,'
                +   'pswpal#7,'
                +   'pswpcmp7,'
                +   'pswplid7,'
                +   'pswbgc7,'
                +   'pswspin8,'
                +   'pswpick8,'
                +   'pswcube8,'
                +   'pswstp18,'
                +   'pswstp28,'
                +   'pswdoor8,'
                +   'pswspcs8,'
                +   'pswrtpa8,'
                +   'pswwgt8,'
                +   'pswsscc8,'
                +   'pswpal#8,'
                +   'pswpcmp8,'
                +   'pswplid8,'
                +   'pswbgc8,'
                +   'pswspin9,'
                +   'pswpick9,'
                +   'pswcube9,'
                +   'pswstp19,'
                +   'pswstp29,'
                +   'pswdoor9,'
                +   'pswspcs9,'
                +   'pswrtpa9,'
                +   'pswwgt9,'
                +   'pswsscc9,'
                +   'pswpal#9,'
                +   'pswpcmp9,'
                +   'pswplid9,'
                +   'pswbgc9,'
                +   'pssrlst11,'
                +   'pssrlst12,'
                +   'pssrlst21,'
                +   'pssrlst22,'
                +   'pssrlst31,'
                +   'pssrlst32,'
                +   'pssrlst41,'
                +   'pssrlst42,'
                +   'pssrlst51,'
                +   'pssrlst52,'
                +   'pssrlst61,'
                +   'pssrlst62,'
                +   'pssrlst71,'
                +   'pssrlst72,'
                +   'pssrlst81,'
                +   'pssrlst82,'
                +   'pssrlst91,'
                +   'pssrlst92'
                + ') '
                + 'as ('
                + 'select '
                +   'pswwhse,'
                +   'pswrtid,'
                +   'pswrecf,'
                +   'pswrow,'
       //                                     1   4 PSWSPIN1
                +   'substr(pswdata,1,4),'
       //                                     5   8 PSWPICK1
                +   'substr(pswdata,5,4),'
       //                                     9  1522PSWCUBE1
                +   'zoned('
                +   'translate(substr(pswdata,9,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,14,2),''0'','' '')'
                +   ',7,2),'
       //                                    16  180PSWSTP11
                +   'zoned('
                +     'translate(substr(pswdata,16,3),''0'','' '')'
                +   ',3,0),'
       //                                    19  210PSWSTP21
                +   'zoned('
                +     'translate(substr(pswdata,19,3),''0'','' '')'
                +   ',3,0),'
       //                                    22  240PSWDOOR1
                +   'zoned('
                +     'translate(substr(pswdata,22,3),''0'','' '')'
                +   ',3,0),'
       //                                    25  290PSWSPCS1
                +   'zoned('
                +     'translate(substr(pswdata,25,5),''0'','' '')'
                +   ',5,0),'
       //                                    30  36 PSWRTPA1
                +   'substr(pswdata,30,7),'
       //                                    37  420PSWWGT1
                +   'zoned('
                +     'translate(substr(pswdata,37,6),''0'','' '')'
                +   ',6,0),'
       //                                    43  49 PSWSSCC1
                +   'substr(pswdata,43,7),'
       //                                    50  540PSWPAL#1
                +   'zoned('
                +     'translate(substr(pswdata,50,5),''0'','' '')'
                +   ',5,0),'
       //                                    55  58 PSWPCMP1
                +   'substr(pswdata,55,4),'
       //                                    59  65 PSWPLID1
                +   'substr(pswdata,59,7),'
       //                                    66  72 PSWBGC1
                +   'substr(pswdata,66,7),'
       //                                    73  76 PSWSPIN2
                +   'substr(pswdata,73,4),'
       //                                    77  80 PSWPICK2
                +   'substr(pswdata,77,4),'
       //                                    81  872PSWCUBE2
                +   'zoned('
                +   'translate(substr(pswdata,81,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,86,2),''0'','' '')'
                +   ',7,2),'
       //                                    88  900PSWSTP12
                +   'zoned('
                +     'translate(substr(pswdata,88,3),''0'','' '')'
                +   ',3,0),'
       //                                    91  930PSWSTP22
                +   'zoned('
                +     'translate(substr(pswdata,91,3),''0'','' '')'
                +   ',3,0),'
       //                                    94  960PSWDOOR2
                +   'zoned('
                +     'translate(substr(pswdata,94,3),''0'','' '')'
                +   ',3,0),'
       //                                    97 1010PSWSPCS2
                +   'zoned('
                +     'translate(substr(pswdata,97,5),''0'','' '')'
                +   ',5,0),'
       //                                   102 108 PSWRTPA2
                +   'substr(pswdata,102,7),'
       //                                   109 1140PSWWGT2
                +   'zoned('
                +     'translate(substr(pswdata,109,6),''0'','' '')'
                +   ',6,0),'
       //                                   115 121 PSWSSCC2
                +   'substr(pswdata,115,7),'
       //                                   122 1260PSWPAL#2
                +   'zoned('
                +     'translate(substr(pswdata,122,5),''0'','' '')'
                +   ',5,0),'
       //                                   127 130 PSWPCMP2
                +   'substr(pswdata,127,4),'
       //                                   131 137 PSWPLID2
                +   'substr(pswdata,131,7),'
       //                                   138 144 PSWBGC2
                +   'substr(pswdata,138,7),'
       //                                   145 148 PSWSPIN3
                +   'substr(pswdata,145,4),'
       //                                   149 152 PSWPICK3
                +   'substr(pswdata,149,4),'
       //                                   153 1592PSWCUBE3
                +   'zoned('
                +   'translate(substr(pswdata,153,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,158,2),''0'','' '')'
                +   ',7,2),'
       //                                   160 1620PSWSTP13
                +   'zoned('
                +     'translate(substr(pswdata,160,3),''0'','' '')'
                +   ',3,0),'
       //                                   163 1650PSWSTP23
                +   'zoned('
                +     'translate(substr(pswdata,163,3),''0'','' '')'
                +   ',3,0),'
       //                                   166 1680PSWDOOR3
                +   'zoned('
                +     'translate(substr(pswdata,166,3),''0'','' '')'
                +   ',3,0),'
       //                                   169 1730PSWSPCS3
                +   'zoned('
                +     'translate(substr(pswdata,169,5),''0'','' '')'
                +   ',5,0),'
       //                                   174 180 PSWRTPA3
                +   'substr(pswdata,174,7),'
       //                                   181 1860PSWWGT3
                +   'zoned('
                +     'translate(substr(pswdata,181,6),''0'','' '')'
                +   ',6,0),'
       //                                   187 193 PSWSSCC3
                +   'substr(pswdata,187,7),'
       //                                   194 1980PSWPAL#3
                +   'zoned('
760aD  //       +     'translate(substr(pswdata,193,5),''0'','' '')'
760aM           +     'translate(substr(pswdata,194,5),''0'','' '')'
                +   ',5,0),'
       //                                   199 202 PSWPCMP3
                +   'substr(pswdata,199,4),'
       //                                   203 209 PSWPLID3
                +   'substr(pswdata,203,7),'
       //                                   210 216 PSWBGC3
                +   'substr(pswdata,210,7),'
       //                                   217 220 PSWSPIN4
                +   'substr(pswdata,217,4),'
       //                                   221 224 PSWPICK4
                +   'substr(pswdata,221,4),'
       //                                   225 2312PSWCUBE4
                +   'zoned('
                +   'translate(substr(pswdata,225,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,230,2),''0'','' '')'
                +   ',7,2),'
       //                                   232 2340PSWSTP14
                +   'zoned('
                +     'translate(substr(pswdata,232,3),''0'','' '')'
                +   ',3,0),'
       //                                   235 2370PSWSTP24
                +   'zoned('
                +     'translate(substr(pswdata,235,3),''0'','' '')'
                +   ',3,0),'
       //                                   238 2400PSWDOOR4
                +   'zoned('
                +     'translate(substr(pswdata,238,3),''0'','' '')'
                +   ',3,0),'
       //                                   241 2450PSWSPCS4
                +   'zoned('
                +     'translate(substr(pswdata,241,5),''0'','' '')'
                +   ',5,0),'
       //                                   246 252 PSWRTPA4
                +   'substr(pswdata,246,7),'
       //                                   253 2580PSWWGT4
                +   'zoned('
                +     'translate(substr(pswdata,253,6),''0'','' '')'
                +   ',6,0),'
       //                                   259 265 PSWSSCC4
                +   'substr(pswdata,259,7),'
       //                                   266 2700PSWPAL#4
                +   'zoned('
                +     'translate(substr(pswdata,266,5),''0'','' '')'
                +   ',5,0),'
       //                                   271 274 PSWPCMP4
                +   'substr(pswdata,271,4),'
       //                                   275 281 PSWPLID4
                +   'substr(pswdata,275,7),'
       //                                   282 288 PSWBGC4
                +   'substr(pswdata,282,7),'
       //                                   289 292 PSWSPIN5
                +   'substr(pswdata,289,4),'
       //                                   293 296 PSWPICK5
                +   'substr(pswdata,293,4),'
       //                                   297 3032PSWCUBE5
                +   'zoned('
                +   'translate(substr(pswdata,297,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,302,2),''0'','' '')'
                +   ',7,2),'
       //                                   304 3060PSWSTP15
                +   'zoned('
                +     'translate(substr(pswdata,304,3),''0'','' '')'
                +   ',3,0),'
       //                                   307 3090PSWSTP25
                +   'zoned('
                +     'translate(substr(pswdata,307,3),''0'','' '')'
                +   ',3,0),'
       //                                   310 3120PSWDOOR5
                +   'zoned('
                +     'translate(substr(pswdata,310,3),''0'','' '')'
                +   ',3,0),'
       //                                   313 3170PSWSPCS5
                +   'zoned('
                +     'translate(substr(pswdata,313,5),''0'','' '')'
                +   ',5,0),'
       //                                   318 324 PSWRTPA5
                +   'substr(pswdata,318,7),'
       //                                   325 3300PSWWGT5
                +   'zoned('
                +     'translate(substr(pswdata,325,6),''0'','' '')'
                +   ',6,0),'
       //                                   331 337 PSWSSCC5
                +   'substr(pswdata,331,7),'
       //                                   338 3420PSWPAL#5
                +   'zoned('
                +     'translate(substr(pswdata,338,5),''0'','' '')'
                +   ',5,0),'
       //                                   343 346 PSWPCMP5
                +   'substr(pswdata,343,4),'
       //                                   347 353 PSWPLID5
                +   'substr(pswdata,353,7),'
       //                                   354 360 PSWBGC5
                +   'substr(pswdata,354,7),'
       //                                   361 364 PSWSPIN6
                +   'substr(pswdata,361,4),'
       //                                   365 368 PSWPICK6
                +   'substr(pswdata,365,4),'
       //                                   369 3752PSWCUBE6
                +   'zoned('
                +   'translate(substr(pswdata,369,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,374,2),''0'','' '')'
                +   ',7,2),'
       //                                   376 3780PSWSTP16
                +   'zoned('
                +     'translate(substr(pswdata,376,3),''0'','' '')'
                +   ',3,0),'
       //                                   379 3810PSWSTP26
                +   'zoned('
                +     'translate(substr(pswdata,379,3),''0'','' '')'
                +   ',3,0),'
       //                                   382 3840PSWDOOR6
                +   'zoned('
                +     'translate(substr(pswdata,382,3),''0'','' '')'
                +   ',3,0),'
       //                                   385 3890PSWSPCS6
                +   'zoned('
                +     'translate(substr(pswdata,385,5),''0'','' '')'
                +   ',5,0),'
       //                                   390 396 PSWRTPA6
                +   'substr(pswdata,390,7),'
       //                                   397 4020PSWWGT6
                +   'zoned('
                +     'translate(substr(pswdata,397,6),''0'','' '')'
                +   ',6,0),'
       //                                   403 409 OPSWSSCC6
                +   'substr(pswdata,403,7),'
       //                                   410 4140PSWPAL#6
                +   'zoned('
                +     'translate(substr(pswdata,410,5),''0'','' '')'
                +   ',5,0),'
       //                                   415 418 PSWPCMP6
                +   'substr(pswdata,415,4),'
       //                                   419 425 PSWPLID6
                +   'substr(pswdata,419,7),'
       //                                   426 432 PSWBGC6
                +   'substr(pswdata,426,7),'
       //                                   433 436 PSWSPIN7
                +   'substr(pswdata,433,4),'
       //                                   437 440 PSWPICK7
                +   'substr(pswdata,437,4),'
       //                                   441 4472PSWCUBE7
                +   'zoned('
                +   'translate(substr(pswdata,441,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,446,2),''0'','' '')'
                +   ',7,2),'
       //                                   448 4500PSWSTP17
                +   'zoned('
                +     'translate(substr(pswdata,448,3),''0'','' '')'
                +   ',3,0),'
       //                                   451 4530PSWSTP27
                +   'zoned('
                +     'translate(substr(pswdata,451,3),''0'','' '')'
                +   ',3,0),'
       //                                   454 4560PSWDOOR7
                +   'zoned('
                +     'translate(substr(pswdata,454,3),''0'','' '')'
                +   ',3,0),'
       //                                   457 4610PSWSPCS7
                +   'zoned('
                +     'translate(substr(pswdata,457,5),''0'','' '')'
                +   ',5,0),'
       //                                   462 468 PSWRTPA7
                +   'substr(pswdata,462,7),'
       //                                   469 4740PSWWGT7
                +   'zoned('
                +     'translate(substr(pswdata,469,6),''0'','' '')'
                +   ',6,0),'
       //                                   475 481 PSWSSCC7
                +   'substr(pswdata,475,7),'
       //                                   482 4860PSWPAL#7
                +   'zoned('
                +     'translate(substr(pswdata,482,5),''0'','' '')'
                +   ',5,0),'
       //                                   487 490 PSWPCMP7
                +   'substr(pswdata,487,4),'
       //                                   491 497 PSWPLID7
                +   'substr(pswdata,491,7),'
       //                                   498 504 PSWBGC7
                +   'substr(pswdata,498,7),'
       //                                   505 508 PSWSPIN8
                +   'substr(pswdata,505,4),'
       //                                   509 512 PSWPICK8
                +   'substr(pswdata,509,4),'
       //                                   513 5192PSWCUBE8
                +   'zoned('
                +   'translate(substr(pswdata,513,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,518,2),''0'','' '')'
                +   ',7,2),'
       //                                   520 5220PSWSTP18
                +   'zoned('
                +     'translate(substr(pswdata,520,3),''0'','' '')'
                +   ',3,0),'
       //                                   523 5250PSWSTP28
                +   'zoned('
                +     'translate(substr(pswdata,523,3),''0'','' '')'
                +   ',3,0),'
       //                                   526 5280PSWDOOR8
                +   'zoned('
                +     'translate(substr(pswdata,526,3),''0'','' '')'
                +   ',3,0),'
       //                                   529 5330PSWSPCS8
                +   'zoned('
                +     'translate(substr(pswdata,529,5),''0'','' '')'
                +   ',5,0),'
       //                                   534 540 PSWRTPA8
                +   'substr(pswdata,534,7),'
       //                                   541 5460PSWWGT8
                +   'zoned('
                +     'translate(substr(pswdata,541,6),''0'','' '')'
                +   ',6,0),'
       //                                   547 553 PSWSSCC8
                +   'substr(pswdata,547,7),'
       //                                   554 5580PSWPAL#8
                +   'zoned('
                +     'translate(substr(pswdata,554,5),''0'','' '')'
                +   ',5,0),'
       //                                   559 562 PSWPCMP8
                +   'substr(pswdata,559,4),'
       //                                   563 569 PSWPLID8
                +   'substr(pswdata,563,7),'
       //                                   570 576 PSWBGC8
                +   'substr(pswdata,570,7),'
       //                                   577 580 PSWSPIN9
                +   'substr(pswdata,577,4),'
       //                                   581 584 PSWPICK9
                +   'substr(pswdata,581,4),'
       //                                   585 5912PSWCUBE9
                +   'zoned('
                +   'translate(substr(pswdata,585,5),''0'','' '')'
                +   '||''.''||'
                +     'translate(substr(pswdata,590,2),''0'','' '')'
                +   ',7,2),'
       //                                   592 5940PSWSTP19
                +   'zoned('
                +     'translate(substr(pswdata,592,3),''0'','' '')'
                +   ',3,0),'
       //                                   595 5970PSWSTP29
                +   'zoned('
                +     'translate(substr(pswdata,595,3),''0'','' '')'
                +   ',3,0),'
       //                                   598 6000PSWDOOR9
                +   'zoned('
                +     'translate(substr(pswdata,598,3),''0'','' '')'
                +   ',3,0),'
       //                                   601 6050PSWSPCS9
                +   'zoned('
                +     'translate(substr(pswdata,601,5),''0'','' '')'
                +   ',5,0),'
       //                                   606 612 PSWRTPA9
                +   'substr(pswdata,606,7),'
       //                                   613 6180PSWWGT9
                +   'zoned('
                +     'translate(substr(pswdata,613,6),''0'','' '')'
                +   ',6,0),'
       //                                   619 625 PSWSSCC9
                +   'substr(pswdata,619,7),'
       //                                   626 6300PSWPAL#9
                +   'zoned('
                +     'translate(substr(pswdata,626,5),''0'','' '')'
                +   ',5,0),'
       //                                   631 634 PSWPCMP9
                +   'substr(pswdata,631,4),'
       //                                   635 641 PSWPLID9
                +   'substr(pswdata,635,7),'
       //                                   642 648 PSWBGC9
                +   'substr(pswdata,642,7),'
       //                                   649 665 PSSRLST11
                +   'substr(pswdata,649,17),'
       //                                   666 682 PSSRLST12
                +   'substr(pswdata,666,17),'
       //                                   683 699 PSSRLST21
                +   'substr(pswdata,683,17),'
       //                                   700 716 PSSRLST22
                +   'substr(pswdata,700,17),'
       //                                   717 733 PSSRLST31
                +   'substr(pswdata,717,17),'
       //                                   734 750 PSSRLST32
                +   'substr(pswdata,734,17),'
       //                                   751 767 PSSRLST41
                +   'substr(pswdata,751,17),'
       //                                   768 784 PSSRLST42
                +   'substr(pswdata,768,17),'
       //                                   785 801 PSSRLST51
                +   'substr(pswdata,785,17),'
       //                                   802 818 PSSRLST52
                +   'substr(pswdata,802,17),'
       //                                   819 835 PSSRLST61
                +   'substr(pswdata,819,17),'
       //                                   836 852 PSSRLST62
                +   'substr(pswdata,836,17),'
       //                                   853 869 PSSRLST71
                +   'substr(pswdata,853,17),'
       //                                   870 886 PSSRLST72
                +   'substr(pswdata,870,17),'
       //                                   887 903 PSSRLST81
                +   'substr(pswdata,887,17),'
       //                                   904 920 PSSRLST82
                +   'substr(pswdata,904,17),'
       //                                   921 937 PSSRLST91
                +   'substr(pswdata,921,17),'
       //                                   938 954 PSSRLST92
                +   'substr(pswdata,938,17)'
                + ' from ' + %trim(pfLibFile)
                + ' where pswrpttp = ' + sq + 'D' + sq
                + ')';

        debugStr1 = %subst(sqlstmtLarge:1:1000);
        debugStr2 = %subst(sqlstmtLarge:1001);

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Create Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
          dsplyMsg = 'View ' + %trimr(viewLibFile) + ' not created.';
          dsply dsplyMsg;
          return;
        endif;

        // Grant permission to file

        sqlstmtLarge = 'grant select,insert,update,delete '
                + 'on ' + %trim(viewLibFile) + ' '
                + 'to public';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Grant Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add comment to file

        sqlstmtLarge = 'comment on table ' + %trimr(viewLibFile) + ' '
                + 'is ''View to split out '
                + %trimr(file) + ' ' + %trim(code) + ' fields''';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Comment Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add file label

        sqlstmtLarge = 'label on table ' + %trimr(viewLibFile) + ' '
                + 'is ''' + %trimr(file) + ' ' + %trimr(code) + ' '
                + 'field view - 6.40''';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Table Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        // Add column labels
        //   To create a multi-line comment,
        //   second line must start at position 21.

        sqlstmtLarge = 'label on column ' + %trimr(viewLibFile) + ' '
                + '('
                +   'pswspin1 is ''Spin indicator 1'
                +               ''','
                +   'pswpick1 is ''Row/Col 1 '
                +               ''','
                +   'pswcube1 is ''Cube 1 '
                +               ''','
                +   'pswstp11 is ''Beginning of Stop '
                +               'range 1'','
                +   'pswstp21 is ''Ending of Stop '
                +               'range 1'','
                +   'pswdoor1 is ''Door 1'
                +               ''','
                +   'pswspcs1 is ''Pallet pieces 1'
                +               ''','
                +   'pswrtpa1 is ''..'
                +               ''','
                +   'pswwgt1 is ''Pallet Weight 1 '
                +               ''','
                +   'pswsscc1 is ''SSCC 18 pallet '
                +               'number 1'','
                +   'pswpal#1 is ''Pallet number 1'
                +               ''','
                +   'pswpcmp1 is ''Compartment Code 1'
                +               ''','
                +   'pswplid1 is ''Pallet Id 1'
                +               ''','
                +   'pswbgc1 is ''Background Color 1'
                +               ''','
                +   'pswspin2 is ''Spin indicator 2'
                +               ''','
                +   'pswpick2 is ''Row/Col 2 '
                +               ''','
                +   'pswcube2 is ''Cube 2 '
                +               ''','
                +   'pswstp12 is ''Beginning of Stop '
                +               'range 2'','
                +   'pswstp22 is ''Ending of Stop '
                +               'range 2'','
                +   'pswdoor2 is ''Door 2'
                +               ''','
                +   'pswspcs2 is ''Pallet pieces 2'
                +               ''','
                +   'pswrtpa2 is ''..'
                +               ''','
                +   'pswwgt2 is ''Pallet Weight 2'
                +               ''','
                +   'pswsscc2 is ''SSCC 18 pallet '
                +               'number 2'','
                +   'pswpal#2 is ''Pallet number 2'
                +               ''','
                +   'pswpcmp2 is ''Compartment Code 2'
                +               ''','
                +   'pswplid2 is ''Pallet Id 2'
                +               ''','
                +   'pswbgc2 is ''Background Color 2'
                +               ''','
                +   'pswspin3 is ''Spin indicator 3'
                +               ''','
                +   'pswpick3 is ''Row/Col 3  '
                +               ''','
                +   'pswcube3 is ''Cube 3'
                +               ''','
                +   'pswstp13 is ''Beginning of Stop '
                +               'range 3'','
                +   'pswstp23 is ''Ending of Stop '
                +               'range 3'','
                +   'pswdoor3 is ''Door 3'
                +               ''','
                +   'pswspcs3 is ''Pallet pieces 3'
                +               ''','
                +   'pswrtpa3 is ''..'
                +               ''','
                +   'pswwgt3 is ''Pallet Weight 3'
                +               ''','
                +   'pswsscc3 is ''SSCC 18 pallet '
                +               'number 3'','
                +   'pswpal#3 is ''Pallet number 3'
                +               ''','
                +   'pswpcmp3 is ''Compartment Code 3'
                +               ''','
                +   'pswplid3 is ''Pallet Id 3'
                +               ''','
                +   'pswbgc3 is ''Background Color 3'
                +               ''','
                +   'pswspin4 is ''Spin indicator 4'
                +               ''','
                +   'pswpick4 is ''Row/Col 4 '
                +               ''','
                +   'pswcube4 is ''Cube 4 '
                +               ''','
                +   'pswstp14 is ''Beginning of Stop '
                +               'range  4'','
                +   'pswstp24 is ''Ending of Stop '
                +               'range 4'','
                +   'pswdoor4 is ''Door 4'
                +               ''','
                +   'pswspcs4 is ''Pallet pieces 4'
                +               ''','
                +   'pswrtpa4 is ''..'
                +               ''','
                +   'pswwgt4 is ''Pallet Weight 4'
                +               ''','
                +   'pswsscc4 is ''SSCC 18 pallet '
                +               'number 4'','
                +   'pswpal#4 is ''Pallet number 4'
                +               ''','
                +   'pswpcmp4 is ''Compartment Code 4'
                +               ''','
                +   'pswplid4 is ''Pallet Id 4'
                +               ''','
                +   'pswbgc4 is ''Background Color 4'
                +               ''','
                +   'pswspin5 is ''Spin indicator 5'
                +               ''','
                +   'pswpick5 is ''Row/Col 5'
                +               ''','
                +   'pswcube5 is ''Cube 5 '
                +               ''','
                +   'pswstp15 is ''Beginning of Stop '
                +               'range 5'','
                +   'pswstp25 is ''Ending of Stop '
                +               'range 5'','
                +   'pswdoor5 is ''Door 5'
                +               ''','
                +   'pswspcs5 is ''Pallet pieces 5'
                +               ''','
                +   'pswrtpa5 is ''..'
                +               ''','
                +   'pswwgt5 is ''Pallet Weight 5'
                +               ''','
                +   'pswsscc5 is ''SSCC 18 pallet '
                +               'number 5'','
                +   'pswpal#5 is ''Pallet number 5'
                +               ''','
                +   'pswpcmp5 is ''Compartment Code 5'
                +               ''','
                +   'pswplid5 is ''Pallet Id 5'
                +               ''','
                +   'pswbgc5 is ''Background Color 5'
                +               ''','
                +   'pswspin6 is ''Spin indicator 5'
                +               ''','
                +   'pswpick6 is ''Row/Col 5 '
                +               ''','
                +   'pswcube6 is ''Cube 5 '
                +               ''','
                +   'pswstp16 is ''Beginning of Stop '
                +               'range 5'','
                +   'pswstp26 is ''Ending of Stop '
                +               'range 5'','
                +   'pswdoor6 is ''Door 5'
                +               ''','
                +   'pswspcs6 is ''Pallet pieces 5'
                +               ''','
                +   'pswrtpa6 is ''..'
                +               ''','
                +   'pswwgt6 is ''Pallet Weight 5'
                +               ''','
                +   'pswsscc6 is ''SSCC 18 pallet  '
                +               'number 6'','
                +   'pswpal#6 is ''Pallet number 6'
                +               ''','
                +   'pswpcmp6 is ''Compartment Code 6'
                +               ''','
                +   'pswplid6 is ''Pallet Id 6'
                +               ''','
                +   'pswbgc6 is ''Background Color 6'
                +               ''','
                +   'pswspin7 is ''Spin indicator 7'
                +               ''','
                +   'pswpick7 is ''Row/Col 7'
                +               ''','
                +   'pswcube7 is ''Cube 7'
                +               ''','
                +   'pswstp17 is ''Beginning of Stop '
                +               'range 7'','
                +   'pswstp27 is ''Ending of Stop '
                +               'range 7'','
                +   'pswdoor7 is ''Door 7'
                +               ''','
                +   'pswspcs7 is ''Pallet pieces 7'
                +               ''','
                +   'pswrtpa7 is ''..'
                +               ''','
                +   'pswwgt7 is ''Pallet Weight 7'
                +               ''','
                +   'pswsscc7 is ''SSCC 18 pallet  '
                +               'number 7'','
                +   'pswpal#7 is ''Pallet number 7'
                +               ''','
                +   'pswpcmp7 is ''Compartment Code 7'
                +               ''','
                +   'pswplid7 is ''Pallet Id 7'
                +               ''','
                +   'pswbgc7 is ''Background Color 7'
                +               ''','
                +   'pswspin8 is ''Spin indicator 8'
                +               ''','
                +   'pswpick8 is ''Row/Col 8 '
                +               ''','
                +   'pswcube8 is ''Cube 8 '
                +               ''','
                +   'pswstp18 is ''Beginning of Stop '
                +               'range 8'','
                +   'pswstp28 is ''Ending of Stop '
                +               'range 8'','
                +   'pswdoor8 is ''Door '
                +               ''','
                +   'pswspcs8 is ''Pallet pieces 8 '
                +               ''','
                +   'pswrtpa8 is ''..'
                +               ''','
                +   'pswwgt8 is ''Pallet Weight 8'
                +               ''','
                +   'pswsscc8 is ''SSCC 18 pallet '
                +               'number 8'','
                +   'pswpal#8 is ''Pallet number 8'
                +               ''','
                +   'pswpcmp8 is ''Compartment Code 8 '
                +               ''','
                +   'pswplid8 is ''Pallet Id 8'
                +               ''','
                +   'pswbgc8 is ''Background Color 8'
                +               ''','
                +   'pswspin9 is ''Spin indicator 9'
                +               ''','
                +   'pswpick9 is ''Row/Col 9 '
                +               ''','
                +   'pswcube9 is ''Cube '
                +               'number 9'','
                +   'pswstp19 is ''Beginning of Stop '
                +               'range 9'','
                +   'pswstp29 is ''Ending of Stop '
                +               'range 9'','
                +   'pswdoor9 is ''Door 9'
                +               ''','
                +   'pswspcs9 is ''Pallet pieces 9 '
                +               ''','
                +   'pswrtpa9 is ''..'
                +               ''','
                +   'pswwgt9 is ''Pallet Weight 9'
                +               ''','
                +   'pswsscc9 is ''SSCC 18 pallet  '
                +               'number 9'','
                +   'pswpal#9 is ''Pallet number 9'
                +               ''','
                +   'pswpcmp9 is ''Compartment Code 9'
                +               ''','
                +   'pswplid9 is ''Pallet Id 9'
                +               ''','
                +   'pswbgc9 is ''Background Color 9'
                +               ''','
                +   'pssrlst11 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst12 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst21 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst22 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst31 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst32 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst41 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst42 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst51 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst52 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst61 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst62 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst71 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst72 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst81 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst82 is ''Super Route Child List2'
                +               ''','
                +   'pssrlst91 is ''Super Route Child List1'
                +               ''','
                +   'pssrlst92 is ''Super Route Child List2'
                +               ''''
                + ')';

        exec sql execute immediate :sqlstmtLarge;
        if sqlstt <> sqlSuccess;
          dsplyMsg = 'Column Label Error: SQLSTT = ' + sqlstt;
          dsply dsplyMsg;
        endif;

        return;

      /end-free
