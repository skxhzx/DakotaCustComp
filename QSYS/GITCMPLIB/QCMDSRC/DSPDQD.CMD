/*-------------------------------------------------------------------*/
/* DSPDQD - Display Datq Description - Command Definition            */
/* By   Craig Rutledge, 10/08/92                                     */
/*-------------------------------------------------------------------*/
/* Command Summary:                                                  */
/* The command displays the object description for a dataq.  Included*/
/* are data queue length, sequence, and key length.                  */
/*-------------------------------------------------------------------*/
/* Related Objects:                                                  */
/* DSPDQDR    *PGM    RPGLE    Command processing program            */
/* DSPDQDD    *FILE   DSPF     Display file used for DSPDQD          */
/* DSPDQDH    *PNLGRP          Help Text                             */
/* OBJCHKRV   *PGM    RPGLE    Validity checker                      */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Display Dataq Description')

             PARM       KWD(DTAQ) TYPE(Q1) MIN(1) PROMPT('Data Queue')
             PARM       KWD(OBJTYP) TYPE(*CHAR) CONSTANT('*DTAQ     ')

 Q1:         QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library:')
