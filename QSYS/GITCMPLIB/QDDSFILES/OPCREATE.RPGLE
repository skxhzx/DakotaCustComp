      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  OPCREATE   Program to create OP files
     *  04 August 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    08/04/12  DAS  6.40
     *      - Created.
     *
700aA*    10/22/15  DAS  7.00
     *      - Added OPSPROD.
     *
740aA*    08/13/20  DAS  7.40a
     *      - Added missing programs:
     *           OPCTRAX/1, OPEUSER, OPSMRCRPT, OPSTRAX1/2/3
     *
740bA*    08/31/20  DAS  7.40b
     *      - Added OPSPLTPRTY
     *
760 A*    07/13/22  KDE  7.60
     *      - Added TSDETAIL
     *
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

740aAd opctrax         pr                  extpgm('OPCTRAX')
     d  pfLib                        10
     d  viewLib                      10

740aAd opctrax1        pr                  extpgm('OPCTRAX1')
     d  pfLib                        10
     d  viewLib                      10

     d opdpick         pr                  extpgm('OPDPICK')
     d  pfLib                        10
     d  viewLib                      10

740aAd opeuser         pr                  extpgm('OPEUSER')
     d  pfLib                        10
     d  viewLib                      10

     d opschkdgt       pr                  extpgm('OPSCHKDGT')
     d  pfLib                        10
     d  viewLib                      10

     d opsclose        pr                  extpgm('OPSCLOSE')
     d  pfLib                        10
     d  viewLib                      10

     d opscount        pr                  extpgm('OPSCOUNT')
     d  pfLib                        10
     d  viewLib                      10

     d opsdateopt      pr                  extpgm('OPSDATEOPT')
     d  pfLib                        10
     d  viewLib                      10

     d opsdayend       pr                  extpgm('OPSDAYEND')
     d  pfLib                        10
     d  viewLib                      10

     d opsdlyhit       pr                  extpgm('OPSDLYHIT')
     d  pfLib                        10
     d  viewLib                      10

     d opsdocdoor      pr                  extpgm('OPSDOCDOOR')
     d  pfLib                        10
     d  viewLib                      10

     d opsfeature      pr                  extpgm('OPSFEATURE')
     d  pfLib                        10
     d  viewLib                      10

     d opsftp          pr                  extpgm('OPSFTP')
     d  pfLib                        10
     d  viewLib                      10

     d opsftpimp       pr                  extpgm('OPSFTPIMP')
     d  pfLib                        10
     d  viewLib                      10

     d opsgenpick      pr                  extpgm('OPSGENPICK')
     d  pfLib                        10
     d  viewLib                      10

     d opsimpitem      pr                  extpgm('OPSIMPITEM')
     d  pfLib                        10
     d  viewLib                      10

     d opsinterlv      pr                  extpgm('OPSINTERLV')
     d  pfLib                        10
     d  viewLib                      10

     d opsitemmnt      pr                  extpgm('OPSITEMMNT')
     d  pfLib                        10
     d  viewLib                      10

     d opslicense      pr                  extpgm('OPSLICENSE')
     d  pfLib                        10
     d  viewLib                      10

     d opsloader       pr                  extpgm('OPSLOADER')
     d  pfLib                        10
     d  viewLib                      10

740aAd opsmrcrpt       pr                  extpgm('OPSMRCRPT')
     d  pfLib                        10
     d  viewLib                      10

     d opspattern      pr                  extpgm('OPSPATTERN')
     d  pfLib                        10
     d  viewLib                      10

740bAd opspltprty      pr                  extpgm('OPSPLTPRTY')
740bAd  pfLib                        10
740bAd  viewLib                      10

700aAd opsprod         pr                  extpgm('OPSPROD')
700aAd  pfLib                        10
700aAd  viewLib                      10

     d opsrcvlbl       pr                  extpgm('OPSRCVLBL')
     d  pfLib                        10
     d  viewLib                      10

     d opsrepack       pr                  extpgm('OPSREPACK')
     d  pfLib                        10
     d  viewLib                      10

     d opsreplen       pr                  extpgm('OPSREPLEN')
     d  pfLib                        10
     d  viewLib                      10

     d opsreturns      pr                  extpgm('OPSRETURNS')
     d  pfLib                        10
     d  viewLib                      10

     d opsrfput        pr                  extpgm('OPSRFPUT')
     d  pfLib                        10
     d  viewLib                      10

     d opsrunner       pr                  extpgm('OPSRUNNER')
     d  pfLib                        10
     d  viewLib                      10

     d opsslot         pr                  extpgm('OPSSLOT')
     d  pfLib                        10
     d  viewLib                      10

     d opssltfifo      pr                  extpgm('OPSSLTFIFO')
     d  pfLib                        10
     d  viewLib                      10

     d opssystem       pr                  extpgm('OPSSYSTEM')
     d  pfLib                        10
     d  viewLib                      10

     d opstracksp      pr                  extpgm('OPSTRACKSP')
     d  pfLib                        10
     d  viewLib                      10

     d opstrax         pr                  extpgm('OPSTRAX')
     d  pfLib                        10
     d  viewLib                      10

