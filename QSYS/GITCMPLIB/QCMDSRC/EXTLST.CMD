/* EXTLST - Extract List of parameters - EXTLST cmd                 */
/*PARMS PGM(EXTLSTCL) ALLOW((*IPGM)(*BPGM))                          */
/*                                                                  */
/* The Extract List command extracts the elements from a command    */
/*   definition parameter which is a list. This simplifies list     */
/*   processing for either a simple list or a list of lists.        */
/*                                                                  */
/* The CPP is EXTLSTCL                                              */
/*                                                                  */
             CMD        PROMPT('Extract List')
             PARM       KWD(LIST) TYPE(*CHAR) LEN(2000) +
                          PROMPT('List as char parm (Up to 2000)')
             PARM       KWD(ELMLEN) TYPE(*DEC) LEN(5 0) REL(*GT 0) +
                          PROMPT('Element length')
             PARM       KWD(ELEMENT) TYPE(*CHAR) LEN(100) +
                          RTNVAL(*YES) +
                          PROMPT('Return element           (100)')
             PARM       KWD(CURNBR) TYPE(*DEC) LEN(5 0) +
                          RTNVAL(*YES) +
                          PROMPT('Current list number      (5 0)')
             PARM       KWD(MULTILIST) TYPE(*CHAR) LEN(4) DFT(*NO) +
                          RSTD(*YES) VALUES('*YES' '*NO') +
                          PROMPT('Multiple list')
