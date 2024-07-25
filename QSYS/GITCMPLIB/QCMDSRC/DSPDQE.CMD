/*-------------------------------------------------------------------*/
/* DSPDQE- Display Data Queue Entries - Command Definition           */
/* By   Craig Rutledge, 06/11/93                                     */
/*-------------------------------------------------------------------*/
/* Command Summary:                                                  */
/* The command will display, in a subfile, all entries in a DATAQ.   */
/* The entries on the queue are not touched or disturbed.            */
/*-------------------------------------------------------------------*/
/* Related Objects:                                                  */
/* DSPDQER   *PGM    RPGLE    Display data queue entries             */
/* DSPDQED   *FILE   DSPF                                            */
/* DSPDQEH   *PNLGRP          Help Text                              */
/* OBJCHKRV  *PGM    RPGLE    Validity checker                      */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Display Data Queue Entries')

             PARM       KWD(DTAQ) TYPE(QUAL1) MIN(1) PROMPT('Data +
                          queue:')
             PARM       KWD(OBJTYP) TYPE(*CHAR) LEN(10) +
                          CONSTANT('*DTAQ     ')

 QUAL1:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) PROMPT('Library name:')
