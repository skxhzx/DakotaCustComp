/*-------------------------------------------------------------------*/
/*                                                                   */
/*  CRTSTATJSE   Create Stats Job Schedule Entries                   */
/*  07 June 2014                                                     */
/*  Rod Roller                                                       */
/*                                                                   */
/*  Revisions                                                        */
/*                                                                   */
/*    07/07/14  RTR  6.50a                                           */
/*      - Created.                                                   */
/*    01/05/14  RTR  6.50b                                           */
/*      - Changed to use JOBQ(QSYSNOMAX) per email from Dave S.      */
/*                                                                   */
/*-------------------------------------------------------------------*/

 CRTSTATJSE:   PGM

/*-------------------------------------------------------------------*/
/*  Main line                                                        */
/*-------------------------------------------------------------------*/

             ADDJOBSCDE JOB(PIRSTATS1) CMD(CALL PGM(WRTRECCNT) +
                          PARM('A')) FRQ(*WEEKLY) SCDDATE(*NONE) +
                          SCDDAY(*ALL) SCDTIME(050100) TEXT('BFC +
                          Statistics - WRTRECCNT Daily') +
                          JOBQ(QSYSNOMAX)                    /* 650bA */

             ADDJOBSCDE JOB(PIRSTATS2) CMD(CALL PGM(BFCFILSIZ) +
                          PARM('PIRF')) FRQ(*MONTHLY) +
                          SCDDATE(*MONTHSTR) SCDDAY(*NONE) +
                          SCDTIME('05:00:00') TEXT('BFC Statistics +
                          - BFCFILSIZ Monthly') +
                          JOBQ(QSYSNOMAX)                    /* 650bA */

             ADDJOBSCDE JOB(PIRSTATS3) CMD(CALL PGM(CRTSTATREC)) +
                          FRQ(*MONTHLY) SCDDATE(*MONTHSTR) +
                          SCDDAY(*NONE) SCDTIME('05:05:00') +
                          TEXT('BFC Statistics - CRTSTATREC Monthly') +
                          JOBQ(QSYSNOMAX)                    /* 650bA */

             ENDPGM
