    /*---------------------------------------------------------------*/
    /*     http://home.columbus.rr.com/jbmmdietz/iseries.html        */
    /*        ShowIP Addresses                                       */
    /*                                                               */
    /*          If you find this useful or                           */
    /*          you want to help make it better or                   */
    /*          you can think of a better way......                  */
    /*          drop me a note.  bryandietz@yahoo.com                */
    /*                                                               */
    /*     The following is needed for this command.                 */
    /*     #crtoutq   clp                                            */
    /*     ilecmdcnt  rpgle                                          */
    /*     iledspds   rpgle                                          */
    /*     ileerrmsg  rpgle                                          */
    /*     ileerrprc  rpgle                                          */
    /*     ilepgmds   rpgle                                          */
    /*     rmtoutqds  dspf                                           */
    /*     rmtoutqr2  sqlrpgle                                       */
    /*     wrkrmtwtr  cmd                                            */
    /*     zrmtoqolc  clp                                            */

             CMD        PROMPT('Work with Remote Writers')
             PARM       KWD(OUTQ) TYPE(*CHAR) LEN(10) DFT(*ALL) +
                          PROMPT('OutQ Name, *ALL, *GENERIC' 1)
             PARM       KWD(LIBRARY) TYPE(*CHAR) LEN(10) +
                          DFT(*ALLUSR) PROMPT('Library (*LIBL, +
                          *ALL, *ALLUSR)' 2)




             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          DFT(*) VALUES(* *FILE) PROMPT('Output' 2)
             PARM       KWD(FILE) TYPE(FILE) PMTCTL(ISFILE) +
                          PROMPT('File Name' 3)
             PARM       KWD(FILEOPT) TYPE(*NAME) LEN(8) DFT(*ADD) +
                          SPCVAL((*ADD) (*REPLACE)) PMTCTL(ISFILE) +
                          PROMPT('File Option' 4)
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library')
 ISFILE:     PMTCTL     CTL(OUTPUT) COND((*EQ '*FILE'))
