/* TAASPLD - Dup a spool file to another OUTQ - DUPSPLFBFC          */
/*PARMS PGM(TAASPLDC) PRDLIB(TAATOOL)                               */
/*                                                                  */
/*------------------------------------------------------------------*/
/* Revisions:                                                       */
/*   05/17/16  MLB  7.00                                            */
/*     - Enh: Changed name of cmd to DUPSPLFBFC due to conflict at  */
/*       client site. (Y.Hata).                                     */
/*     - CPP: DUPSPLFCL.                                            */
/*                                                                  */
/*------------------------------------------------------------------*/
/*                                                                  */
/* The Duplicate Spool file command duplicates a spool file         */
/*   from one output queue to another. Some restrictions exist.     */
/*                                                                  */
/* The CPP is TAASPLDC.                                             */
/*                                                                  */
             CMD        PROMPT('BFC Duplicate Spool File')
             PARM         KWD(FILE) TYPE(*NAME) LEN(10) MIN(1) +
                          EXPR(*YES) +
                          PROMPT('Spool file name')
             PARM       KWD(JOB) TYPE(QUAL1) SNGVAL(*) DFT(*) +
                          PROMPT('Job name')
             PARM       KWD(PRTFILE) TYPE(QUAL2) +
                          PROMPT('Printer File name')
             PARM       KWD(OUTQ) TYPE(QUAL3) PROMPT('Spooled output +
                          queue name')
             PARM       KWD(SPLNBR) TYPE(*CHAR) LEN(6) DFT(*ONLY) +
                          RANGE(0001 9999) SPCVAL(*ONLY *LAST) +
                          PROMPT('Spool file number')
             PARM       KWD(COPIES) TYPE(*DEC) LEN(3 0) DFT(1) +
                          RANGE(1 255) +
                          PROMPT('Copies')
             PARM         KWD(NEWNAME) TYPE(*NAME) LEN(10) +
                          EXPR(*YES) DFT(*PRTFILE) +
                          SPCVAL(*PRTFILE *FILE) +
                          PROMPT('New spooled file name')
             PARM       KWD(DLTOLDSPLF) TYPE(*CHAR) LEN(4) DFT(*NO) +
                          RSTD(*YES) VALUES('*YES' '*NO') +
                          PROMPT('Delete old spooled file')
 QUAL1:      QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) MIN(0) EXPR(*YES) +
                          PROMPT('User name')
             QUAL       TYPE(*CHAR) LEN(6)  MIN(0) FULL(*YES)    +
                          RANGE(000000 999999) +
                          PROMPT('Job number')
 QUAL2:      QUAL       TYPE(*NAME) LEN(10) DFT(QSYSPRT) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL) +
                          EXPR(*YES) PROMPT('Library name')
 QUAL3:      QUAL       TYPE(*NAME) LEN(10) DFT(*PRTFILE) +
                          SPCVAL((*PRTFILE)) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL) +
                          EXPR(*YES) PROMPT('Library name')