740aAd opstrax1        pr                  extpgm('OPSTRAX1')
     d  pfLib                        10
     d  viewLib                      10

740aAd opstrax2        pr                  extpgm('OPSTRAX2')
     d  pfLib                        10
     d  viewLib                      10

740aAd opstrax3        pr                  extpgm('OPSTRAX3')
     d  pfLib                        10
     d  viewLib                      10

     d opsvirtual      pr                  extpgm('OPSVIRTUAL')
     d  pfLib                        10
     d  viewLib                      10

     d opsvoice        pr                  extpgm('OPSVOICE')
     d  pfLib                        10
     d  viewLib                      10

     d opszerovfy      pr                  extpgm('OPSZEROVFY')
     d  pfLib                        10
     d  viewLib                      10

     d opzpick         pr                  extpgm('OPZPICK')
     d  pfLib                        10
     d  viewLib                      10

     d opzpicklba      pr                  extpgm('OPZPICKLBA')
     d  pfLib                        10
     d  viewLib                      10

     d opzpicklbb      pr                  extpgm('OPZPICKLBB')
     d  pfLib                        10
     d  viewLib                      10

     d opzpicklbl      pr                  extpgm('OPZPICKLBL')
     d  pfLib                        10
     d  viewLib                      10

760 Ad slot16          pr                  extpgm('SLOT16')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad slot17          pr                  extpgm('SLOT17')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad slot18          pr                  extpgm('SLOT18')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad tsdetail        pr                  extpgm('TSDETAIL')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad tscols          pr                  extpgm('TSCOLS')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad tshead2         pr                  extpgm('TSHEAD2')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad tstotcol        pr                  extpgm('TSTOTCOL')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

760 Ad tstotsum        pr                  extpgm('TSTOTSUM')
760 Ad  pfLib                        10
760 Ad  viewLib                      10

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
                     + 'CALL OPCREATE (pfLib viewLib)';
            dsply DsplyMsg;
            return;
        endif;

        // Create files

740aA   opctrax(pPFLib: pViewLib);
740aA   opctrax1(pPFLib: pViewLib);
        opdpick(pPFLib: pViewLib);
740aA   opeuser(pPFLib: pViewLib);
        opschkdgt(pPFLib: pViewLib);
        opsclose(pPFLib: pViewLib);
        opscount(pPFLib: pViewLib);
        opsdateopt(pPFLib: pViewLib);
        opsdayend(pPFLib: pViewLib);
        opsdlyhit(pPFLib: pViewLib);
        opsdocdoor(pPFLib: pViewLib);
        opsfeature(pPFLib: pViewLib);
        opsftp(pPFLib: pViewLib);
        opsftpimp(pPFLib: pViewLib);
        opsgenpick(pPFLib: pViewLib);
        opsimpitem(pPFLib: pViewLib);
        opsinterlv(pPFLib: pViewLib);
        opsitemmnt(pPFLib: pViewLib);
        opslicense(pPFLib: pViewLib);
        opsloader (pPFLib: pViewLib);
740aA   opsmrcrpt(pPFLib: pViewLib);
        opspattern(pPFLib: pViewLib);
740bA   opspltprty(pPFLib: pViewLib);
700aA   opsprod(pPFLib: pViewLib);
        opsrcvlbl(pPFLib: pViewLib);
        opsrepack(pPFLib: pViewLib);
        opsreplen(pPFLib: pViewLib);
        opsreturns(pPFLib: pViewLib);
        opsrfput(pPFLib: pViewLib);
        opsrunner(pPFLib: pViewLib);
        opsslot(pPFLib: pViewLib);
        opssltfifo(pPFLib: pViewLib);
        opssystem(pPFLib: pViewLib);
        opstracksp(pPFLib: pViewLib);
        opstrax(pPFLib: pViewLib);
740aA   opstrax1(pPFLib: pViewLib);
740aA   opstrax2(pPFLib: pViewLib);
740aA   opstrax3(pPFLib: pViewLib);
        opsvirtual(pPFLib: pViewLib);
        opsvoice(pPFLib: pViewLib);
        opszerovfy(pPFLib: pViewLib);
        opzpick(pPFLib: pViewLib);
        opzpicklba(pPFLib: pViewLib);
        opzpicklbb(pPFLib: pViewLib);
        opzpicklbl(pPFLib: pViewLib);
760 A   opsprod(pPFLib: pViewLib);
760 A   slot16(pPFLib: pViewLib);
760 A   slot17(pPFLib: pViewLib);
760 A   slot18(pPFLib: pViewLib);
760 A   tsdetail(pPFLib: pViewLib);
760 A   tscols(pPFLib: pViewLib);
760 A   tshead2(pPFLib: pViewLib);
760 A   tstotcol(pPFLib: pViewLib);
760 A   tstotsum(pPFLib: pViewLib);

      /end-free
