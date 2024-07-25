      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  R25900   Runner Exceptions Report - get JSON info
     *  23 August 2017
     *  Mike Rooker
     *
     *  Revisions
     *
610  *    08/23/17  MR  7.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

700aMD pFrmSlot        s             12
700aMD pToSlot         s             12
700aMD pSection        s              1
700aMD pDept           s              5
700aMD pExerId         s              7
700aMD pGenDate        s              8  0
700aMD pGenTime        s              6  0
     D pOutStr         s           1024    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
     D W1rtrn          s              7
     D W1ptrn          s              7
     D W1plbl          s              7
     D W1dept          s              5
     D W1sect          s              5
700aMD errMsg          s             25a
700aMD genDte          s              6  0
700aMD timex           s              6
700aMD datex           s              6
     *----------------------------------------------------------------
     *  Data Structures
     *----------------------------------------------------------------
     D                 DS
     D fromSlot                1     12
     D toSlot                 13     24
     D*
     D dsrtrn                  1      7
     D dsptrn                  8     14
     D dsplbl                 15     21

     D WDATE           DS
     D wMON                    1      2
     D wday                    3      4
     D wyear                   5      6

     D FMTDATE         DS
     D fmon                    1      2
     D fslash                  3      3    inz('/')
     D fday                    4      5
     D fslash2                 6      6    inz('/')
     D fyear                   7      8

     D WTime           DS
     D whour                   1      2
     D wmin                    3      4
     D wsec                    5      6

     D fmtTime         DS
     D fhour                   1      2
     D fcol1                   3      3    inz(':')
     D fmin                    4      5
     D fcol2                   6      6    inz(':')
     D fsec                    7      8
      *
     D$CVTDT           DS
     D $cvcmd                  1      8
     D $cvprg                  9     18
     D $cvd6i                 19     24
     D $cvd8i                 25     32
     D $cvd6o                 33     38  0
     D $cvd8o                 39     46  0
     D $cvsto                 47     64
     D $cvrtn                 65     72
     D $cverm                 73    132
     D $cvmsg                 73     76
      *
     D convertDte      PR                  Extpgm('CVTDTE')
     D  $CVTDT                      132a
     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pExerId      Exerid
     *      pFrmSlot     From Slot
     *      pToSlot      To Slot
     *      pSection     Section Type
     *      pDept        Whse Dept
     *      pGenDate     Generated Date
     *      pGenTime     Generated Time
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pExerId
     c                   parm                    pFrmSlot
     c                   parm                    pToSlot
     c                   parm                    pSection
     c                   parm                    pDept
     c                   parm                    pGenDate
     c                   parm                    pGenTime
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        eval fromSlot = pFrmSlot;
        eval toSlot = pToSlot;
        *inlr = *on;
        if  pExerId = 'OVRZRO';
        //if  pExerId = 'NOSCAN';
            eval errmsg = 'Zero w/Avail Qty Override';
            eval w1rtrn = dsrtrn;
            eval w1ptrn = dsptrn;
            eval w1plbl = dsplbl;
        else;
            eval errmsg = pExerId;
        endif;

        // Format Time
        eval timex = %char(pGenTime);
        if %len(%trim(timex)) = 5;
          eval timex = '0'+timex;
        endif;
        eval wtime = timex;
        eval fhour=whour;
        eval fmin =wmin;
        eval fsec = wsec;

        //Convert and Format Generated date
         eval $cvcmd = '*CMDMDY';
         eval $cvd8i = %char(pGenDate);
         ConvertDte ($cvtdt);
         eval gendte = $CVD6O;
         eval datex = %char(gendte);
         if %len(%trim(datex)) = 5;
            eval datex = '0'+datex;
         endif;
         eval wdate=datex;
         eval fmon=wmon;
         eval fday=wday;
         eval fyear=wyear;

        //Section Description
        eval w1Dept = pDept;
        if pSection = 'F';
           eval w1Sect='Fixed';
        else;
        if pSection = 'P';
           eval w1Sect = 'PIR';
        else;
           eval w1Sect = '*Both';
        endif;
        endif;

        // Build JSON string to return

        pOutStr = '{'
700aM      +  '"w1Rtrn":"'+ %trim(w1rtrn)+'",'
700aM      +  '"w1Ptrn":"'+ %trim(w1ptrn)+'",'
700aM      +  '"w1Plbl":"'+ %trim(w1plbl)+'",'
           +  '"w1DptSec":"'+ %trim(%trim(w1Dept)+'/'+%trim(w1Sect))+'",'
700aM      +  '"w1GTime":"'+ %trim(fmtTime)+'",'
700aM      +  '"w1GDate":"'+ %trim(fmtDate)+'",'
700aM      +  '"errMsg":"'+ %trim(errMsg)+'"';

        // Add custom client fields

        // Close it off

        pOutStr = %trimr(pOutStr) + '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;


       endsr;
      /end-free
